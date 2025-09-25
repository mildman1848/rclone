# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.71.1-4] - 2025-09-25

### 🛠️ CI/CD Standardization & Modernization
- **Docker Compose Plugin**: Migrated from legacy docker-compose to modern docker compose plugin
- **Hadolint Standardization**: Added consistent ignore directives (DL3007,DL3018,DL3013)
- **Workflow Consistency**: Aligned CI patterns with audiobookshelf and tandoor projects
- **GitHub Actions Enhancement**: Improved workflow reliability and eliminated legacy dependencies

### 📋 Pre-Push Guidelines Compliance
- **Command Modernization**: Updated docker-compose references to docker compose throughout CI
- **Enhanced Documentation**: Updated CLAUDE.md with workflow standardization details

## [1.71.1-3] - 2025-09-25

### 🔧 Build & Infrastructure Updates
- **Baseimage Testing**: Added comprehensive baseimage update testing system with Make targets
- **Infrastructure**: Confirmed all baseimages and upstream versions are current (no updates needed)

### 📝 File Management
- **gitignore**: Added baseimage testing files (BASEIMAGE_UPDATE_REPORT.md, baseimage-test-*.log, baseimage-test-*.json)
- **Security**: Enhanced ignored patterns for security scan results and testing artifacts

### 🛠️ Make Command Extensions
- `make baseimage-check`: Check for LinuxServer.io baseimage updates
- `make baseimage-test`: Test new LinuxServer.io baseimage version
- `make baseimage-update`: Update to latest LinuxServer.io baseimage

### ✅ Validation Status
- **Upstream Version**: v1.71.1 confirmed as current (no update needed)
- **Base Image**: 3.22-02acf855-ls10 confirmed as latest
- **CI/CD Pipeline**: All workflows passing successfully

## [1.71.1-2] - 2025-09-24

### 🚀 Version Update & Management
- **rclone Update**: Upgraded from 1.71.0 to 1.71.1 (latest upstream release)
- **Version Validation**: Added mandatory upstream version checking with GitHub API
- **Build Integration**: version-check target enforced before builds
- **Synchronization**: Maintained alignment with upstream rclone/rclone releases

### 📚 Documentation Organization
- **docs/ Structure**: Moved LINUXSERVER.md files from root to docs/ directory
- **Standards Compliance**: Aligned with workspace documentation standards
- **Consistency**: Maintained bilingual documentation (English/German)

### 🔒 Security Validation
- **Clean Scan**: Zero vulnerabilities detected in comprehensive security assessment
- **Alpine Base**: LinuxServer.io Alpine 3.22.1 security validated
- **Go Binary**: rclone binary security verified
- **Production Ready**: Security posture optimized

### 📝 File Management Standardization (2025-09-23)

#### .gitignore and .dockerignore Updates
- **Standardized Exclusions**: Updated .gitignore and .dockerignore to follow workspace-wide patterns
- **Directory Structure**: Added standardized config/, data/, logs/, security/, security-reports/ exclusions
- **CLAUDE.md Policy**: Kept CLAUDE.md in repository for documentation (commented in ignore files)
- **Application-specific Directories**: Organized rclone-specific runtime directories (rclone-cache/, rclone-logs/)
- **Security Patterns**: Enhanced security-related file exclusions across all ignore files
- **Runtime Volume Optimization**: Optimized Docker build context by excluding runtime volumes

### 🏗️ Project Structure Standardization (2025-09-23)

#### Directory Structure Standardization
- **Security Directory**: Moved `seccomp-profile.json` to standardized `security/` directory
- **Updated References**: Updated docker-compose.production.yml to reference `./security/seccomp-profile.json`
- **Path Consistency**: Ensured all security-related files follow workspace template standards
- **Cross-Project Alignment**: Synchronized directory structure with audiobookshelf and tandoor projects

#### Security Enhancements
- **seccomp Profile Location**: Standardized seccomp profile location in `security/` directory
- **Production Configuration**: Enhanced docker-compose.production.yml security configuration references
- **Template Compliance**: Ensured all security configurations follow LinuxServer.io template standards

#### Documentation Updates
- **Configuration Updates**: Updated all references to security files in documentation
- **Template Alignment**: Ensured configuration files match workspace template standards
- **Cross-Project Consistency**: Maintained identical patterns across all workspace projects

## [1.71.0-initial] - 2025-09-22

### 🎉 Initial Release
- **rclone Integration**: Complete adaptation from Audiobookshelf to rclone cloud storage management
- **Web GUI Support**: Integrated rclone Web GUI on official port 5572
- **Multi-Mode Operation**: Support for both rcd (Web GUI) and serve (file server) modes
- **LinuxServer.io Compliance**: Full LinuxServer.io baseimage integration with S6 Overlay v3
- **Security Features**: Comprehensive container hardening and FILE__ secrets support
- **Multi-Architecture**: Native AMD64 and ARM64 builds with OCI manifest lists
- **Production Ready**: Complete production deployment configuration with security hardening