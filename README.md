# WaveCom TV a terminálban

Élő TV, műsorújság, visszanézés és időeltolás egy terminálablakban, WaveCom-előfizetéssel.
Windows Terminalban, macOS-en, Linuxon, Raspberry Pi-n, és SSH-n át bárhonnan.

```
▶ 73 MAX4  07:25–09:10 George Gently VII./2.  ━━━━━━━━────────  ● ÉLŐ  07:54
```

Fiók nélkül is kipróbálható: `iptv-tui --demo`.

## Telepítés

A lejátszáshoz az **mpv** is kell. A telepítők szólnak, ha hiányzik.

### Windows

PowerShellben (Windows Terminal ajánlott):

```powershell
irm https://raw.githubusercontent.com/Wavecom-hu/iptv-tui/main/install.ps1 | iex
```

Scooppal:

```powershell
scoop bucket add wavecom https://github.com/Wavecom-hu/iptv-tui
scoop bucket add extras
scoop install wavecom/iptv-tui extras/mpv
```

### macOS

Homebrew-val (az mpv-t is felteszi):

```sh
brew install wavecom-hu/tap/iptv-tui
```

Telepítő-szkripttel:

```sh
curl -fsSL https://raw.githubusercontent.com/Wavecom-hu/iptv-tui/main/install.sh | sh
brew install mpv
```

### Linux és Raspberry Pi

```sh
curl -fsSL https://raw.githubusercontent.com/Wavecom-hu/iptv-tui/main/install.sh | sh
sudo apt install mpv
```

A telepítő felismeri a processzort (x64, ARM64, Raspberry Pi armv7/armv6), és a `~/.local/bin`
mappába telepít. Homebrew Linuxon is működik (x64 és ARM64).

### Kézzel

A [legújabb kiadásból](https://github.com/Wavecom-hu/iptv-tui/releases/latest) töltsd le a gépednek
megfelelő fájlt, csomagold ki, és indítsd el az `iptv-tui` (Windowson `iptv-tui.exe`) programot.

| Rendszer | Fájl |
|---|---|
| Windows 10/11 x64 | `iptv-tui_windows_amd64.zip` |
| Windows ARM | `iptv-tui_windows_arm64.zip` |
| macOS Apple Silicon (M1–M4) | `iptv-tui_darwin_arm64.tar.gz` |
| macOS Intel | `iptv-tui_darwin_amd64.tar.gz` |
| Linux x64 | `iptv-tui_linux_amd64.tar.gz` |
| Linux ARM64, Raspberry Pi 4/5 (64 bit) | `iptv-tui_linux_arm64.tar.gz` |
| Raspberry Pi 2/3/4 (32 bit) | `iptv-tui_linux_armv7.tar.gz` |
| Raspberry Pi Zero / 1 | `iptv-tui_linux_armv6.tar.gz` |

A macOS-es program az Apple-nél regisztrált fejlesztői tanúsítvánnyal aláírt és notarizált
(Developer ID: Wavecom Kft.), így a Gatekeeper kézzel letöltve sem tiltja le.

## Használat

```sh
iptv-tui            # belépés telefonnal (QR-kód, wavecom.tv/kod) vagy e-maillel
iptv-tui --demo     # kipróbálás fiók nélkül
iptv-tui --doctor   # mit tud a terminál és az mpv
```

| Gomb | Mit csinál |
|---|---|
| ↑ ↓ | csatornaváltás lejátszás közben |
| ← → | visszatekerés / előre (élőben időeltolás) |
| Enter | lejátszás a listából |
| `e` | a műsor elejétől |
| `l` | vissza az élő adásba |
| `i` | műsorinfó |
| `v` | külön ablakos videó ↔ kép a terminálban |
| `h` | súgó |
| `q` | vissza / kilépés |

A kép alapból színes karakterekből áll, így SSH-n át is működik. Ahol a terminál tudja, kitty-
vagy sixel-grafikára válthatsz. Helyben a `v` gombbal igazi, külön ablakos videóra is; közben
a terminálban használható marad a menü.

## English

WaveCom TV for the terminal: live TV, programme guide, catch-up and timeshift for WaveCom IPTV
subscribers, on Windows, macOS, Linux and Raspberry Pi, also over SSH. Install with the
commands above (`install.ps1`, `install.sh`, Scoop, or `brew install wavecom-hu/tap/iptv-tui`).
Requires mpv. Try it without an account: `iptv-tui --demo`.

Ügyfélszolgálat: **1236** · [wavecom.hu](https://wavecom.hu)
