# Sentinel Security Journal

## 2026-03-05 - Enforcing HTTPS and Obfuscating API Keys in Janus Settings
**Vulnerability:** Clear-text input of API/AI Endpoint URLs and API Keys on the settings page with no validation could result in (1) unencrypted HTTP connections leading to Man-In-The-Middle (MITM) attacks and credential/data leakage, and (2) clear-text persistence of sensitive API keys on device disk (via SharedPreferences), exposing keys to unauthorized access.
**Learning:** Initial scaffolding of settings text fields was mock/incomplete. In mobile app development, developers often defer securing text configurations and store credentials alongside non-sensitive preferences without obfuscation.
**Prevention:** Always validate external URL inputs to enforce safe transfer protocols (HTTPS). For sensitive credentials/keys, store them securely using obfuscation (e.g., lightweight XOR ciphers) or platform-native secure vaults rather than plain-text shared preference keys to guarantee defense-in-depth security.
