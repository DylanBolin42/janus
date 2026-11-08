## 2026-03-30 - AI Endpoint Scheme Validation

**漏洞：** Remote AI API endpoints configured in settings could allow unencrypted HTTP connections (`http://`), exposing user prompts and API authentication headers to Man-In-The-Middle (MITM) network eavesdropping.
**经验心得：** Users might configure third-party OpenAI-compatible endpoints or local LLM instances (like Ollama). Blocking all HTTP traffic breaks local development workflows.
**预防措施：** Enforce HTTPS for remote AI endpoints while explicitly permitting HTTP for local loopback hosts (`localhost`, `127.0.0.1`, `::1`).
