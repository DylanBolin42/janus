## 2026-03-31 - Safe AI Endpoint URL Validation

**漏洞：** AI Setting 页面允许输入任意未加密的 HTTP 远程 Endpoint，可能导致敏感的 AI Prompt/上下文数据在传输过程中被中间人攻击（MitM）窃听或篡改。
**经验心得：** 在开发和测试场景中，开发者常需要调用本地 LLM 服务（如 Ollama、LocalAI，位于 `localhost` 或 `127.0.0.1`），如果一律强制 HTTPS 会阻碍本地调试。因此，安全的校验逻辑应严格限制 HTTP 仅作用于本地环回地址（Loopback hosts），而远程地址必须强制 HTTPS。
**预防措施：** 对所有配置远程服务 URL/Endpoint 的输入组件应用 `isValidEndpointUrl` 校验逻辑，防止明文 HTTP 数据泄露。
