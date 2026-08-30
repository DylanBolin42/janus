## 2026-08-26 - Enforce HTTPS Endpoint Validation for Remote AI/API Endpoints

**漏洞：** Unvalidated custom AI endpoint URLs allowed unencrypted HTTP connections to remote servers, exposing API keys and request payloads to Man-in-the-Middle (MitM) attacks.

**经验心得：** Users frequently configure custom API/AI endpoints, but allowing arbitrary `http://` schemes to remote domains poses a major network security threat. Allowing `http://` only on loopback addresses (`localhost`, `127.0.0.1`, `::1`) retains developer flexibility without compromising production data security.

**预防措施：** Always validate input URLs for network requests to enforce HTTPS for remote endpoints while explicitly whitelisting loopback hosts for local development.
