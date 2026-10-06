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
  *) say "Figyelem: a $DIR nincs a PATH-ban. Add hozzá, pl.:  echo 'export PATH=\"$DIR:\$PATH\"' >> ~/.profile" ;;
esac

if ! command -v mpv >/dev/null 2>&1; then
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
