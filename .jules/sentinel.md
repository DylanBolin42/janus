# Sentinel's Journal - Critical Security Learnings

## 2026-07-31 - [Secure Pubspec Dependency Resolution]
**Vulnerability:** Insecure dependency resolution over plain HTTP/unencrypted channels.
**Learning:** Dart's analyzer offers a specialized linter rule `secure_pubspec_urls` to enforce that all pub dependency references use HTTPS, guarding against Man-in-the-Middle (MitM) attacks during automated package retrieval and local environment configuration.
**Prevention:** Always include `secure_pubspec_urls: true` in `analysis_options.yaml` of Flutter/Dart projects.
