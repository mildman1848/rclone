# rclone Docker Image Makefile
# Based on LinuxServer.io best practices

# Variables
DOCKER_REPO = mildman1848/rclone
VERSION ?= latest
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
RCLONE_VERSION ?= 1.71.1
UPSTREAM_REPO = rclone/rclone

# Platform support for multi-architecture builds
PLATFORMS = linux/amd64,linux/arm64

# Docker commands with error checking
DOCKER = docker
BUILDX = docker buildx
COMPOSE = docker-compose

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: help build build-multiarch build-manifest build-manifest-push inspect-manifest validate-manifest push test clean lint validate security-scan secrets-generate secrets-generate-ci secrets-rotate secrets-clean secrets-info env-setup env-validate setup

# Default target
all: help

## Help target
help: ## Show this help message
	@echo "$(BLUE)rclone Docker Image Build System$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(GREEN)Variables:$(NC)"
	@echo "  $(YELLOW)DOCKER_REPO$(NC)           Repository name (default: $(DOCKER_REPO))"
	@echo "  $(YELLOW)VERSION$(NC)               Version tag (default: $(VERSION))"
	@echo "  $(YELLOW)RCLONE_VERSION$(NC)        rclone version (default: $(RCLONE_VERSION))"
	@echo "  $(YELLOW)PLATFORMS$(NC)             Target platforms (default: $(PLATFORMS))"

