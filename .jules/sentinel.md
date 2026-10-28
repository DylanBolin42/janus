# Sentinel Journal

## 2026-11-18 - Enforce HTTPS for Remote AI Endpoints
**漏洞：** AI 设置中输入的 Endpoint 若使用未加密的远程 HTTP 协议，可能导致请求暴露于中间人攻击 (MITM) 中，从而泄露敏感凭据与 API Key。
**经验心得：** AI 功能通常需要用户配置自定义 Endpoint，需要同时兼容远程云端服务与本地运行的 LLM 开发工具（如 Ollama/LM Studio）。
**预防措施：** 在设置 Endpoint 时校验协议与 Host，对远程地址强制要求 HTTPS，同时对 loopback 主机（`localhost`、`127.0.0.1`、`::1`）允许 HTTP。
