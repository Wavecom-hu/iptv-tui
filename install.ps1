# WaveCom TV a terminálban (iptv-tui) — telepítő Windowsra.
#
#   irm https://raw.githubusercontent.com/Wavecom-hu/iptv-tui/main/install.ps1 | iex
#
# A %LOCALAPPDATA%\Programs\iptv-tui mappába telepít, és a felhasználói PATH-ba veszi
# (rendszergazdai jog nem kell). Ha nincs mpv, felajánlja a winget-es telepítését.

$ErrorActionPreference = 'Stop'
$repo = 'Wavecom-hu/iptv-tui'
$dir = Join-Path $env:LOCALAPPDATA 'Programs\iptv-tui'

$arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') { 'arm64' } else { 'amd64' }
$name = "iptv-tui_windows_$arch.zip"
$url = "https://github.com/$repo/releases/latest/download/$name"

Write-Host "Letöltés: $url"
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("iptv-tui-" + [Guid]::NewGuid())
New-Item -ItemType Directory -Force $tmp | Out-Null
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile (Join-Path $tmp $name)
    New-Item -ItemType Directory -Force $dir | Out-Null
    Expand-Archive -Force (Join-Path $tmp $name) $dir
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

$exe = Join-Path $dir 'iptv-tui.exe'
Unblock-File $exe -ErrorAction SilentlyContinue

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not ($userPath -split ';' | Where-Object { $_ -eq $dir })) {
    [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $dir), 'User')
    $env:Path += ";$dir"
    Write-Host "A PATH-hoz adva: $dir (az új terminálablakokban már látszik)"
}

Write-Host ""
Write-Host ("Kész: " + (& $exe --version))

$hasMpv = (Get-Command mpv -ErrorAction SilentlyContinue) -or (Test-Path "$env:LOCALAPPDATA\Microsoft\WinGet\Links\mpv.exe")
if (-not $hasMpv) {
    Write-Host ""
    Write-Host "A lejátszáshoz az mpv is kell."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $ans = 'n'
        try { $ans = Read-Host "Telepítsem most a wingettel? (i/n)" } catch { }
        if ($ans -match '^(i|y)') {
            winget install -e --id shinchiro.mpv --accept-source-agreements --accept-package-agreements
        } else {
            Write-Host "Később:  winget install shinchiro.mpv   (vagy: scoop install mpv)"
        }
    } else {
        Write-Host "Telepítés:  scoop install mpv   vagy  https://mpv.io/installation/"
    }
}

Write-Host ""
Write-Host "Indítás (Windows Terminalban):  iptv-tui"
Write-Host "Fiók nélkül:                    iptv-tui --demo"
Write-Host "Mit tud a gép:                  iptv-tui --doctor"
