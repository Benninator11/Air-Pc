# Pi Air PC Control

**Pi Air PC Control** ist eine lokale Desktop-App für den Raspberry Pi 5. Sie verbindet eine Electron-Oberfläche mit einem lokalen Python-/Flask-Backend und OpenRouter, damit ein KI-Modell den Desktop-Kontext auswerten und – nach Bestätigung – lokale Aktionen ausführen kann.

> **Aktueller Stand:** Version **1.0.8**. Die Version wurde auf einem Raspberry Pi 5 mit Raspberry Pi OS 64-bit getestet; der Projektinhaber hat bestätigt, dass die App jetzt funktioniert.

## Funktionen

- Chat mit OpenRouter-Modellen; Modellliste wird über die OpenRouter-API geladen.
- Voreinstellung: `nvidia/nemotron-3.5-super-vl:free`.
- Bildschirmaufnahme für Desktop-Kontext: Wayland über `grim`, X11 über `scrot`, zusätzlicher Fallback über `mss`.
- Animierter Partikel-/Lichteffekt während die KI nachdenkt.
- Lokales Python-/Flask-Backend mit zufälligem Sitzungstoken.
- Aktionsbestätigung als Standard; der autonome Modus bleibt gesperrt.
- Installationsskript erstellt einen Desktop-Starter und einen Menüeintrag.
- Deutsche Oberfläche und Aktivitätsprotokoll.

## Zielsystem

- Raspberry Pi 5
- Raspberry Pi OS 64-bit (ARM64 / `aarch64`)
- Desktop-Sitzung unter Wayland oder X11
- Node.js und npm zum Erstellen aus dem Quellcode
- Internetverbindung für OpenRouter sowie die Paketinstallation

## Installation aus dem Quellcode auf dem Pi

Repository herunterladen:

```bash
git clone https://github.com/Benninator11/Air-Pc.git
cd Air-Pc
```

Quellcode bauen und installieren:

```bash
chmod +x build-on-pi.sh install.sh
./build-on-pi.sh
```

Das Build-Skript installiert die npm-Abhängigkeiten, erstellt das ARM64-Electron-Paket und übergibt es an `install.sh`. Das Installationsskript installiert die Python-/Desktop-Abhängigkeiten, richtet die App unter `~/.local/opt/pi-air-pc-control` ein und erstellt den Desktop-Starter.

Anschließend lässt sich **Pi Air PC Control** über das Desktop-Symbol oder das Anwendungsmenü öffnen.

### Nur den bereits gebauten Ordner installieren

Wenn bereits ein passender Ordner `release/` mit dem Electron-Programm vorhanden ist, kann direkt installiert werden:

```bash
chmod +x install.sh
./install.sh
```

## Einrichtung

1. App starten.
2. OpenRouter-API-Key in den Einstellungen eintragen und speichern.
3. Ein verfügbares Modell auswählen.
4. Eine Nachricht senden.

Der API-Key wird lokal in `~/.config/pi-air-pc-control/settings.json` gespeichert. Die Datei ist auf Benutzerzugriff beschränkt (Berechtigung `0600`), aber **nicht zusätzlich verschlüsselt**. Den Key niemals in Issues, Screenshots oder Commits veröffentlichen.

## Bildschirmaufnahme

- **Wayland:** `grim`
- **X11:** `scrot`
- **Fallback:** `mss`

Die Desktop-Aufnahme hängt von der aktiven grafischen Sitzung und deren Berechtigungen ab. Schwarze/leere Bilder sollen als Fehler erkannt und nicht als gültiger Bildschirmkontext weitergegeben werden.

## Sicherheitshinweise

- Der Bestätigungsmodus ist der empfohlene Standard: prüfe jede Aktion, bevor sie ausgeführt wird.
- Gib das Root-Passwort nur ein, wenn eine konkrete Aktion es benötigt. Es soll nicht dauerhaft gespeichert werden.
- Die lokale API verwendet ein Sitzungstoken; sie ist für die lokale App gedacht und sollte nicht ins Netzwerk freigegeben werden.
- KI-generierte Shell-Befehle vor der Ausführung prüfen. Ein Bestätigungsdialog ersetzt keine eigene Prüfung.
- Der OpenRouter-Key wird lokal gespeichert und ist nicht verschlüsselt.

## Projektstruktur

```text
Air-Pc/
├── backend/                 # Flask-Backend für OpenRouter, Desktop und Aktionen
├── source/
│   ├── assets/              # App-Icon
│   ├── backend/             # Backend-Quellkopie
│   └── src/
│       ├── main/             # Electron Main/Preload
│       └── renderer/         # HTML, CSS und Chat-Oberfläche
├── build-on-pi.sh            # ARM64-Build und Installation
├── install.sh                # Systemabhängigkeiten + Desktop-Starter
└── launch.sh                 # Startet die installierte App mit dem venv-Python
```

Das große vorkompilierte Electron-Laufzeitprogramm wird nicht im Git-Quellbaum abgelegt: Die ARM64-Hauptdatei ist größer als GitHubs Größenlimit von 100 MiB pro Datei. `build-on-pi.sh` erzeugt diese Datei lokal aus dem enthaltenen Quellcode.

## Versionshinweise

### 1.0.8
- Python-Abhängigkeiten `requests`, Flask und `flask-cors` zusätzlich über Debian-Pakete installieren.
- Virtuelle Umgebung bei Updates frisch erstellen.
- Pflicht-Imports mit exakt dem Interpreter prüfen, den Electron verwendet.
- Desktop-Starter prüft vor dem Start die Python-Umgebung.
- Einstellungen und lokal gespeicherter OpenRouter-Key bleiben bei Updates erhalten.

Weitere Änderungen sind in den Dateien `CHANGELOG_1.0.*.txt` dokumentiert.

## Lizenz

MIT – siehe [LICENSE](LICENSE).
