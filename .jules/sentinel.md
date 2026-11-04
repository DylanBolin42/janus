## 2026-04-10 - Enforce HTTPS on Remote AI Endpoint Persistence

**漏洞：** AI settings API `endPoint` previously lacked validation upon persistence in `AppSettingsNotifier`, allowing arbitrary unencrypted `http://` remote endpoints that expose API keys, prompts, and inference data to Man-In-The-Middle (MitM) eavesdropping on untrusted networks.
**经验心得：** AI integrations collect and send sensitive user context and credentials. While local developer tools often run on unencrypted loopback hosts (`localhost`, `127.0.0.1`, `::1`), production/remote endpoints must strictly enforce `https://` schemes before being stored in settings state.
**预防措施：** Validate endpoint URLs at the notifier state setter level to reject non-loopback `http://` schemes and malformed URLs, ensuring defense-in-depth and fail-secure principles prior to persistence.
