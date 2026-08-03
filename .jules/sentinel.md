# Sentinel Security Journal

## 2025-02-15 - [API Key Plaintext Exposure & MitM vulnerability in AI configuration]
**Vulnerability:** Prior to this patch, AI configuration settings (Endpoint, API Key, and Model name) were not persistent/wired, and standard SharedPreferences storage is vulnerable to plain text exposure of sensitive credentials like API Keys on disk, and unvalidated HTTP endpoints are vulnerable to Man-in-the-Middle (MitM) attacks.
**Learning:** Storing API keys directly in standard preferences leaves them vulnerable to extraction from device backups or physical access. Additionally, unconstrained custom endpoint fields allow users to mistakenly or maliciously configure insecure HTTP connections, risking payload interception.
**Prevention:** Enforce HTTPS validation for any custom API endpoint URLs in the model logic/validation, and obfuscate sensitive credentials (such as API keys) with a lightweight XOR cipher before persisting to disk.
