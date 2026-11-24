param(
    [int] $DebounceSeconds = 5
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$safeDirectory = $repoRoot.Replace('\', '/')
$pending = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$watcher = [System.IO.FileSystemWatcher]::new($repoRoot)
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, DirectoryName, LastWrite, Size'

function Invoke-Git([string[]] $GitArgs) {
    $result = & git -c "safe.directory=$safeDirectory" -C $repoRoot @GitArgs 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Git gagal: $($result -join [Environment]::NewLine)" }
    return $result
}

function Add-ChangedPath([string] $FullPath) {
    if ([string]::IsNullOrWhiteSpace($FullPath)) { return }
    $relative = [System.IO.Path]::GetRelativePath($repoRoot, $FullPath).Replace('\', '/')
    if ($relative -eq '..' -or $relative.StartsWith('../') -or $relative.StartsWith('.git/')) { return }
    if ($relative -match '(^|/)(bin|obj|\.vs)/' -or $relative -match '\.(user|suo)$') { return }
    [void]$pending.Add($relative)
}

$onChanged = [System.IO.FileSystemEventHandler]{ param($sender, $event) Add-ChangedPath $event.FullPath }.GetNewClosure()
$onRenamed = [System.IO.RenamedEventHandler]{ param($sender, $event) Add-ChangedPath $event.FullPath; Add-ChangedPath $event.OldFullPath }.GetNewClosure()
$watcher.add_Changed($onChanged)
$watcher.add_Created($onChanged)
$watcher.add_Deleted($onChanged)
$watcher.add_Renamed($onRenamed)
$watcher.EnableRaisingEvents = $true

Write-Host "Automatic local commits are running in $repoRoot. Press Ctrl+C to stop. No push will be performed."
Write-Host "Changes are grouped for $DebounceSeconds seconds. Existing files are not committed until they change after startup."

try {
    while ($true) {
        Start-Sleep -Milliseconds 500
        if ($pending.Count -eq 0) { continue }
        Start-Sleep -Seconds $DebounceSeconds

        $paths = @($pending)
        $pending.Clear()

        # Do not absorb changes that were already staged before this watcher ran.
        $staged = @(Invoke-Git @('diff', '--cached', '--name-only'))
        if ($staged.Count -gt 0) {
            Write-Warning 'Commit otomatis dilewati karena index Git sudah berisi perubahan staged. Kosongkan/commit index lalu ubah file lagi.'
            continue
        }

        $changed = [System.Collections.Generic.List[string]]::new()
        foreach ($path in $paths) {
            $status = @(Invoke-Git @('status', '--porcelain', '--untracked-files=all', '--', ":(literal)$path"))
            if ($status.Count -gt 0) { [void]$changed.Add($path) }
        }
        if ($changed.Count -eq 0) { continue }

        foreach ($path in $changed) { Invoke-Git @('add', '-A', '--', ":(literal)$path") | Out-Null }

        $cached = @(Invoke-Git @('diff', '--cached', '--name-status'))
        $added = @($cached | Where-Object { $_ -match '^A\s' })
        $type = if ($added.Count -gt 0) { 'feat' } else { 'chore' }
        $names = @($changed | ForEach-Object { [System.IO.Path]::GetFileName($_) } | Select-Object -Unique)
        if ($names.Count -le 2) { $summary = $names -join ' and ' }
        else { $summary = "$($names[0]), $($names[1]), and $($names.Count - 2) more files" }
        $subject = "$type(auto): update $summary"
        if ($subject.Length -gt 72) { $subject = $subject.Substring(0, 69).TrimEnd() + '...' }

        Invoke-Git @('commit', '-m', $subject)
        Write-Host "Committed: $subject"
    }
}
finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
}
