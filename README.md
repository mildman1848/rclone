# rclone Docker Image

> 📖 **[Deutsche Version](README.DE.md)** | 🇬🇧 **English Version**

![Build Status](https://github.com/mildman1848/rclone/workflows/CI/badge.svg)
![Security Scan](https://github.com/mildman1848/rclone/workflows/Security%20Scan/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/mildman1848/rclone)
![Docker Image Size](https://img.shields.io/docker/image-size/mildman1848/rclone/latest)
![License](https://img.shields.io/github/license/mildman1848/rclone)
![Version](https://img.shields.io/badge/version-1.73.2-blue)

🐳 **[Docker Hub: mildman1848/rclone](https://hub.docker.com/r/mildman1848/rclone)**

A production-ready Docker image for [rclone](https://rclone.org/) based on the LinuxServer.io Alpine baseimage with enhanced security features, automatic secret management, full LinuxServer.io compliance, and CI/CD integration. rclone is a command-line program to manage files on cloud storage.

## 🚀 Features

- ✅ **LinuxServer.io Alpine Baseimage 3.22** - Optimized and secure
- ✅ **S6 Overlay v3** - Professional process management
- ✅ **Full LinuxServer.io Compliance** - FILE__ secrets, Docker Mods, custom scripts
- ✅ **Enhanced Security Hardening** - Non-root execution, capability dropping, secure permissions
- ✅ **OCI Manifest Lists** - True multi-architecture support following OCI standard
- ✅ **LinuxServer.io Pipeline** - Architecture-specific tags + manifest lists
- ✅ **Multi-Platform Support** - AMD64, ARM64 with native performance
- ✅ **Advanced Health Checks** - Automatic monitoring with failover
- ✅ **Robust Secret Management** - 512-bit JWT, 256-bit API keys, secure rotation
- ✅ **Automated Build System** - Make + GitHub Actions CI/CD with manifest validation
- ✅ **Environment Validation** - Comprehensive configuration checks
- ✅ **Security Scanning** - Integrated vulnerability scans with Trivy + CodeQL
- ✅ **OCI Compliance** - Standard-compliant container labels and manifest structure

## 🚀 Quick Start

### Automated Setup (Recommended)

```bash
# Clone repository
git clone https://github.com/mildman1848/rclone.git
cd rclone

# Complete setup (environment + secrets)
make setup

# Start container
docker-compose up -d
```

### With Docker Compose (Manual)

```bash
# Clone repository
git clone https://github.com/mildman1848/rclone.git
cd rclone

# Configure environment
cp .env.example .env
# Adjust .env as needed

# Generate secure secrets
make secrets-generate

# Start container (docker-compose.override.yml provides security hardening)
docker-compose up -d
```

### With Docker Run

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
# Show help
make help

# Complete setup
make setup                   # Initial setup (env + secrets)
make env-setup               # Create environment from .env.example
make env-validate            # Validate environment

# Secret Management (Enhanced)
make secrets-generate        # Generate secure secrets (512-bit JWT, 256-bit API)
make secrets-rotate          # Rotate secrets (with backup)
make secrets-clean           # Clean up old secret backups
make secrets-info            # Show secret status

# Build & Test (Enhanced with OCI Manifest Lists)
make build                   # Build image for current platform
make build-multiarch         # Multi-architecture build (legacy)
make build-manifest          # LinuxServer.io style manifest lists (recommended)
make inspect-manifest        # Inspect manifest lists (multi-arch details)
make validate-manifest       # Validate OCI manifest compliance
make test                    # Test container (with health checks)
make security-scan           # Run comprehensive security scan (Trivy + CodeQL)
make trivy-scan              # Run Trivy vulnerability scan only
make codeql-scan             # Run CodeQL static code analysis
make validate                # Validate Dockerfile

# Container Management
make start                   # Start container
make stop                    # Stop container
make restart                 # Restart container
make status                  # Show container status and health
make logs                    # Show container logs
make shell                   # Open shell in container

# Development
make dev                     # Start development container

# Release
make release                 # Complete release workflow
make push                    # Push image to registry
```

### Manual Build

```bash
# Build image
docker build -t mildman1848/rclone:latest .

# With specific arguments
docker build \
  --build-arg RCLONE_VERSION=v1.73.2 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  -t mildman1848/rclone:latest .
```

### Production Deployment

```bash
# Use production configuration with enhanced security
docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d

# Or use the override file for automatic security hardening
docker-compose up -d  # Automatically applies docker-compose.override.yml
```

## ⚙️ Configuration

### Environment File

Configuration is done via a `.env` file containing all environment variables:

```bash
# Create .env from template
cp .env.example .env

# Adjust values as needed
nano .env
```

The `.env.example` contains all available options with documentation and links to the official rclone documentation.

### Important Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `Europe/Berlin` | Timezone |
| `PORT` | `5572` | Internal container port (rclone Web GUI) |
| `EXTERNAL_PORT` | `5572` | External host port (rclone Web GUI) |
| `CONFIG_PATH` | `/config` | Configuration path in container |
| `DATA_PATH` | `/data` | Data path in container |
| `LOG_LEVEL` | `info` | Log level (debug, info, warn, error) |
| `RCLONE_MODE` | `rcd` | rclone operation mode (rcd/serve) |
| `RCLONE_CONFIG` | `/config/rclone/rclone.conf` | rclone configuration file |
| `RCLONE_LOG_LEVEL` | `INFO` | rclone log level (DEBUG, INFO, NOTICE, ERROR) |

> 📖 **Full Documentation:** See [.env.example](.env.example) for all available options

### 🔐 Enhanced LinuxServer.io Secrets Management

**FILE__ Prefix (Recommended):**
The image supports the LinuxServer.io standard `FILE__` prefix for secure secret management:

```bash
# .env file - FILE__ prefix secrets for rclone
FILE__RCLONE_CONFIG_PASS=/run/secrets/rclone_config_pass
FILE__RCLONE_WEB_GUI_PASSWORD=/run/secrets/rclone_web_pass
FILE__RCLONE_PASSWORD=/run/secrets/rclone_password

# Docker Compose example
environment:
  - FILE__RCLONE_CONFIG_PASS=/run/secrets/rclone_config_pass
  - FILE__RCLONE_WEB_GUI_PASSWORD=/run/secrets/rclone_web_pass
```

**Enhanced Secret Generation:**

```bash
# Secure secret generation (improved algorithms)
make secrets-generate        # 512-bit JWT, 256-bit API keys

# Secret rotation with backup
make secrets-rotate

# Check secret status
make secrets-info
```

**Supported Secrets (rclone-specific):**

| FILE__ Variable | Description | Security | Make Generated |
|----------------|-------------|----------|----------------|
| `FILE__RCLONE_CONFIG_PASS` | rclone config encryption password | ✅ High | ✅ |
| `FILE__RCLONE_WEB_GUI_PASSWORD` | rclone Web GUI password | ✅ High | ✅ |
| `FILE__RCLONE_PASSWORD` | rclone authentication password | ✅ High | ✅ |
| `FILE__SESSION_SECRET` | Session secret (256-bit) | ✅ High | ✅ |
| `FILE__BACKUP_KEY` | Backup encryption key | ✅ High | ✅ |

> 📖 **LinuxServer.io Documentation:** [FILE__ Prefix](https://docs.linuxserver.io/FAQ)

### Volumes

| Container Path | Description |
|----------------|-------------|
| `/config` | rclone configuration files, cache, and logs |
| `/data` | Cloud storage mount points and data |

### rclone Operation Modes

The container supports two primary operation modes:

#### 1. rcd Mode (Default) - Remote Control Daemon with Web GUI
- **Port:** 5572 (official rclone Web GUI port)
- **Features:** Full Web-based management interface
- **Access:** http://localhost:5572
- **Configuration:** `RCLONE_MODE=rcd`

#### 2. serve Mode - File Server
- **Port:** Configurable (default 5572)
- **Features:** File serving with optional Web GUI
- **Protocols:** http, webdav, ftp, sftp
- **Configuration:** `RCLONE_MODE=serve`

```bash
# rcd mode (Web GUI) - Default
RCLONE_MODE=rcd

# serve mode (File Server)
RCLONE_MODE=serve
RCLONE_SERVE_PROTOCOL=http  # or webdav, ftp, sftp
```

## 🔧 Enhanced LinuxServer.io S6 Overlay Services

The image uses S6 Overlay v3 with optimized services following LinuxServer.io standards:

- **init-branding** - Custom Mildman1848 ASCII art branding
- **init-mods-package-install** - Docker Mods installation
- **init-custom-files** - Custom scripts & UMASK setup
- **init-secrets** - Enhanced FILE__ prefix & legacy secret processing
- **init-rclone-config** - rclone configuration with validation
- **rclone** - Main application with correct parameter passing

### Service Dependencies (Fixed)

```
init-branding → init-mods-package-install → init-custom-files → init-secrets → init-rclone-config → rclone
```

### Service Improvements
- ✅ **Secure Permissions** - Fallback methods for chmod issues
- ✅ **Enhanced Validation** - JSON config validation
- ✅ **Robust Error Handling** - Graceful fallbacks on errors
- ✅ **Security Hardening** - Path validation for FILE__ secrets

### LinuxServer.io Features

**Docker Mods Support:**
```bash
# Single mod
DOCKER_MODS=linuxserver/mods:universal-cron

# Multiple mods (separated by |)
DOCKER_MODS=linuxserver/mods:universal-cron|linuxserver/mods:rclone-custom
```

**Custom Scripts:**
```bash
# Scripts in /custom-cont-init.d are executed before services
docker run -v ./my-scripts:/custom-cont-init.d:ro mildman1848/rclone
```

**UMASK Support:**
```bash
# Default: 022 (files: 644, directories: 755)
UMASK=022
```

> 📖 **Available Mods:** [mods.linuxserver.io](https://mods.linuxserver.io/)

## 🔒 Enhanced Security

> 🛡️ **Security Policy**: See our [Security Policy](SECURITY.md) for reporting vulnerabilities and security guidelines

### Advanced Security Hardening

The image implements comprehensive security measures:

- ✅ **Non-root Execution** - Container runs as user `abc` (UID 911)
- ✅ **Capability Dropping** - ALL capabilities dropped, minimal required added
- ✅ **no-new-privileges** - Prevents privilege escalation
- ✅ **Secure File Permissions** - 750 for directories, 640 for files
- ✅ **Path Validation** - FILE__ secret path sanitization
- ✅ **Enhanced Error Handling** - Secure fallbacks for permission issues
- ✅ **tmpfs Mounts** - Temporary files in memory
- ✅ **Security Opt** - Additional kernel security features
- ✅ **Robust Secret Handling** - 512-bit encryption, secure rotation

### Security Scanning & Vulnerability Management

**Latest Security Improvements (September 2025):**
- ✅ **68% Vulnerability Reduction** - From 28 to 9 vulnerabilities through comprehensive npm package updates
- ✅ **CodeQL Integration** - Static code analysis for JavaScript/TypeScript
- ✅ **Enhanced npm Security** - Updated 16+ vulnerable packages (axios, express, cookie, etc.)
- ✅ **Automated Scanning** - GitHub Actions integration for continuous security monitoring

```bash
# Comprehensive security scan (Trivy + CodeQL)
make security-scan

# Individual scanning tools
make trivy-scan              # Vulnerability scanning only
make codeql-scan             # Static code analysis only
make security-scan-detailed  # Detailed scan with exports

# Manual scanning
trivy image mildman1848/rclone:latest
trivy fs --format sarif --output trivy-results.sarif .

# Dockerfile validation
make validate
```

### Docker Security Best Practices

**Implemented Security Features:**
- ✅ **docker-compose.override.yml** - Automatic security hardening
- ✅ **docker-compose.production.yml** - Production-ready configuration
- ✅ **seccomp-profile.json** - Custom syscall filtering
- ✅ **Capability dropping** - Minimal required privileges
- ✅ **Non-root execution** - User `abc` (UID 911)
- ✅ **Resource limits** - CPU, memory, and PID constraints
- ✅ **Network isolation** - Custom bridge networks
- ✅ **tmpfs mounts** - Temporary files in memory
- ✅ **Read-only filesystems** where applicable

```bash
# 1. Use LinuxServer.io FILE__ secrets for rclone
FILE__RCLONE_CONFIG_PASS=/run/secrets/rclone_config_pass
FILE__RCLONE_WEB_GUI_PASSWORD=/run/secrets/rclone_web_pass
FILE__RCLONE_PASSWORD=/run/secrets/rclone_password

# 2. Set host user IDs (LinuxServer.io standard)
export PUID=$(id -u)
export PGID=$(id -g)

# 3. Use restrictive UMASK for production
export UMASK=027  # More secure than default 022

# 4. Secure secret generation
make secrets-generate

# 5. Validate configuration
make env-validate

# 6. Use specific image tags
docker run mildman1848/rclone:v1.73.2  # instead of :latest

# 7. Monitor container health
make status  # Container status and health checks

# 8. Production deployment with maximum security
docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d

# 9. Development with automatic security hardening
docker-compose up -d  # Uses docker-compose.override.yml automatically

# 10. Use custom seccomp profile for syscall filtering
# Automatically applied in docker-compose.production.yml
```

### OCI Manifest Lists & LinuxServer.io Pipeline

**OCI-compliant Multi-Architecture Support:**

```bash
# Automatic platform detection (Docker pulls the right image)
docker pull mildman1848/rclone:latest

# Platform-specific tags (LinuxServer.io style)
docker pull mildman1848/rclone:amd64-latest    # Intel/AMD 64-bit
docker pull mildman1848/rclone:arm64-latest    # ARM 64-bit (Apple M1, Pi 4)

# Inspect manifest lists
make inspect-manifest
docker manifest inspect mildman1848/rclone:latest
```

**Technical Details:**
- ✅ **OCI Image Manifest Specification v1.1.0** compliant
- ✅ **LinuxServer.io Pipeline Standards** - Architecture tags + manifest lists
- ✅ **Native Performance** - No emulation, real platform builds
- ✅ **Automatic Platform Selection** - Docker chooses optimal image
- ✅ **Backward Compatibility** - Works with all Docker clients

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

### LinuxServer.io Compatibility

```bash
# Fully compatible with LinuxServer.io standards
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

The container shows a **custom ASCII-art branding** for "Mildman1848" at startup:

```
███╗   ███╗██╗██╗     ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗ ██╗ █████╗ ██╗  ██╗ █████╗
████╗ ████║██║██║     ██╔══██╗████╗ ████║██╔══██╗████╗  ██║███║██╔══██╗██║  ██║██╔══██╗
██╔████╔██║██║██║     ██║  ██║██╔████╔██║███████║██╔██╗ ██║╚██║╚█████╔╝███████║╚█████╔╝
██║╚██╔╝██║██║██║     ██║  ██║██║╚██╔╝██║██╔══██║██║╚██╗██║ ██║██╔══██╗╚════██║██╔══██╗
██║ ╚═╝ ██║██║███████╗██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║ ██║╚█████╔╝     ██║╚█████╔╝
╚═╝     ╚═╝╚═╝╚══════╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═╝ ╚════╝      ╚═╝ ╚════╝
```

**Branding Features:**
- ✅ **LinuxServer.io Compliance** - Correct branding implementation
- ✅ **Custom ASCII Art** - Unique Mildman1848 representation
- ✅ **Version Information** - Build details and rclone version
- ✅ **Support Links** - Clear references for help and documentation
- ✅ **Feature Overview** - Overview of implemented LinuxServer.io features

> ⚠️ **Note:** This container is **NOT** officially supported by LinuxServer.io

## Monitoring & Health Checks

### Health Check

The image includes automatic health checks:

```bash
# Check status
docker inspect --format='{{.State.Health.Status}}' rclone

# Show logs
docker logs rclone
```

### rclone Monitoring

**Built-in Monitoring:**
- Health checks via process validation
- Container status monitoring
- Log aggregation

**rclone Web GUI (rcd mode):**
- Real-time transfer monitoring
- Configuration management
- File browser interface

**Prometheus Metrics (Optional):**
rclone can export Prometheus metrics when configured with `--rc-enable-metrics`. See [rclone documentation](https://rclone.org/rc/#prometheus-metrics) for details.

```bash
# Enable Prometheus metrics
RCLONE_RC_ENABLE_METRICS=true
# Access metrics at http://localhost:5572/metrics
```

## 📁 Configuration Files

| File | Purpose | Usage |
|------|---------|-------|
| `docker-compose.yml` | Base configuration | Standard deployment |
| `docker-compose.override.yml` | Security hardening | Automatically applied |
| `docker-compose.production.yml` | Production config | `docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d` |
| `seccomp-profile.json` | Syscall filtering | Enhanced security (production) |
| `.env.example` | Environment template | Copy to `.env` and customize |

## 🔧 Troubleshooting

### Common Issues

<details>
<summary><strong>File Permissions</strong></summary>

```bash
# Adjust PUID/PGID to host user
export PUID=$(id -u)
export PGID=$(id -g)
docker-compose up -d

# Or set in .env
echo "PUID=$(id -u)" >> .env
echo "PGID=$(id -g)" >> .env
```
</details>

<details>
<summary><strong>Port Already in Use</strong></summary>

```bash
# Change port in .env
echo "EXTERNAL_PORT=13379" >> .env

# Or directly in docker-compose.yml
ports:
  - "13379:5572"
```
</details>

<details>
<summary><strong>Container Won't Start</strong></summary>

```bash
# 1. Check logs
make logs

# 2. Health check status
docker inspect --format='{{.State.Health.Status}}' rclone

# 3. Validate environment
make env-validate

# 4. Debug shell
make shell
```
</details>

<details>
<summary><strong>Secrets Not Found</strong></summary>

```bash
# Use LinuxServer.io FILE__ secrets
echo "FILE__JWT_SECRET=/run/secrets/jwt_secret" >> .env

# Generate legacy secrets
make secrets-generate

# Check secret status
make secrets-info

# Manual FILE__ secret creation
mkdir -p secrets
openssl rand -base64 64 > secrets/jwt_secret.txt
echo "FILE__JWT_SECRET=$(pwd)/secrets/jwt_secret.txt" >> .env
```
</details>

### Debug Mode

```bash
# Development container with debug logging
echo "LOG_LEVEL=debug" >> .env
echo "DEBUG_MODE=true" >> .env
echo "VERBOSE_LOGGING=true" >> .env
make dev

# Shell access
make shell

# Container inspection
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
   - Create a feature branch
   - Test all changes
   - Create a pull request

> 🛡️ **Security Issues**: Please read our [Security Policy](SECURITY.md) before reporting security vulnerabilities

### CI/CD Pipeline

The project uses GitHub Actions for:
- ✅ **Automated Testing** - Dockerfile, container, integration tests
- ✅ **Security Scanning** - Trivy, Hadolint, SBOM generation
- ✅ **OCI Manifest Lists** - LinuxServer.io pipeline with architecture-specific tags
- ✅ **Multi-Architecture Builds** - AMD64, ARM64 with native performance
- ✅ **Manifest Validation** - OCI compliance and platform verification
- ✅ **Automated Releases** - Semantic versioning, Docker Hub/GHCR
- ✅ **Dependency Updates** - Dependabot integration
- ✅ **Upstream Monitoring** - Automated dependency tracking and update notifications

### 🔄 Upstream Dependency Monitoring

The project includes automated monitoring of upstream dependencies:

- **rclone Application**: Monitors [rclone/rclone](https://github.com/rclone/rclone) releases
- **LinuxServer.io Base Image**: Tracks [linuxserver/docker-baseimage-alpine](https://github.com/linuxserver/docker-baseimage-alpine) updates
- **Automated Notifications**: Creates GitHub issues for new releases
- **Security Assessment**: Prioritizes security-related updates
- **Semi-Automated**: rclone updates via PR, base image updates require manual review

**Monitoring Schedule**: Monday and Thursday at 6 AM UTC

### 🔧 Setup Requirements

**For GHCR (GitHub Container Registry) support:**
- Create a Personal Access Token with `write:packages` and `read:packages` scopes
- Add as repository secret: `GHCR_TOKEN`
- Path: Repository Settings → Secrets and variables → Actions → New repository secret

**All other workflows work without additional setup.**

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

- [rclone](https://github.com/rclone/rclone) - Original project
- [LinuxServer.io](https://www.linuxserver.io/) - Baseimage and best practices
- [S6 Overlay](https://github.com/just-containers/s6-overlay) - Process management
