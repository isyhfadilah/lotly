# Lotly

Lotly adalah prototipe marketplace berbasis ASP.NET Core Razor Pages. Model domain saat ini mencakup seller, listing, question, dan answer. Halaman utama menampilkan contoh profil seller.

## Teknologi

- .NET 10 dan ASP.NET Core Razor Pages
- C# dengan nullable reference types dan implicit usings
- pnpm untuk menjalankan watcher commit otomatis

## Persyaratan

- .NET SDK 10.0
- Git
- PowerShell dan pnpm (hanya diperlukan untuk watcher commit)

Periksa instalasi dengan:

```powershell
dotnet --version
git --version
pnpm --version
```

## Menjalankan aplikasi

Jalankan dari direktori proyek:

```powershell
dotnet run --project Lotly.csproj
```

Buka alamat lokal yang ditampilkan oleh ASP.NET Core di terminal. Untuk menjalankan aplikasi dengan pemantauan perubahan kode:

```powershell
dotnet watch --project Lotly.csproj
```

## Struktur proyek

```text
.
├── Pages/                         # Halaman Razor
├── Properties/                    # Konfigurasi peluncuran lokal
├── scripts/auto-commit.ps1        # Watcher commit lokal
├── src/Lotly.Domain/Entities/     # Entitas domain
├── wwwroot/                       # CSS, JavaScript, dan aset statis
├── Lotly.csproj
└── package.json                   # Perintah pnpm
```

## Commit otomatis

Mulai watcher dari direktori proyek dan biarkan terminal tetap terbuka:

```powershell
pnpm run commit:watch
```

Jika PowerShell memblokir `pnpm.ps1` karena execution policy, gunakan shim `.cmd`:

```powershell
pnpm.cmd run commit:watch
```

Watcher mengelompokkan perubahan selama lima detik sebelum membuat commit lokal. Terminal menampilkan saat watcher aktif, perubahan terdeteksi, commit berhasil, atau watcher berhenti. Tekan `Ctrl+C` untuk menghentikannya. Watcher tidak melakukan push; push dilakukan secara manual.

File yang berubah sebelum watcher dimulai tidak otomatis di-commit. Ubah file tersebut setelah watcher aktif, atau buat commit manual. Folder `bin/`, `obj/`, dan `.vs/` dikecualikan dari Git.

Pesan commit menggunakan format Conventional Commits. Watcher menandai penambahan file sebagai `feat` dan perubahan lainnya sebagai `chore`, lalu menyertakan path file pada ringkasan. Karena watcher menentukan jenis dari status file, bukan memahami maksud perubahan, periksa pesannya jika jenis yang lebih spesifik seperti `fix`, `refactor`, atau `docs` diperlukan.

## Alur Git

```powershell
git status
git log --oneline
git push
```

Periksa commit lokal dengan `git log --oneline`. Jalankan `git push` hanya saat siap mengirim commit ke remote.
