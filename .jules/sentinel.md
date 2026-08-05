# Sentinel Security Journal

## 2025-02-18 - [AI Settings Endpoint Verification and API Key Obfuscation] **漏洞：** AI 配置页面上的 Endpoint 缺少 HTTPS 强制校验，可能导致传输敏感信息或受到中间人攻击；同时 API Key 存在直接以明文形式持久化存储在磁盘上的风险。 **经验心得：** 客户端应用程序在连接第三方 AI 服务和云存储（例如 WebDAV、OpenAI 兼容端点）时，需要采取防御性纵深设计：1) 强加安全传输协议（HTTPS），除非是在本地环回地址（localhost, 127.0.0.1, ::1）进行开发测试；2) 对于持久化在磁盘上的 API 凭据，采用混淆或加密手段避免物理或 root 提取明文，使用轻量级的 XOR base64 编解码可以非常优雅且无额外开销地实现。 **预防措施：** 每次添加需要网络访问或敏感信息配置的第三方服务时，必须严格应用 Endpoint Scheme 检验，并为密码或密钥设计专用的混淆持久化层，不可直接写入标准未加密配置文件中。
