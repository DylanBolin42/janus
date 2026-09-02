## 2025-05-18 - Enforce HTTPS Validation for Remote AI Endpoints

**Vulnerability:** Unencrypted HTTP endpoints for remote AI services allow plain-text transmission of sensitive API requests over public networks, creating a Man-in-the-Middle (MITM) interception vector.
**Learning:** Developers often allow arbitrary URL input in AI setting configurations without scheme validation, accidentally permitting HTTP fallback for remote hosts.
**Prevention:** Strictly enforce HTTPS for remote URLs via `isValidAiEndpoint` while permitting unencrypted HTTP only for local loopback development hosts (`localhost`, `127.0.0.1`, `::1`).
