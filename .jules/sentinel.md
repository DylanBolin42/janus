## 2026-03-31 - Enforce HTTPS on Remote Endpoint Settings

**漏洞：** AI Settings API `endPoint` previously lacked validation upon persistence, allowing arbitrary unencrypted `http://` remote endpoints that expose API keys, user prompts, and private responses to Man-In-The-Middle (MITM) interception on untrusted networks.

**经验心得：** Remote AI service endpoints handle sensitive credentials and user data. While local development tools often run on unencrypted loopback hosts (`localhost` / `127.0.0.1`), production/remote endpoints must strictly enforce `https://` schemes before being stored in settings.

**预防措施：** Validate endpoint URLs at the notifier state setter level to reject non-loopback `http://` schemes and invalid URL structures, ensuring Defense-in-Depth before data persistence.
