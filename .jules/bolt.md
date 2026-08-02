## 2025-02-15 - [Settings & Theme Mode Optimization]
**Learning:** Watching full async config models/objects in root-level or parent components triggers global app rebuilds on unrelated settings mutations. Using Riverpod's `.select` filtering eliminates these redundant rebuilds. Additionally, performing settings modifications optimistically in memory first, and caching Shared Preferences singletons, removes asynchronous main-thread bottlenecks and disk-serialization latency from the UX path.
**Action:** When working with global app configurations and settings providers, always:
1. Cache SharedPreferences instances locally in the service layer to avoid setup/init overhead on every save/load call.
2. Select specific properties granularly using `.select` to watch only fields that actually dictate UI changes in that component.
3. Apply state updates optimistically in memory before waiting for asynchronous I/O/serialization to avoid blocking UI responsive feedback.