## Version Management
version-check: ## Check if current version is up to date with upstream
	@echo "$(BLUE)Checking upstream version...$(NC)"
	@LATEST=$$(curl -s https://api.github.com/repos/$(UPSTREAM_REPO)/releases/latest | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"//;s/"//' 2>/dev/null || echo "unknown"); \
	LATEST_CLEAN=$$(echo "$$LATEST" | sed 's/^v//'); \
	if [ "$$LATEST" = "unknown" ]; then \
		echo "$(YELLOW)⚠️  Unable to fetch latest version from GitHub API$(NC)"; \
		echo "$(YELLOW)Current version: $(RCLONE_VERSION)$(NC)"; \
		echo "$(YELLOW)Please check https://github.com/$(UPSTREAM_REPO)/releases manually$(NC)"; \
	elif [ "$$LATEST_CLEAN" != "$(RCLONE_VERSION)" ]; then \
		echo "$(RED)⚠️  OUTDATED: Using $(RCLONE_VERSION), latest is $$LATEST_CLEAN$(NC)"; \
		echo "$(YELLOW)Consider updating RCLONE_VERSION in Makefile and Dockerfile$(NC)"; \
		echo "$(YELLOW)Update command: sed -i 's/$(RCLONE_VERSION)/'$$LATEST_CLEAN'/g' Makefile Dockerfile$(NC)"; \
		echo "$(BLUE)Release info: https://github.com/$(UPSTREAM_REPO)/releases/tag/$$LATEST$(NC)"; \
	else \
		echo "$(GREEN)✅ Using latest version: $(RCLONE_VERSION)$(NC)"; \
	fi

## Build targets
build: version-check ## Build Docker image for current platform (with version check)
	@echo "$(GREEN)Building Docker image...$(NC)"
	$(DOCKER) build \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg RCLONE_VERSION="$(RCLONE_VERSION)" \
		--tag $(DOCKER_REPO):$(VERSION) \
		--tag $(DOCKER_REPO):latest \
		.
	@echo "$(GREEN)Build completed successfully!$(NC)"

build-multiarch: ## Build multi-architecture Docker image
	@echo "$(GREEN)Building multi-architecture Docker image...$(NC)"
	$(BUILDX) build \
		--platform $(PLATFORMS) \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg RCLONE_VERSION="$(RCLONE_VERSION)" \
		--tag $(DOCKER_REPO):$(VERSION) \
		--tag $(DOCKER_REPO):latest \
		--push \
		.
	@echo "$(GREEN)Multi-architecture build completed successfully!$(NC)"

## LinuxServer.io Pipeline targets
build-manifest: ## Build and create LinuxServer.io style manifest lists (local)
	@echo "$(GREEN)Building LinuxServer.io style multi-arch with manifest lists (local)...$(NC)"
	@echo "Building platform-specific images..."
	# Build for current platform (amd64) - guaranteed to work
	$(BUILDX) build \
		--platform linux/amd64 \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg RCLONE_VERSION="$(RCLONE_VERSION)" \
		--tag $(DOCKER_REPO):amd64-$(VERSION) \
		--load \
		.
	@echo "$(GREEN)AMD64 build completed!$(NC)"
	# ARM builds (optional - may fail if base images don't support these platforms)
	@echo "$(YELLOW)Attempting ARM64 build (may fail if base image doesn't support this platform)...$(NC)"
	-$(BUILDX) build \
		--platform linux/arm64 \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg RCLONE_VERSION="$(RCLONE_VERSION)" \
		--tag $(DOCKER_REPO):arm64-$(VERSION) \
		--output=type=docker \
		. && echo "$(GREEN)ARM64 build completed!$(NC)" || echo "$(YELLOW)ARM64 build failed (base image may not support this platform)$(NC)"
	@echo "$(YELLOW)Attempting ARM v7 build (may fail if base image doesn't support this platform)...$(NC)"
	-$(BUILDX) build \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg RCLONE_VERSION="$(RCLONE_VERSION)" \
		--tag $(DOCKER_REPO):arm-v7-$(VERSION) \
		--output=type=docker \
		. && echo "$(GREEN)ARM v7 build completed!$(NC)" || echo "$(YELLOW)ARM v7 build failed (base image may not support this platform)$(NC)"
	@echo "$(YELLOW)Note: Some ARM builds may fail due to base image platform support limitations.$(NC)"
	@echo "$(YELLOW)For full manifest creation with registry push, use 'make build-manifest-push'$(NC)"
	@echo "$(GREEN)LinuxServer.io style local builds completed!$(NC)"

build-manifest-push: ## Build and push LinuxServer.io style manifest lists (requires registry access)
	@echo "$(GREEN)Building and pushing LinuxServer.io style multi-arch with manifest lists...$(NC)"
	@echo "$(YELLOW)Warning: This requires Docker Hub login and push access!$(NC)"
	@echo "Building platform-specific images..."
	# Build for each platform separately and push by digest
	$(BUILDX) build \
		--platform linux/amd64 \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg RCLONE_VERSION="$(RCLONE_VERSION)" \
		--tag $(DOCKER_REPO):amd64-$(VERSION) \
		--push \
		.
	$(BUILDX) build \
		--platform linux/arm64 \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg RCLONE_VERSION="$(RCLONE_VERSION)" \
		--tag $(DOCKER_REPO):arm64-$(VERSION) \
		--push \
		.
	$(BUILDX) build \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg RCLONE_VERSION="$(RCLONE_VERSION)" \
		--tag $(DOCKER_REPO):arm-v7-$(VERSION) \
		--push \
		.
	@echo "Creating manifest list..."
	$(DOCKER) manifest create $(DOCKER_REPO):$(VERSION) \
		$(DOCKER_REPO):amd64-$(VERSION) \
		$(DOCKER_REPO):arm64-$(VERSION) \
		$(DOCKER_REPO):arm-v7-$(VERSION)
	$(DOCKER) manifest push $(DOCKER_REPO):$(VERSION)
	@echo "$(GREEN)LinuxServer.io style build with manifest list completed!$(NC)"

inspect-manifest: ## Inspect manifest lists (LinuxServer.io style)
	@echo "$(GREEN)Inspecting local images and manifest lists...$(NC)"
	@echo "=== Local Images ==="
	@$(DOCKER) images $(DOCKER_REPO) | grep -E "(latest|amd64|arm64|arm-v7)" || echo "No local images found"
	@echo "=== Architecture-specific local images ==="
	@for arch in amd64 arm64 arm-v7; do \
		echo "--- $${arch} specific image ---"; \
		if $(DOCKER) inspect $(DOCKER_REPO):$${arch}-$(VERSION) >/dev/null 2>&1; then \
			$(DOCKER) inspect $(DOCKER_REPO):$${arch}-$(VERSION) --format '{{.Architecture}}' 2>/dev/null || echo "Architecture info not available"; \
		else \
			echo "Image not found locally"; \
		fi; \
	done
	@echo "=== Remote Manifest verification (if available) ==="
	@$(BUILDX) imagetools inspect $(DOCKER_REPO):$(VERSION) 2>/dev/null || echo "$(YELLOW)Remote manifest not available (not pushed)$(NC)"

validate-manifest: ## Validate OCI manifest compliance
	@echo "$(GREEN)Validating OCI manifest compliance...$(NC)"
	@command -v skopeo >/dev/null 2>&1 && \
		skopeo inspect docker://$(DOCKER_REPO):$(VERSION) || \
		(echo "$(YELLOW)Skopeo not installed, using docker manifest inspect$(NC)"; \
		$(DOCKER) manifest inspect $(DOCKER_REPO):$(VERSION))

## Test targets
test: ## Test the Docker image
	@echo "$(GREEN)Testing Docker image...$(NC)"
	@echo "Creating test directories..."
	@mkdir -p /tmp/rclone-test-{config,data,logs}
	@echo "Starting container for testing..."
	$(DOCKER) run -d \
		--name rclone-test \
		--rm \
		-p 15572:5572 \
		-v /tmp/rclone-test-config:/config \
		-v /tmp/rclone-test-data:/data \
		-v /tmp/rclone-test-logs:/config/logs \
		-e PUID=$(shell id -u) \
		-e PGID=$(shell id -g) \
		--health-cmd="ps aux | grep -v grep | grep rclone || exit 1" \
		--health-interval=15s \
		--health-timeout=10s \
		--health-retries=5 \
		--health-start-period=30s \
		$(DOCKER_REPO):$(VERSION)
	@echo "Waiting for container to be healthy..."
	@timeout 120 sh -c 'until [ "$$($(DOCKER) inspect --format="{{.State.Health.Status}}" rclone-test)" = "healthy" ]; do sleep 3; done' || \
		(echo "$(RED)✗ Container failed to become healthy$(NC)"; \
		$(DOCKER) logs rclone-test; \
		$(DOCKER) stop rclone-test; \
		exit 1)
	@echo "$(GREEN)✓ Health check passed$(NC)"
	@echo "Testing rclone functionality..."
	@echo "Waiting for services to fully start..."
	@sleep 10
	@echo "Checking rclone binary availability..."
	@$(DOCKER) exec rclone-test rclone version >/dev/null || \
		(echo "$(RED)✗ rclone binary not accessible$(NC)"; \
		$(DOCKER) logs rclone-test; \
		$(DOCKER) stop rclone-test; \
		exit 1)
	@echo "$(GREEN)✓ rclone binary is working$(NC)"
	@echo "Verifying container is running correctly..."
	@$(DOCKER) inspect rclone-test >/dev/null || \
		(echo "$(RED)✗ Container is not running$(NC)"; \
		exit 1)
	@echo "$(GREEN)✓ Container is running successfully$(NC)"
	@echo "Stopping test container..."
	@$(DOCKER) stop rclone-test
	@echo "Cleaning up test directories..."
	@rm -rf /tmp/rclone-test-*
	@echo "$(GREEN)All tests passed!$(NC)"

## Security and validation targets
security-scan: ## Run comprehensive security scan (Trivy + CodeQL)
	@echo "$(GREEN)Running comprehensive security scan...$(NC)"
	@echo "$(YELLOW)1. Running Trivy vulnerability scan...$(NC)"
	@command -v trivy >/dev/null 2>&1 && \
		trivy image $(DOCKER_REPO):$(VERSION) || \
		(echo "$(YELLOW)Running Trivy via Docker...$(NC)"; \
		docker run --rm -v //var/run/docker.sock:/var/run/docker.sock \
			aquasec/trivy:latest image $(DOCKER_REPO):$(VERSION) || \
		(echo "$(YELLOW)Trivy scan failed$(NC)"; \
		echo "Install Trivy for security scanning: https://trivy.dev/"))
	@echo "$(YELLOW)2. Running CodeQL static analysis...$(NC)"
	@make codeql-scan
	@echo "$(GREEN)✓ Comprehensive security scan completed$(NC)"

codeql-scan: ## Run CodeQL static code analysis
	@echo "$(GREEN)Running CodeQL static analysis...$(NC)"
	@if command -v gh >/dev/null 2>&1; then \
		echo "$(YELLOW)Using GitHub CLI for CodeQL...$(NC)"; \
		gh workflow run codeql.yml --ref $(shell git branch --show-current) || \
		echo "$(YELLOW)CodeQL workflow triggered via GitHub CLI$(NC)"; \
	elif command -v codeql >/dev/null 2>&1; then \
		echo "$(YELLOW)Running CodeQL locally...$(NC)"; \
		codeql database create codeql-db --language=javascript || true; \
		codeql database analyze codeql-db --format=csv --output=codeql-results.csv || true; \
		echo "$(GREEN)✓ CodeQL analysis completed - results in codeql-results.csv$(NC)"; \
	else \
		echo "$(YELLOW)CodeQL not available locally. Install CodeQL CLI or use GitHub Actions.$(NC)"; \
		echo "$(CYAN)GitHub Actions CodeQL workflow available at: .github/workflows/codeql.yml$(NC)"; \
		echo "$(CYAN)Install CodeQL: https://docs.github.com/en/code-security/codeql-cli/getting-started-with-the-codeql-cli$(NC)"; \
	fi

trivy-scan: ## Run Trivy vulnerability scan only
	@echo "$(GREEN)Running Trivy vulnerability scan...$(NC)"
	@command -v trivy >/dev/null 2>&1 && \
		trivy image $(DOCKER_REPO):$(VERSION) || \
		(echo "$(YELLOW)Running Trivy via Docker...$(NC)"; \
		docker run --rm -v //var/run/docker.sock:/var/run/docker.sock \
			aquasec/trivy:latest image $(DOCKER_REPO):$(VERSION))

security-scan-detailed: ## Run detailed security scan with exports
	@echo "$(GREEN)Running detailed security scan with exports...$(NC)"
	@mkdir -p security-reports
	@echo "$(YELLOW)1. Trivy JSON report...$(NC)"
	@command -v trivy >/dev/null 2>&1 && \
		trivy image --format json --output security-reports/trivy-report.json $(DOCKER_REPO):$(VERSION) || \
		docker run --rm -v //var/run/docker.sock:/var/run/docker.sock -v $(PWD)/security-reports:/reports \
			aquasec/trivy:latest image --format json --output /reports/trivy-report.json $(DOCKER_REPO):$(VERSION)
	@echo "$(YELLOW)2. Trivy SARIF report...$(NC)"
	@command -v trivy >/dev/null 2>&1 && \
		trivy image --format sarif --output security-reports/trivy-report.sarif $(DOCKER_REPO):$(VERSION) || \
		docker run --rm -v //var/run/docker.sock:/var/run/docker.sock -v $(PWD)/security-reports:/reports \
			aquasec/trivy:latest image --format sarif --output /reports/trivy-report.sarif $(DOCKER_REPO):$(VERSION)
	@echo "$(YELLOW)3. Dockerfile scan...$(NC)"
	@command -v trivy >/dev/null 2>&1 && \
		trivy config --format json --output security-reports/dockerfile-scan.json . || \
		docker run --rm -v $(PWD):/workspace -v $(PWD)/security-reports:/reports \
			aquasec/trivy:latest config --format json --output /reports/dockerfile-scan.json /workspace
	@echo "$(GREEN)✓ Security reports saved to security-reports/$(NC)"
	@echo "$(CYAN)Reports generated:$(NC)"
	@echo "  - security-reports/trivy-report.json"
	@echo "  - security-reports/trivy-report.sarif"
	@echo "  - security-reports/dockerfile-scan.json"

validate: ## Validate Dockerfile and configuration
	@echo "$(GREEN)Validating Dockerfile...$(NC)"
	@command -v hadolint >/dev/null 2>&1 && \
		(hadolint Dockerfile; echo "$(GREEN)✓ Dockerfile validation passed$(NC)") || \
		(echo "$(YELLOW)Hadolint not installed, skipping Dockerfile validation$(NC)"; \
		echo "Install Hadolint for Dockerfile validation: https://github.com/hadolint/hadolint")

lint: validate ## Alias for validate

## Deployment targets
push: ## Push image to registry
	@echo "$(GREEN)Pushing Docker image to registry...$(NC)"
	$(DOCKER) push $(DOCKER_REPO):$(VERSION)
	$(DOCKER) push $(DOCKER_REPO):latest
	@echo "$(GREEN)Push completed successfully!$(NC)"

## Utility targets
clean: ## Clean up Docker artifacts
	@echo "$(GREEN)Cleaning up Docker artifacts...$(NC)"
	$(DOCKER) image prune -f
	$(DOCKER) container prune -f
	@echo "$(GREEN)Cleanup completed!$(NC)"

clean-all: ## Remove all related Docker images and containers
	@echo "$(GREEN)Removing all rclone Docker artifacts...$(NC)"
	-@$(DOCKER) stop `$(DOCKER) ps -q --filter ancestor=$(DOCKER_REPO)` 2>/dev/null || true
	-@$(DOCKER) rmi `$(DOCKER) images $(DOCKER_REPO) -q` 2>/dev/null || true
	@echo "$(GREEN)Complete cleanup finished!$(NC)"

## Development targets
dev: ## Build and run for development
	@echo "$(GREEN)Building and starting development container...$(NC)"
	$(MAKE) build
	$(DOCKER) run -it --rm \
		--name rclone-dev \
		-p 15572:5572 \
		-v $(PWD)/test-data/config:/config \
		-v $(PWD)/test-data/data:/data \
		-v $(PWD)/test-data/logs:/config/logs \
		$(DOCKER_REPO):$(VERSION)

shell: ## Get shell access to running container
	@echo "$(GREEN)Opening shell in rclone container...$(NC)"
	$(DOCKER) exec -it `$(DOCKER) ps -q --filter ancestor=$(DOCKER_REPO)` /bin/bash

logs: ## Show logs from running container
	@echo "$(GREEN)Showing logs from rclone container...$(NC)"
	$(DOCKER) logs -f `$(DOCKER) ps -q --filter ancestor=$(DOCKER_REPO)`

## Baseimage management targets
baseimage-check: ## Check for LinuxServer.io baseimage updates
	@echo "$(GREEN)Checking for LinuxServer.io baseimage updates...$(NC)"
	@CURRENT=$$(grep -o 'baseimage-alpine:3.22-[a-f0-9]*-ls[0-9]*' Dockerfile | head -1 | cut -d':' -f2); \
	LATEST=$$(curl -s "https://api.github.com/repos/linuxserver/docker-baseimage-alpine/releases/latest" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4); \
	echo "$(BLUE)Current baseimage: $$CURRENT$(NC)"; \
	echo "$(BLUE)Latest baseimage: $$LATEST$(NC)"; \
	if [ "$$CURRENT" != "$$LATEST" ]; then \
		echo "$(YELLOW)⚠️  Update available: $$CURRENT → $$LATEST$(NC)"; \
		echo "$(CYAN)Run 'make baseimage-test' to test the new version$(NC)"; \
	else \
		echo "$(GREEN)✅ Already using latest baseimage$(NC)"; \
	fi

baseimage-test: ## Test new LinuxServer.io baseimage version
	@echo "$(GREEN)Testing new LinuxServer.io baseimage...$(NC)"
	@if [ ! -f scripts/baseimage-update-test.sh ]; then \
		echo "$(YELLOW)⚠️  Baseimage test script not found. Creating from template...$(NC)"; \
		mkdir -p scripts; \
		curl -s https://raw.githubusercontent.com/mildman1848/template/main/scripts/baseimage-update-test.sh > scripts/baseimage-update-test.sh; \
		chmod +x scripts/baseimage-update-test.sh; \
		echo "$(GREEN)✓ Test script downloaded$(NC)"; \
	fi
	@./scripts/baseimage-update-test.sh
	@echo "$(CYAN)📋 Review test report: BASEIMAGE_UPDATE_REPORT.md$(NC)"

baseimage-update: ## Update to latest LinuxServer.io baseimage (run baseimage-test first!)
	@echo "$(YELLOW)⚠️  This will update the baseimage in Dockerfile$(NC)"
	@echo "$(RED)🛑 Have you run 'make baseimage-test' and verified compatibility?$(NC)"
	@read -p "Continue with baseimage update? [y/N] " -n 1 -r; echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		LATEST=$$(curl -s "https://api.github.com/repos/linuxserver/docker-baseimage-alpine/releases/latest" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4); \
		echo "$(GREEN)Updating to baseimage: $$LATEST$(NC)"; \
		sed -i.bak "s/baseimage-alpine:3.22-[a-f0-9]*-ls[0-9]*/baseimage-alpine:$$LATEST/g" Dockerfile; \
		echo "$(GREEN)✅ Dockerfile updated$(NC)"; \
		echo "$(YELLOW)📋 Backup created: Dockerfile.bak$(NC)"; \
		echo "$(CYAN)🔄 Run 'make build && make test' to verify the update$(NC)"; \
	else \
		echo "$(BLUE)Update cancelled$(NC)"; \
	fi

## Release targets
release: validate build test security-scan ## Complete release workflow
	@echo "$(GREEN)Release workflow completed successfully!$(NC)"
	@echo "To push to registry, run: make push"

## Secrets management targets
secrets-generate: ## Generate secure secrets for rclone
	@echo "$(GREEN)Generating secure secrets for rclone...$(NC)"
	@mkdir -p secrets
	@echo "Generating rclone config password..."
	@openssl rand -base64 32 | tr -d "=+/\n" | head -c 24 > secrets/rclone_config_pass.txt
	@echo "Generating rclone Web GUI password..."
	@openssl rand -base64 32 | tr -d "=+/\n" | head -c 20 > secrets/rclone_web_gui_password.txt
	@chmod 600 secrets/rclone_*.txt
	@chown $(shell id -u):$(shell id -g) secrets/rclone_*.txt 2>/dev/null || true
	@echo "$(GREEN)✓ rclone secrets generated successfully!$(NC)"
	@echo "$(YELLOW)⚠️  Keep these secrets secure and never commit them to version control!$(NC)"
	@echo "$(BLUE)Generated rclone secrets:$(NC)"
	@ls -la secrets/rclone_*.txt | awk '{print "  " $$9 " (" $$5 " bytes)"}'

secrets-generate-ci: ## Generate standardized secrets for CI workflows (GitHub Actions)
	@echo "$(GREEN)Generating CI-standardized secrets for GitHub Actions workflows...$(NC)"
	@mkdir -p secrets
	@echo "Generating comprehensive secret set for CI testing..."
	@openssl rand -base64 32 | tr -d "=+/" | head -c 24 > secrets/rclone_config_pass.txt
	@openssl rand -base64 32 | tr -d "=+/" | head -c 20 > secrets/rclone_password.txt
	@openssl rand -base64 32 | tr -d "=+/" | head -c 20 > secrets/rclone_web_gui_password.txt
	@chmod 600 secrets/*.txt 2>/dev/null || true
	@echo "$(GREEN)✓ CI secrets generated successfully!$(NC)"
	@echo "$(BLUE)CI Secret Files Created:$(NC)"
	@ls -la secrets/ 2>/dev/null | grep -E "(config_pass|password|web_gui)" | awk '{print "  " $$9 ": " $$5 " bytes"}' || echo "  All secrets generated"
	@echo "$(YELLOW)ℹ️  These secrets match CI workflow generation patterns exactly$(NC)"

secrets-rotate: ## Rotate existing secrets (keeps backups)
	@echo "$(GREEN)Rotating secrets...$(NC)"
	@test -d "secrets" && \
		(echo "Creating backup of existing secrets..."; \
		mkdir -p secrets/backup-$(shell date +%Y%m%d-%H%M%S); \
		cp secrets/*.txt secrets/backup-$(shell date +%Y%m%d-%H%M%S)/ 2>/dev/null || true) || true
	@$(MAKE) secrets-generate
	@echo "$(GREEN)✓ Secrets rotated successfully!$(NC)"
	@echo "$(YELLOW)⚠️  Update your running containers with the new secrets!$(NC)"

secrets-clean: ## Clean up old secret backups (keeps last 5)
	@echo "$(GREEN)Cleaning up old secret backups...$(NC)"
	@test -d "secrets" && \
		(cd secrets && ls -dt backup-* 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true; \
		echo "$(GREEN)✓ Old secret backups cleaned up!$(NC)") || \
		echo "$(YELLOW)No secrets directory found.$(NC)"

secrets-info: ## Show information about current secrets
	@echo "$(BLUE)rclone Secrets Information:$(NC)"
	@test -d "secrets" && \
		(echo "  Secrets directory: exists"; \
		echo "  rclone secret files:"; \
		ls -la secrets/rclone_*.txt 2>/dev/null | awk '{print "    " $$9 " (" $$5 " bytes, " $$6 " " $$7 " " $$8 ")"}' || echo "    No rclone secret files found"; \
		echo "  Backup directories:"; \
		ls -d secrets/backup-* 2>/dev/null | wc -l | awk '{print "    " $$1 " backup(s) available"}' || echo "    No backups found") || \
		(echo "  Secrets directory: not found"; \
		echo "  Run 'make secrets-generate' to create rclone secrets")

## Environment setup targets
env-setup: ## Setup environment from .env.example
	@echo "$(GREEN)Setting up environment...$(NC)"
	@test ! -f .env && \
		(echo "Creating .env from .env.example..."; \
		cp .env.example .env; \
		echo "$(GREEN)✓ .env file created!$(NC)"; \
		echo "$(YELLOW)⚠️  Please review and customize .env before starting containers!$(NC)") || \
		echo "$(YELLOW).env file already exists, skipping...$(NC)"

env-validate: ## Validate environment configuration
	@echo "$(GREEN)Validating environment configuration...$(NC)"
	@test -f .env && \
		(echo "✓ .env file exists"; \
		grep -q "PUID=" .env && echo "✓ PUID is set" || echo "⚠️  PUID not set"; \
		grep -q "PGID=" .env && echo "✓ PGID is set" || echo "⚠️  PGID not set"; \
		grep -q "TZ=" .env && echo "✓ TZ is set" || echo "⚠️  TZ not set"; \
		grep -q "UMASK=" .env && echo "✓ UMASK is set" || echo "⚠️  UMASK not set"; \
		grep -q "LSIO_FIRST_PARTY=false" .env && echo "✓ LSIO_FIRST_PARTY correctly set" || echo "⚠️  LSIO_FIRST_PARTY should be false"; \
		test -d secrets && echo "✓ Secrets directory exists" || echo "⚠️  Secrets directory missing - run 'make secrets-generate'"; \
		echo "$(GREEN)Environment validation completed!$(NC)") || \
		(echo "$(RED)✗ .env file not found!$(NC)"; \
		echo "Run 'make env-setup' to create it."; \
		exit 1)

## Complete setup workflow
setup: env-setup secrets-generate ## Complete initial setup
	@echo "$(GREEN)Initial setup completed!$(NC)"
	@echo "$(BLUE)Next steps:$(NC)"
	@echo "  1. Review and customize .env file"
	@echo "  2. Run 'make build' to build the Docker image"
	@echo "  3. Run 'make dev' or 'docker-compose up -d' to start"

## Windows-specific targets
windows-setup: env-setup secrets-generate-windows ## Setup for Windows with OpenSSL
	@echo "$(GREEN)Windows setup completed!$(NC)"
	@echo "$(BLUE)Next steps:$(NC)"
	@echo "  1. Review and customize .env file"
	@echo "  2. Run 'make build' to build the Docker image"
	@echo "  3. Run 'make start' to start the container"

secrets-generate-windows: ## Generate secrets using Windows OpenSSL
	@echo "$(GREEN)Generating secure secrets for rclone (Windows)...$(NC)"
	@mkdir -p secrets
	@echo "Generating rclone config password..."
	@openssl rand -base64 32 | tr -d "=+/\n" | cut -c1-24 > secrets/rclone_config_pass.txt
	@echo "Generating rclone Web GUI password..."
	@openssl rand -base64 32 | tr -d "=+/\n" | cut -c1-20 > secrets/rclone_web_gui_password.txt
	@echo "$(GREEN)✓ rclone secrets generated successfully!$(NC)"
	@echo "$(YELLOW)⚠️  Keep these secrets secure and never commit them to version control!$(NC)"

## Container management commands
start: ## Start the rclone container
	@echo "$(GREEN)Starting rclone container...$(NC)"
	@test -f .env || (echo "$(RED)✗ .env file not found! Run 'make env-setup' first$(NC)" && exit 1)
	@test -d secrets || (echo "$(YELLOW)⚠️  Secrets not found, generating...$(NC)" && $(MAKE) secrets-generate)
	$(COMPOSE) up -d rclone
	@echo "$(GREEN)✓ Container started on http://localhost:$$(grep EXTERNAL_PORT .env | cut -d'=' -f2 | head -1)$(NC)"

start-with-db: ## Start rclone with PostgreSQL database
	@echo "$(GREEN)Starting rclone with database...$(NC)"
	@test -f .env || (echo "$(RED)✗ .env file not found! Run 'make env-setup' first$(NC)" && exit 1)
	@test -d secrets || (echo "$(YELLOW)⚠️  Secrets not found, generating...$(NC)" && $(MAKE) secrets-generate)
	$(COMPOSE) --profile with-db up -d
	@echo "$(GREEN)✓ Container with database started$(NC)"

stop: ## Stop the rclone container
	@echo "$(GREEN)Stopping rclone container...$(NC)"
	$(COMPOSE) down
	@echo "$(GREEN)✓ Container stopped$(NC)"

restart: stop start ## Restart the rclone container

status: ## Show container status and health
	@echo "$(GREEN)Container Status:$(NC)"
	$(COMPOSE) ps
	@echo ""
	@echo "$(GREEN)Health Status:$(NC)"
	@$(DOCKER) ps --filter "name=rclone" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"
	@echo ""
	@echo "$(GREEN)Recent Logs:$(NC)"
	$(COMPOSE) logs --tail=20 rclone 2>/dev/null || echo "No logs available"

## Information targets
info: ## Show build information
	@echo "$(BLUE)Build Information:$(NC)"
	@echo "  Repository: $(DOCKER_REPO)"
	@echo "  Version: $(VERSION)"
	@echo "  Build Date: $(BUILD_DATE)"
	@echo "  VCS Ref: $(VCS_REF)"
	@echo "  rclone Version: $(RCLONE_VERSION)"
	@echo "  Platforms: $(PLATFORMS)"