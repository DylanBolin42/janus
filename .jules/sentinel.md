# Sentinel Journal

## 2025-08-04 - Secure AI Configuration and API Key Storage
**Vulnerability:** Cleartext storage of LLM API Keys in generic shared preferences and lack of verification/enforcement of secure HTTPS endpoints for AI requests.
**Learning:** Storing API keys inside generic JSON settings serialized to plain-text SharedPreferences leaves credentials vulnerable to standard device backup harvesting or shared preference scanning. Furthermore, allowing non-HTTPS/HTTP remote endpoints exposes the API Keys to intermediate interception (Man-in-the-Middle attacks). However, purely restricting HTTP would break local development tools such as Ollama running on `localhost` or `127.0.0.1`.
**Prevention:** Always validate remote endpoints to enforce HTTPS protocols unless they point to `localhost` or loopback addresses. API keys and other sensitive credentials must be stored under separate keys and obfuscated on disk (e.g. using lightweight XOR-ciphering before persisting to SharedPreferences) to prevent plain text disclosure.
