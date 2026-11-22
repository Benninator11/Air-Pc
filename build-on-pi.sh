#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/source"
DIST_DIR="$SOURCE_DIR/dist/linux-arm64-unpacked"
SOURCE_ARCHIVE="$ROOT_DIR/source-code-v1.0.8.tar.xz"

if [[ "$(uname -m)" != "aarch64" && "$(uname -m)" != "arm64" ]]; then
  echo "Dieses Build-Skript ist für Raspberry Pi OS 64-bit (ARM64) vorgesehen." >&2
  echo "Erkannte Architektur: $(uname -m)" >&2
  exit 1
fi

if [[ ! -f "$SOURCE_DIR/package.json" ]]; then
  if [[ -f "$SOURCE_ARCHIVE" ]]; then
    echo "[1/5] Entpacke den Quellcode ..."
    tar -xJf "$SOURCE_ARCHIVE" -C "$ROOT_DIR"
  else
    echo "Quellcode-Archiv fehlt: $SOURCE_ARCHIVE" >&2
    exit 1
  fi
fi

for required in "$ROOT_DIR/backend/server.py" "$ROOT_DIR/backend/requirements.txt" "$ROOT_DIR/assets/icon.png" "$ROOT_DIR/install.sh" "$ROOT_DIR/launch.sh"; do
  if [[ ! -f "$required" ]]; then
    echo "Erforderliche Projektdatei fehlt: $required" >&2
    echo "Bitte source-code-v1.0.8.tar.xz vollständig entpacken." >&2
    exit 1
  fi
done

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "Node.js und npm fehlen. Installiere zuerst Node.js und npm." >&2
  exit 1
fi

echo "[2/5] Installiere npm-Abhängigkeiten ..."
cd "$SOURCE_DIR"
npm install

echo "[3/5] Erstelle das Linux-ARM64-Electron-Paket ..."
npm run pack -- --linux --arm64

if [[ ! -x "$DIST_DIR/pi-air-pc-control" ]]; then
  echo "Build-Ausgabe nicht gefunden: $DIST_DIR/pi-air-pc-control" >&2
  echo "Prüfe die electron-builder-Ausgabe unter $SOURCE_DIR/dist." >&2
  exit 1
fi

echo "[4/5] Übernehme das Programm nach release/ ..."
rm -rf "$ROOT_DIR/release"
mkdir -p "$ROOT_DIR/release"
cp -a "$DIST_DIR/." "$ROOT_DIR/release/"

echo "[5/5] Installiere Pi Air PC Control ..."
chmod +x "$ROOT_DIR/install.sh" "$ROOT_DIR/launch.sh"
"$ROOT_DIR/install.sh"

echo
echo "Fertig. Pi Air PC Control wurde gebaut und installiert."
