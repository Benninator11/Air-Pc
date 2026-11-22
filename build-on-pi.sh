#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/source"
DIST_DIR="$SOURCE_DIR/dist/linux-arm64-unpacked"

if [[ "$(uname -m)" != "aarch64" && "$(uname -m)" != "arm64" ]]; then
  echo "Dieses Build-Skript ist für Raspberry Pi OS 64-bit (ARM64) vorgesehen." >&2
  echo "Erkannte Architektur: $(uname -m)" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "Node.js und npm fehlen. Installiere zuerst eine aktuelle Node.js-LTS-Version." >&2
  exit 1
fi

if [[ ! -f "$SOURCE_DIR/package.json" ]]; then
  echo "Quellcode nicht gefunden: $SOURCE_DIR/package.json" >&2
  exit 1
fi

echo "[1/4] Installiere npm-Abhängigkeiten ..."
cd "$SOURCE_DIR"
npm install

echo "[2/4] Erstelle das Linux-ARM64-Electron-Paket ..."
npm run pack -- --linux --arm64

if [[ ! -x "$DIST_DIR/pi-air-pc-control" ]]; then
  echo "Build-Ausgabe nicht gefunden: $DIST_DIR/pi-air-pc-control" >&2
  echo "Prüfe die electron-builder-Ausgabe unter $SOURCE_DIR/dist." >&2
  exit 1
fi

echo "[3/4] Übernehme das gebaute Programm nach release/ ..."
rm -rf "$ROOT_DIR/release"
mkdir -p "$ROOT_DIR/release"
cp -a "$DIST_DIR/." "$ROOT_DIR/release/"

echo "[4/4] Installiere Pi Air PC Control ..."
chmod +x "$ROOT_DIR/install.sh" "$ROOT_DIR/launch.sh"
"$ROOT_DIR/install.sh"

echo
echo "Fertig. Pi Air PC Control wurde gebaut und installiert."
