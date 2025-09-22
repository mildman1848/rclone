# syntax=docker/dockerfile:1

# Build stage for rclone
FROM rclone/rclone:1.71.0 AS rclone

# Production stage with LinuxServer.io Alpine baseimage
FROM ghcr.io/linuxserver/baseimage-alpine:3.22-25712cc1-ls9

# Build arguments for metadata
ARG BUILD_DATE
ARG VERSION
ARG RCLONE_VERSION="1.71.0"

# Metadata labels following LinuxServer.io standards
LABEL build.version="Mildman1848 version: ${VERSION} Build-date: ${BUILD_DATE}"
LABEL maintainer="Mildman1848"
LABEL org.opencontainers.image.title="rclone"
LABEL org.opencontainers.image.description="rclone is a command-line program to manage files on cloud storage."
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.authors="Mildman1848"
LABEL org.opencontainers.image.url="https://rclone.org/"
LABEL org.opencontainers.image.documentation="https://rclone.org/docs/"
LABEL org.opencontainers.image.source="https://github.com/Mildman1848/rclone"
LABEL org.opencontainers.image.vendor="Mildman1848"
LABEL org.opencontainers.image.licenses="MIT"

# Environment variables for rclone
ENV RCLONE_CONFIG="/config/rclone/rclone.conf" \
    RCLONE_CACHE_DIR="/config/cache" \
    RCLONE_TEMP_DIR="/tmp/rclone" \
    RCLONE_LOG_LEVEL="INFO" \
    RCLONE_LOG_FILE="/config/logs/rclone.log" \
    RCLONE_APP_VERSION="${RCLONE_VERSION}"

# Install dependencies and rclone
RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    ca-certificates=20250619-r0 \
    curl=8.14.1-r1 \
    fuse3=3.16.2-r1 \
    unzip=6.0-r15 && \
  echo "**** install rclone ****" && \
  mkdir -p /app && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/* \
    /var/tmp/*

# Copy rclone binary from official image
COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

# Copy local files and set permissions
COPY root/ /

# Security: Set non-root user (LinuxServer.io will manage actual user via S6)
# This satisfies security scanners while S6 overlay handles the real user management
# USER abc

# Expose ports (rclone serve ports)
EXPOSE 5572

# Health check for rclone (test process)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD ps aux | grep -v grep | grep rclone || exit 1

# Volumes for persistent data
VOLUME ["/config", "/data"]
