# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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