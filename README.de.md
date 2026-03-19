# rclone Docker Image

> 🇩🇪 **Deutsche Version** | 📖 **[English Version](README.md)**

![Build Status](https://github.com/mildman1848/rclone/workflows/CI/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/mildman1848/rclone)
![Docker Image Size](https://img.shields.io/docker/image-size/mildman1848/rclone/latest)
![License](https://img.shields.io/github/license/mildman1848/rclone)
![Version](https://img.shields.io/badge/version-1.73.2-blue)

🐳 **[Docker Hub: mildman1848/rclone](https://hub.docker.com/r/mildman1848/rclone)**

Ein production-ready Docker-Image für [rclone](https://rclone.org/) basierend auf dem LinuxServer.io Alpine Baseimage mit erweiterten Security-Features, automatischer Secret-Verwaltung, vollständiger LinuxServer.io Compliance und CI/CD-Integration. rclone ist ein Kommandozeilen-Programm zur Verwaltung von Dateien auf Cloud-Speichern.

## 🚀 Features

- ✅ **LinuxServer.io Alpine Baseimage 3.22** - Optimiert und sicher
- ✅ **S6 Overlay v3** - Professionelles Process Management
- ✅ **Vollständige LinuxServer.io Compliance** - FILE__ Secrets, Docker Mods, Custom Scripts
- ✅ **Enhanced Security Hardening** - Non-root execution, capability dropping, secure permissions
- ✅ **OCI Manifest Lists** - Echte Multi-Architecture Unterstützung nach OCI Standard
- ✅ **LinuxServer.io Pipeline** - Architecture-specific Tags + Manifest Lists
- ✅ **Multi-Platform Support** - AMD64, ARM64 mit nativer Performance
- ✅ **Advanced Health Checks** - Automatische Überwachung mit Failover
- ✅ **Robust Secret Management** - 512-bit JWT, 256-bit API Keys, sichere Rotation
- ✅ **Automated Build System** - Make + GitHub Actions CI/CD mit Manifest Validation
- ✅ **Environment Validation** - Umfassende Konfigurationsprüfung
- ✅ **Security Scanning** - Integrierte Vulnerability-Scans mit Trivy + CodeQL
- ✅ **OCI Compliance** - Standard-konforme Container Labels und Manifest Structure

## 🚀 Quick Start

### Automatisiertes Setup (Empfohlen)

```bash
# Repository klonen
git clone https://github.com/mildman1848/rclone.git
cd rclone

# Komplettes Setup (Environment + Secrets)
make setup

# Container starten
docker-compose up -d
```

### Mit Docker Compose (Manuell)

```bash
# Repository klonen
git clone https://github.com/mildman1848/rclone.git
cd rclone

# Environment konfigurieren
cp .env.example .env
# .env nach Bedarf anpassen

# Sichere Secrets generieren
make secrets-generate

# Container starten (docker-compose.override.yml bietet Security-Hardening)
docker-compose up -d
```

### Mit Docker Run

```bash
docker run -d \
  --name rclone \
  -p 5572:5572 \
  -v /path/to/config:/config \
  -v /path/to/data:/data \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Berlin \
  --restart unless-stopped \
  mildman1848/rclone:latest
```

## 🛠️ Build & Development

### Makefile Targets

```bash
# Hilfe anzeigen
make help

# Komplettes Setup
make setup                   # Initial setup (env + secrets)
make env-setup               # Environment aus .env.example erstellen
make env-validate            # Environment validieren

# Secret Management (Enhanced)
make secrets-generate        # Sichere Secrets generieren (512-bit JWT, 256-bit API)
make secrets-rotate          # Secrets rotieren (mit Backup)
make secrets-clean           # Alte Secret-Backups aufräumen
make secrets-info            # Secret-Status anzeigen

# Build & Test (Enhanced with OCI Manifest Lists)
make build                   # Image für aktuelle Plattform bauen
make build-multiarch         # Multi-Architecture Build (Legacy)
make build-manifest          # LinuxServer.io style Manifest Lists (Empfohlen)
make inspect-manifest        # Manifest Lists inspizieren (Multi-Arch Details)
make validate-manifest       # OCI Manifest Compliance validieren
make test                    # Container testen (mit Health Checks)
make security-scan           # Umfassender Security-Scan (Trivy + CodeQL)
make trivy-scan              # Nur Trivy Vulnerability-Scan
make codeql-scan             # CodeQL Static Code Analysis
make validate                # Dockerfile validieren

# Container Management
make start                   # Container starten
make stop                    # Container stoppen
make restart                 # Container neustarten
make status                  # Container Status und Health anzeigen
make logs                    # Container-Logs anzeigen
make shell                   # Shell in Container öffnen

# Development
make dev                     # Development Container starten

# Release
make release                 # Vollständiger Release-Workflow
make push                    # Image zu Registry pushen
```

### Manuelle Build

```bash
# Image bauen
docker build -t mildman1848/rclone:latest .

# Mit spezifischen Argumenten
docker build \
  --build-arg RCLONE_VERSION=v1.73.2 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  -t mildman1848/rclone:latest .
```

## ⚙️ Konfiguration

### Environment-Datei

Die Konfiguration erfolgt über eine `.env`-Datei, die alle Umgebungsvariablen enthält:

```bash
# Erstelle .env aus Template
cp .env.example .env

# Passe Werte nach Bedarf an
nano .env
```

Die `.env.example` enthält alle verfügbaren Optionen mit Dokumentation und Links zur offiziellen rclone-Dokumentation.

### Wichtige Umgebungsvariablen

| Variable | Standard | Beschreibung |
|----------|----------|--------------|
| `PUID` | `1000` | User ID für Dateiberechtigungen |
| `PGID` | `1000` | Group ID für Dateiberechtigungen |
| `TZ` | `Europe/Berlin` | Zeitzone |
| `PORT` | `5572` | Interner Container-Port (rclone Web GUI) |
| `EXTERNAL_PORT` | `5572` | Externer Host-Port (rclone Web GUI) |
| `CONFIG_PATH` | `/config` | Konfigurationspfad im Container |
| `DATA_PATH` | `/data` | Daten-Pfad im Container |
| `LOG_LEVEL` | `info` | Log-Level (debug, info, warn, error) |
| `RCLONE_MODE` | `rcd` | rclone Betriebsmodus (rcd/serve) |
| `RCLONE_CONFIG` | `/config/rclone/rclone.conf` | rclone Konfigurationsdatei |
| `RCLONE_LOG_LEVEL` | `INFO` | rclone Log-Level (DEBUG, INFO, NOTICE, ERROR) |

> 📖 **Vollständige Dokumentation:** Siehe [.env.example](.env.example) für alle verfügbaren Optionen

### 🔐 Enhanced LinuxServer.io Secrets Management

**FILE__ Prefix (Empfohlen):**
Das Image unterstützt den LinuxServer.io Standard `FILE__` Prefix für sichere Secret-Verwaltung:

```bash
# .env Datei - FILE__ Prefix Secrets für rclone
FILE__RCLONE_CONFIG_PASS=/run/secrets/rclone_config_pass
FILE__RCLONE_WEB_GUI_PASSWORD=/run/secrets/rclone_web_pass
FILE__RCLONE_PASSWORD=/run/secrets/rclone_password

# Docker Compose Beispiel
environment:
  - FILE__RCLONE_CONFIG_PASS=/run/secrets/rclone_config_pass
  - FILE__RCLONE_WEB_GUI_PASSWORD=/run/secrets/rclone_web_pass
```

**Enhanced Secret-Generierung:**

```bash
# Sichere Secret-Generierung (verbesserte Algorithmen)
make secrets-generate        # 512-bit JWT, 256-bit API Keys

# Secret-Rotation mit Backup
make secrets-rotate

# Secret-Status prüfen
make secrets-info
```

**Unterstützte Secrets (Enhanced):**

| FILE__ Variable | Beschreibung | Sicherheit | Make generiert |
|----------------|--------------|------------|----------------|
| `FILE__RCLONE_CONFIG_PASS` | rclone Konfigurations-Verschlüsselungspasswort | ✅ High | ✅ |
| `FILE__RCLONE_WEB_GUI_PASSWORD` | rclone Web GUI Passwort | ✅ High | ✅ |
| `FILE__RCLONE_PASSWORD` | rclone Authentifizierungspasswort | ✅ High | ✅ |
| `FILE__SESSION_SECRET` | Session Secret (256-bit) | ✅ High | ✅ |
| `FILE__BACKUP_KEY` | Backup-Verschlüsselungsschlüssel | ✅ High | ✅ |

> 📖 **LinuxServer.io Dokumentation:** [FILE__ Prefix](https://docs.linuxserver.io/FAQ)

### Volumes

| Container Pfad | Beschreibung |
|----------------|--------------|
| `/config` | rclone Konfigurationsdateien, Cache und Logs |
| `/data` | Cloud-Speicher Mount-Points und Daten |

### rclone Betriebsmodi

Der Container unterstützt zwei primäre Betriebsmodi:

#### 1. rcd Modus (Standard) - Remote Control Daemon mit Web GUI
- **Port:** 5572 (offizieller rclone Web GUI Port)
- **Features:** Vollständige Web-basierte Verwaltungsschnittstelle
- **Zugriff:** http://localhost:5572
- **Konfiguration:** `RCLONE_MODE=rcd`

#### 2. serve Modus - Datei-Server
- **Port:** Konfigurierbar (Standard 5572)
- **Features:** Datei-Serving mit optionaler Web GUI
- **Protokolle:** http, webdav, ftp, sftp
- **Konfiguration:** `RCLONE_MODE=serve`

```bash
# rcd Modus (Web GUI) - Standard
RCLONE_MODE=rcd

# serve Modus (Datei-Server)
RCLONE_MODE=serve
RCLONE_SERVE_PROTOCOL=http  # oder webdav, ftp, sftp
```

## 🔧 Enhanced LinuxServer.io S6 Overlay Services

Das Image verwendet S6 Overlay v3 mit optimierten Services im LinuxServer.io Standard:

- **init-branding** - Custom Mildman1848 ASCII Art Branding
- **init-mods-package-install** - Docker Mods Installation
- **init-custom-files** - Custom Scripts & UMASK Setup
- **init-secrets** - Enhanced FILE__ Prefix & Legacy Secret Processing
- **init-rclone-config** - rclone Konfiguration mit Validation
- **rclone** - Hauptanwendung mit korrekter Parameter-Übergabe

### Service Dependencies (Fixed)

```
init-branding → init-mods-package-install → init-custom-files → init-secrets → init-rclone-config → rclone
```

### Service Improvements
- ✅ **Sichere Permissions** - Fallback-Methoden für chmod-Probleme
- ✅ **Enhanced Validation** - JSON-Config Validation
- ✅ **Robust Error Handling** - Graceful Fallbacks bei Fehlern
- ✅ **Security Hardening** - Path Validation für FILE__ Secrets

### LinuxServer.io Features

**Docker Mods Support:**
```bash
# Einzelne Mod
DOCKER_MODS=linuxserver/mods:universal-cron

# Multiple Mods (mit | getrennt)
DOCKER_MODS=linuxserver/mods:universal-cron|linuxserver/mods:rclone-custom
```

**Custom Scripts:**
```bash
# Scripts in /custom-cont-init.d werden vor Services ausgeführt
docker run -v ./my-scripts:/custom-cont-init.d:ro mildman1848/rclone
```

**UMASK Support:**
```bash
# Standard: 022 (files: 644, directories: 755)
UMASK=022
```

> 📖 **Mods verfügbar:** [mods.linuxserver.io](https://mods.linuxserver.io/)

## 🔒 Enhanced Security

> 🛡️ **Security Policy**: Siehe unsere [Sicherheitsrichtlinie](SECURITY.de.md) für die Meldung von Sicherheitslücken und Sicherheitsleitlinien

### Advanced Security Hardening

Das Image implementiert umfassende Security-Maßnahmen:

- ✅ **Non-root Execution** - Container läuft als User `abc` (UID 911)
- ✅ **Capability Dropping** - ALL capabilities dropped, minimale Required hinzugefügt
- ✅ **no-new-privileges** - Verhindert Privilege Escalation
- ✅ **Secure File Permissions** - 750 für Directories, 640 für Files
- ✅ **Path Validation** - FILE__ Secret Path Sanitization
- ✅ **Enhanced Error Handling** - Sichere Fallbacks bei Permission-Problemen
- ✅ **tmpfs Mounts** - Temporary files in Memory
- ✅ **Security Opt** - Zusätzliche Kernel-Security-Features
- ✅ **Robust Secret Handling** - 512-bit Encryption, sichere Rotation

### Security Scanning & Vulnerability Management

**Neueste Sicherheitsverbesserungen (September 2025):**
- ✅ **68% Vulnerability-Reduktion** - Von 28 auf 9 Vulnerabilities durch umfassende npm Package-Updates
- ✅ **CodeQL Integration** - Static Code Analysis für JavaScript/TypeScript
- ✅ **Enhanced npm Security** - 16+ vulnerable Packages aktualisiert (axios, express, cookie, etc.)
- ✅ **Automatisierte Scans** - GitHub Actions Integration für kontinuierliche Security-Überwachung

```bash
# Umfassender Security-Scan (Trivy + CodeQL)
make security-scan

# Individuelle Scanning-Tools
make trivy-scan              # Nur Vulnerability-Scanning
make codeql-scan             # Nur Static Code Analysis
make security-scan-detailed  # Detaillierter Scan mit Exports

# Manuelle Scans
trivy image mildman1848/rclone:latest
trivy fs --format sarif --output trivy-results.sarif .

# Dockerfile Validation
make validate
```

### Docker Security Best Practices

**Implementierte Sicherheitsfeatures:**
- ✅ **docker-compose.override.yml** - Automatische Sicherheitshärtung
- ✅ **docker-compose.production.yml** - Produktionsbereite Konfiguration
- ✅ **seccomp-profile.json** - Benutzerdefinierte Syscall-Filterung
- ✅ **Capability Dropping** - Minimale erforderliche Berechtigungen
- ✅ **Non-root Execution** - User `abc` (UID 911)
- ✅ **Ressourcenbegrenzungen** - CPU, Memory und PID Constraints
- ✅ **Netzwerk-Isolation** - Benutzerdefinierte Bridge-Netzwerke
- ✅ **tmpfs Mounts** - Temporäre Dateien im Speicher
- ✅ **Read-only Filesystems** wo anwendbar

```bash
# 1. LinuxServer.io FILE__ Secrets für rclone verwenden
FILE__RCLONE_CONFIG_PASS=/run/secrets/rclone_config_pass
FILE__RCLONE_WEB_GUI_PASSWORD=/run/secrets/rclone_web_pass
FILE__RCLONE_PASSWORD=/run/secrets/rclone_password

# 2. Host-User-IDs setzen (LinuxServer.io Standard)
export PUID=$(id -u)
export PGID=$(id -g)

# 3. Restriktive UMASK für Produktion verwenden
export UMASK=027  # Sicherer als Standard 022

# 4. Sichere Secret-Generierung
make secrets-generate

# 5. Konfiguration validieren
make env-validate

# 6. Spezifische Image-Tags verwenden
docker run mildman1848/rclone:v1.73.2  # statt :latest

# 7. Container Health überwachen
make status  # Container Status und Health Checks

# 8. Produktionsdeployment mit maximaler Sicherheit
docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d

# 9. Development mit automatischer Sicherheitshärtung
docker-compose up -d  # Verwendet docker-compose.override.yml automatisch

# 10. Benutzerdefiniertes Seccomp-Profil für Syscall-Filterung
# Automatisch angewendet in docker-compose.production.yml
```

### OCI Manifest Lists & LinuxServer.io Pipeline

**OCI-konforme Multi-Architecture Unterstützung:**

```bash
# Automatische Platform-Detection (Docker zieht das richtige Image)
docker pull mildman1848/rclone:latest

# Platform-spezifische Tags (LinuxServer.io Style)
docker pull mildman1848/rclone:amd64-latest    # Intel/AMD 64-bit
docker pull mildman1848/rclone:arm64-latest    # ARM 64-bit (Apple M1, Pi 4)

# Manifest List inspizieren
make inspect-manifest
docker manifest inspect mildman1848/rclone:latest
```

**Technische Details:**
- ✅ **OCI Image Manifest Specification v1.1.0** konform
- ✅ **LinuxServer.io Pipeline Standards** - Architecture Tags + Manifest Lists
- ✅ **Native Performance** - Keine Emulation, echte Platform-Builds
- ✅ **Automatische Platform Selection** - Docker wählt das optimale Image
- ✅ **Backward Compatibility** - Funktioniert mit allen Docker Clients

**Manifest Structure:**
```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
  "manifests": [
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "platform": { "architecture": "amd64", "os": "linux" }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "platform": { "architecture": "arm64", "os": "linux" }
    }
  ]
}
```

### LinuxServer.io Kompatibilität

```bash
# Vollständig kompatibel mit LinuxServer.io Standards
# ✅ S6 Overlay v3
# ✅ FILE__ Prefix Secrets
# ✅ DOCKER_MODS Support
# ✅ Custom Scripts (/custom-cont-init.d)
# ✅ UMASK Support
# ✅ PUID/PGID Management
# ✅ Custom Branding (LinuxServer.io compliant)
# ✅ OCI Manifest Lists (2024 Pipeline Standard)
```

### 🎨 Container Branding

Das Container zeigt beim Start ein **custom ASCII-Art Branding** für "Mildman1848":

```
███╗   ███╗██╗██╗     ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗ ██╗ █████╗ ██╗  ██╗ █████╗
████╗ ████║██║██║     ██╔══██╗████╗ ████║██╔══██╗████╗  ██║███║██╔══██╗██║  ██║██╔══██╗
██╔████╔██║██║██║     ██║  ██║██╔████╔██║███████║██╔██╗ ██║╚██║╚█████╔╝███████║╚█████╔╝
██║╚██╔╝██║██║██║     ██║  ██║██║╚██╔╝██║██╔══██║██║╚██╗██║ ██║██╔══██╗╚════██║██╔══██╗
██║ ╚═╝ ██║██║███████╗██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║ ██║╚█████╔╝     ██║╚█████╔╝
╚═╝     ╚═╝╚═╝╚══════╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═╝ ╚════╝      ╚═╝ ╚════╝
```

**Features des Brandings:**
- ✅ **LinuxServer.io Compliance** - Korrekte Branding-Implementation
- ✅ **Custom ASCII Art** - Einzigartige Mildman1848 Darstellung
- ✅ **Version Information** - Build-Details und rclone Version
- ✅ **Support Links** - Klare Verweise für Hilfe und Dokumentation
- ✅ **Feature Overview** - Übersicht der implementierten LinuxServer.io Features

> ⚠️ **Hinweis:** Dieses Container ist **NICHT** offiziell von LinuxServer.io unterstützt

## Monitoring & Health Checks

### Health Check

Das Image inkludiert automatische Health Checks:

```bash
# Status prüfen
docker inspect --format='{{.State.Health.Status}}' rclone

# Logs anzeigen
docker logs rclone
```

### rclone Monitoring

**Eingebaute Überwachung:**
- Health Checks via Prozessvalidierung
- Container-Status-Überwachung
- Log-Aggregation

**rclone Web GUI (rcd Modus):**
- Echtzeit-Transfer-Überwachung
- Konfigurationsverwaltung
- Datei-Browser-Interface

**Prometheus Metrics (Optional):**
rclone kann Prometheus-Metriken exportieren, wenn mit `--rc-enable-metrics` konfiguriert. Siehe [rclone Dokumentation](https://rclone.org/rc/#prometheus-metrics) für Details.

```bash
# Prometheus Metriken aktivieren
RCLONE_RC_ENABLE_METRICS=true
# Metriken unter http://localhost:5572/metrics abrufen
```

## 📁 Konfigurationsdateien

| Datei | Zweck | Verwendung |
|-------|-------|------------|
| `docker-compose.yml` | Basis-Konfiguration | Standard-Deployment |
| `docker-compose.override.yml` | Sicherheitshärtung | Automatisch angewendet |
| `docker-compose.production.yml` | Produktions-Konfiguration | `docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d` |
| `seccomp-profile.json` | Syscall-Filterung | Erweiterte Sicherheit (Produktion) |
| `.env.example` | Environment-Template | Nach `.env` kopieren und anpassen |

## 🔧 Troubleshooting

### Häufige Probleme

<details>
<summary><strong>Dateiberechtigungen</strong></summary>

```bash
# PUID/PGID an Host-User anpassen
export PUID=$(id -u)
export PGID=$(id -g)
docker-compose up -d

# Oder in .env setzen
echo "PUID=$(id -u)" >> .env
echo "PGID=$(id -g)" >> .env
```
</details>

<details>
<summary><strong>Port bereits belegt</strong></summary>

```bash
# Port in .env ändern
echo "EXTERNAL_PORT=13379" >> .env

# Oder direkt in docker-compose.yml
ports:
  - "13379:5572"
```
</details>

<details>
<summary><strong>Container startet nicht</strong></summary>

```bash
# 1. Logs prüfen
make logs

# 2. Health Check Status
docker inspect --format='{{.State.Health.Status}}' rclone

# 3. Environment validieren
make env-validate

# 4. Debug Shell
make shell
```
</details>

<details>
<summary><strong>Secrets nicht gefunden</strong></summary>

```bash
# LinuxServer.io FILE__ Secrets verwenden
echo "FILE__JWT_SECRET=/run/secrets/jwt_secret" >> .env

# Legacy Secrets generieren
make secrets-generate

# Secret Status prüfen
make secrets-info

# Manual FILE__ Secret Creation
mkdir -p secrets
openssl rand -base64 64 > secrets/jwt_secret.txt
echo "FILE__JWT_SECRET=$(pwd)/secrets/jwt_secret.txt" >> .env
```
</details>

### Debug Mode

```bash
# Development Container mit Debug-Logging
echo "LOG_LEVEL=debug" >> .env
echo "DEBUG_MODE=true" >> .env
echo "VERBOSE_LOGGING=true" >> .env
make dev

# Shell Access
make shell

# Container Inspection
docker exec -it rclone /bin/bash
```

## 🤝 Contributing

### Development Workflow

1. **Fork & Clone**
   ```bash
   git clone https://github.com/yourusername/rclone.git
   cd rclone
   ```

2. **Setup Development Environment**
   ```bash
   make setup
   make dev
   ```

3. **Make Changes & Test**
   ```bash
   make validate      # Dockerfile linting
   make build         # Build image
   make test          # Run tests
   make security-scan # Security check
   ```

4. **Submit PR**
   - Erstelle einen Feature Branch
   - Teste alle Änderungen
   - Erstelle einen Pull Request

> 🛡️ **Sicherheitsprobleme**: Bitte lesen Sie unsere [Sicherheitsrichtlinie](SECURITY.de.md) bevor Sie Sicherheitslücken melden

### CI/CD Pipeline

Das Projekt verwendet GitHub Actions für:
- ✅ **Automated Testing** - Dockerfile, Container, Integration Tests
- ✅ **Security Scanning** - Trivy, Hadolint, SBOM Generation
- ✅ **OCI Manifest Lists** - LinuxServer.io Pipeline mit Architecture-specific Tags
- ✅ **Multi-Architecture Builds** - AMD64, ARM64 mit nativer Performance
- ✅ **Manifest Validation** - OCI Compliance und Platform Verification
- ✅ **Automated Releases** - Semantic Versioning, Docker Hub/GHCR
- ✅ **Dependency Updates** - Dependabot Integration
- ✅ **Upstream Monitoring** - Automatische Abhängigkeitsverfolgung und Update-Benachrichtigungen

### 🔄 Upstream Dependency Monitoring

Das Projekt beinhaltet automatische Überwachung von Upstream-Abhängigkeiten:

- **rclone Application**: Überwacht [rclone/rclone](https://github.com/rclone/rclone) Releases
- **LinuxServer.io Base Image**: Verfolgt [linuxserver/docker-baseimage-alpine](https://github.com/linuxserver/docker-baseimage-alpine) Updates
- **Automatische Benachrichtigungen**: Erstellt GitHub Issues für neue Releases
- **Security Assessment**: Priorisiert sicherheitsrelevante Updates
- **Semi-Automatisiert**: rclone Updates via PR, Base Image Updates erfordern manuelle Überprüfung

**Überwachungszeiten**: Montag und Donnerstag um 6 Uhr UTC

### 🔧 Setup-Anforderungen

**Für GHCR (GitHub Container Registry) Unterstützung:**
- Erstelle einen Personal Access Token mit `write:packages` und `read:packages` Berechtigungen
- Füge als Repository Secret hinzu: `GHCR_TOKEN`
- Pfad: Repository Settings → Secrets and variables → Actions → New repository secret

**Alle anderen Workflows funktionieren ohne zusätzliches Setup.**

## License

Dieses Projekt steht unter der MIT License. Siehe [LICENSE](LICENSE) für Details.

## Acknowledgments

- [rclone](https://github.com/rclone/rclone) - Original Projekt
- [LinuxServer.io](https://www.linuxserver.io/) - Baseimage und Best Practices
- [S6 Overlay](https://github.com/just-containers/s6-overlay) - Process Management
