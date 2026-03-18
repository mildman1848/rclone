# Sicherheitsrichtlinie

> 🇩🇪 **Deutsche Version** | 🇬🇧 **[English Version](SECURITY.md)**

## Geltungsbereich

Diese Richtlinie gilt für das Docker-Image, die Build-Pipeline, den Compose-Stack, die eingebundene Service-Konfiguration und die Repository-Automation des rclone-Images.

## Meldung von Sicherheitslücken

Bitte eröffnen Sie keine öffentliche Issue für vermutete Sicherheitslücken.

Verwenden Sie stattdessen einen privaten Kanal:

- GitHub Security Advisories: `https://github.com/mildman1848/rclone/security/advisories/new`
- Falls Advisories nicht verfügbar sind, zuerst eine normale Issue ohne Exploit-Details eröffnen und um einen privaten Folgekanal bitten.

## Benötigte Informationen

Bitte geben Sie möglichst Folgendes an:

- betroffenen Image-Tag oder Commit
- Host-Umgebung und Container-Runtime
- Reproduktionsschritte
- erwartete Auswirkungen
- mögliche Gegenmaßnahmen oder Fix-Ideen

## Reaktionsziele

Wir versuchen:

- Berichte innerhalb von 7 Werktagen zu bestätigen
- Schweregrad und Umfang schnell zu validieren
- kritische Fixes vor normaler Wartungsarbeit zu priorisieren

## Außerhalb des Geltungsbereichs

Bitte melden Sie Upstream-Probleme direkt an die zuständigen Maintainer, wenn die Ursache in einem der folgenden Bereiche liegt:

- `rclone` selbst
- LinuxServer.io-Base-Images
- Drittanbieter-Registries oder Hosting-Infrastruktur

## Sicherheitspraktiken

Dieses Repository nutzt bereits:

- automatisierte Trivy-Scans
- Dockerfile-Linting mit Hadolint
- Abhängigkeitsautomation per GitHub-Workflows
- dokumentiertes Secrets-Handling und Compose-basierte Laufzeitkonfiguration

## Verwandte Dokumente

- Projektdokumentation: [README.md](README.md)
- Englische Sicherheitsrichtlinie: [SECURITY.md](SECURITY.md)

Letzte Aktualisierung: 2026-03-18
