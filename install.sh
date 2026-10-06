#!/bin/sh
# WaveCom TV a terminálban (iptv-tui) — telepítő macOS-re és Linuxra (Raspberry Pi is).
#
#   curl -fsSL https://raw.githubusercontent.com/Wavecom-hu/iptv-tui/main/install.sh | sh
#
# Változók: IPTV_TUI_DIR (célmappa, alapból ~/.local/bin), IPTV_TUI_VERSION (pl. v1.0.3, alapból a legújabb)
set -eu

REPO="Wavecom-hu/iptv-tui"
DIR="${IPTV_TUI_DIR:-$HOME/.local/bin}"
VERSION="${IPTV_TUI_VERSION:-latest}"

say() { printf '%s\n' "$*"; }
die() { printf 'Hiba: %s\n' "$*" >&2; exit 1; }

os=$(uname -s)
case "$os" in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) die "ezt a rendszert ($os) a telepítő nem ismeri; Windowson: irm https://raw.githubusercontent.com/$REPO/main/install.ps1 | iex" ;;
esac

arch=$(uname -m)
case "$arch" in
  x86_64|amd64) arch=amd64 ;;
  arm64|aarch64) arch=arm64 ;;
  armv7l|armv7*) arch=armv7 ;;
  armv6l|armv6*) arch=armv6 ;;
  *) die "ismeretlen processzor: $arch" ;;
esac
[ "$os" = darwin ] && case "$arch" in armv*) die "ismeretlen processzor: $arch" ;; esac

name="iptv-tui_${os}_${arch}"
if [ "$VERSION" = latest ]; then
  url="https://github.com/$REPO/releases/latest/download/$name.tar.gz"
else
  url="https://github.com/$REPO/releases/download/$VERSION/$name.tar.gz"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
say "Letöltés: $url"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$url" -o "$tmp/a.tgz" || die "a letöltés nem sikerült"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$tmp/a.tgz" "$url" || die "a letöltés nem sikerült"
else
  die "curl vagy wget kell"
fi
tar -xzf "$tmp/a.tgz" -C "$tmp"

mkdir -p "$DIR"
install -m 0755 "$tmp/$name/iptv-tui" "$DIR/iptv-tui" 2>/dev/null || { cp "$tmp/$name/iptv-tui" "$DIR/iptv-tui"; chmod 0755 "$DIR/iptv-tui"; }
[ "$os" = darwin ] && xattr -d com.apple.quarantine "$DIR/iptv-tui" 2>/dev/null || true

say ""
say "Kész: $DIR/iptv-tui ($("$DIR/iptv-tui" --version 2>/dev/null || echo telepítve))"

case ":$PATH:" in
  *":$DIR:"*) ;;
  *)
    case "${SHELL:-}" in
      *zsh) rc="$HOME/.zshrc" ;;
      *bash) rc="$HOME/.bashrc" ;;
      *) rc="$HOME/.profile" ;;
    esac
    # egyszer beírjuk a shell beállítófájljába (ha még nincs benne); kikapcsolás: IPTV_TUI_NO_PATH=1
    line="export PATH=\"$DIR:\$PATH\""
    if [ -z "${IPTV_TUI_NO_PATH:-}" ] && ! grep -qsF "$DIR" "$rc"; then
      printf '
# iptv-tui
%s
' "$line" >> "$rc"
      say "A $DIR a PATH-ba került ($rc). Nyiss új terminálablakot, vagy futtasd:  . $rc"
    else
      say "Figyelem: a $DIR nincs a PATH-ban. Add hozzá:  echo '$line' >> $rc"
    fi
    ;;
esac

# macOS-en Homebrew nélkül is: a hordozható mpv.app a felhasználó mappájába (rendszergazda nélkül).
# Kikapcsolás: IPTV_TUI_NO_MPV=1
MPVDIR="$HOME/.local/share/iptv-tui"
if [ "$os" = darwin ] && ! command -v mpv >/dev/null 2>&1 && [ ! -x "$MPVDIR/mpv.app/Contents/MacOS/mpv" ]    && [ ! -x /Applications/mpv.app/Contents/MacOS/mpv ] && [ -z "${IPTV_TUI_NO_MPV:-}" ]; then
  if [ "$arch" = arm64 ]; then murl="https://laboratory.stolendata.net/~djinn/mpv_osx/mpv-arm64-latest.tar.gz"
  else murl="https://laboratory.stolendata.net/~djinn/mpv_osx/mpv-latest.tar.gz"; fi
  say ""
  say "Az mpv lejátszó nincs telepítve; letöltöm ide: $MPVDIR (Homebrew nem kell)"
  mkdir -p "$tmp/mpv" "$MPVDIR"
  if curl -fsSL "$murl" -o "$tmp/mpv.tgz" && tar -xzf "$tmp/mpv.tgz" -C "$tmp/mpv"; then
    app=$(find "$tmp/mpv" -maxdepth 3 -name mpv.app -type d | head -1)
    if [ -n "$app" ]; then
      rm -rf "$MPVDIR/mpv.app" && cp -R "$app" "$MPVDIR/mpv.app"
      ln -sf "$MPVDIR/mpv.app/Contents/MacOS/mpv" "$DIR/mpv"
      say "mpv kész: $("$MPVDIR/mpv.app/Contents/MacOS/mpv" --version 2>/dev/null | head -1)"
    fi
  else
    say "Az mpv letöltése nem sikerült; később: brew install mpv"
  fi
fi

if ! command -v mpv >/dev/null 2>&1 && [ ! -x "$MPVDIR/mpv.app/Contents/MacOS/mpv" ] && [ ! -x /Applications/mpv.app/Contents/MacOS/mpv ]; then
  say ""
  say "A lejátszáshoz az mpv is kell:"
  if [ "$os" = darwin ]; then
    say "  brew install mpv"
  elif [ -f /etc/debian_version ]; then
    say "  sudo apt install mpv        (Debian, Ubuntu, Raspberry Pi OS)"
  elif [ -f /etc/fedora-release ]; then
    say "  sudo dnf install mpv"
  elif [ -f /etc/arch-release ]; then
    say "  sudo pacman -S mpv"
  else
    say "  telepítsd a csomagkezelőddel (mpv)"
  fi
fi

say ""
say "Indítás:        iptv-tui"
say "Fiók nélkül:    iptv-tui --demo"
say "Mit tud a gép:  iptv-tui --doctor"
