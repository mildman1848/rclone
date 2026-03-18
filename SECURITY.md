# Security Policy

> 🇬🇧 **English Version** | 🇩🇪 **[Deutsche Version](SECURITY.DE.md)**

## Supported Scope

This policy covers the Docker image, build pipeline, Compose setup, bundled service configuration, and repository automation for the rclone image.

## Reporting Security Vulnerabilities

Please do not open a public issue for a suspected vulnerability.

Use one of these private channels instead:

- GitHub Security Advisories: `https://github.com/mildman1848/rclone/security/advisories/new`
- If advisories are unavailable, open a normal issue only after removing exploit details and asking for a private follow-up channel.

## What to Include

Please include:

- affected image tag or commit
- host environment and container runtime
- reproduction steps
- expected impact
- mitigation ideas, if available

## Response Targets

We aim to:

- acknowledge reports within 7 business days
- validate severity and scope as quickly as possible
- prioritize critical fixes ahead of normal maintenance work

## Out of Scope

Please report upstream issues to the relevant maintainers when the problem is rooted in:

- `rclone` itself
- the LinuxServer.io base image
- third-party registries or hosting infrastructure

## Security Practices

This repository already uses:

- automated Trivy scans
- Dockerfile linting with Hadolint
- dependency automation via GitHub workflows
- documented secrets handling and Compose-based runtime configuration

## Related Documents

- project documentation: [README.md](README.md)
- German security notes: [SECURITY.DE.md](SECURITY.DE.md)

Last updated: 2026-03-18
