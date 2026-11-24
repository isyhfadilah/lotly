param(
    [int] $DebounceSeconds = 5,
    [int] $PollIntervalSeconds = 1
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$safeDirectory = $repoRoot.Replace('\', '/')
$ignoredDirectories = @('.git', 'bin', 'obj', '.vs', 'node_modules')
$deferredPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

function Invoke-Git([string[]] $GitArgs) {
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $result = & git -c "safe.directory=$safeDirectory" -C $repoRoot @GitArgs 2>&1
        $gitExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($gitExitCode -ne 0) { throw "Git gagal (kode $gitExitCode): $($result -join [Environment]::NewLine)" }
    return $result
}

function Get-WorkspaceSnapshot {
    $snapshot = @{}
    $directories = [System.Collections.Generic.Stack[string]]::new()
    $directories.Push($repoRoot)

    while ($directories.Count -gt 0) {
        $directory = $directories.Pop()
        foreach ($item in Get-ChildItem -LiteralPath $directory -Force -ErrorAction SilentlyContinue) {
            if ($item.PSIsContainer) {
                if ($item.Name -notin $ignoredDirectories) { $directories.Push($item.FullName) }
                continue
            }

            if ($item.Extension -in @('.user', '.suo')) { continue }
            $relative = $item.FullName.Substring($repoRoot.Length).TrimStart([char[]]@([char]92, [char]47)).Replace([char]92, [char]47)
            $snapshot[$relative] = "$($item.Length):$($item.LastWriteTimeUtc.Ticks)"
        }
    }

    return $snapshot
}

function Get-ChangedPaths($Previous, $Current) {
    $changed = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $Previous.Keys) {
        if (-not $Current.ContainsKey($path) -or $Previous[$path] -ne $Current[$path]) { [void]$changed.Add($path) }
    }
    foreach ($path in $Current.Keys) {
        if (-not $Previous.ContainsKey($path)) { [void]$changed.Add($path) }
    }
    return $changed
}

$previousSnapshot = Get-WorkspaceSnapshot
Write-Host "Watcher aktif di $repoRoot. Perubahan diperiksa setiap $PollIntervalSeconds detik; tekan Ctrl+C untuk berhenti. Tidak ada push."
Write-Host "File yang sudah ada sebelum watcher aktif tidak di-commit sampai berubah. Perubahan digabung selama $DebounceSeconds detik."

try {
    while ($true) {
        Start-Sleep -Seconds $PollIntervalSeconds
        $currentSnapshot = Get-WorkspaceSnapshot
        $changedPaths = Get-ChangedPaths $previousSnapshot $currentSnapshot
        $previousSnapshot = $currentSnapshot

        if ($changedPaths.Count -eq 0 -and $deferredPaths.Count -eq 0) { continue }
        foreach ($path in $changedPaths) { [void]$deferredPaths.Add($path) }
        Write-Host "Perubahan terdeteksi: $(@($deferredPaths) -join ', ')"
        Start-Sleep -Seconds $DebounceSeconds

        $settledSnapshot = Get-WorkspaceSnapshot
        $lateChanges = Get-ChangedPaths $previousSnapshot $settledSnapshot
        foreach ($path in $lateChanges) { [void]$deferredPaths.Add($path) }
        $previousSnapshot = $settledSnapshot

        $staged = @(Invoke-Git @('diff', '--cached', '--name-only'))
        if ($staged.Count -gt 0) {
            Write-Warning 'Commit otomatis menunggu karena index Git sudah berisi perubahan staged. Commit atau unstaged perubahan tersebut, watcher akan mencoba lagi.'
            continue
        }

        $paths = @($deferredPaths)
        $changed = [System.Collections.Generic.List[string]]::new()
        foreach ($path in $paths) {
            $status = @(Invoke-Git @('status', '--porcelain', '--untracked-files=all', '--', ":(literal)$path"))
            if ($status.Count -gt 0) { [void]$changed.Add($path) }
        }
        if ($changed.Count -eq 0) {
            $deferredPaths.Clear()
            continue
        }

        foreach ($path in $changed) { Invoke-Git @('add', '-A', '--', ":(literal)$path") | Out-Null }

        $cached = @(Invoke-Git @('diff', '--cached', '--name-status'))
        $added = @($cached | Where-Object { $_ -match '^A\s' })
        $names = @($changed | ForEach-Object { [System.IO.Path]::GetFileName($_) } | Select-Object -Unique)
        if ($added.Count -gt 0) {
            $type = 'feat'
            $verb = 'add'
        } else {
            $type = 'chore'
            $verb = 'update'
        }
        if ($names.Count -le 2) { $summary = $names -join ' and ' }
        else { $summary = "$($names[0]), $($names[1]), and $($names.Count - 2) more files" }
        $subject = "$type(auto): $verb $summary"
        if ($subject.Length -gt 72) { $subject = $subject.Substring(0, 69).TrimEnd() + '...' }

        Invoke-Git @('commit', '-m', $subject) | Out-Host
        Write-Host "Commit lokal berhasil: $subject"
        $deferredPaths.Clear()
    }
}
catch {
    Write-Error "Watcher berhenti karena gagal: $_"
    throw
}
finally {
    Write-Host 'Watcher berhenti.'
}
