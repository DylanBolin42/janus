# Bolt's Journal

⚡ Speed is a feature. Every millisecond counts. Measure first, optimize second.

## 2026-07-16 - Prevent Global App Rebuilds on Settings Mutation
**Learning:** In Riverpod, watching a full AppSettings state provider from a high-level provider (like `themeModeProvider` which feeds into the root `MaterialApp`) creates a massive performance bottleneck. Any single settings mutation on any leaf settings screen (e.g., toggling logs, changing sync endpoints) triggers a cascade that rebuilds the entire application widget tree, including routing, app shell, and animations.
**Action:** Use Riverpod's `.select` feature to narrow high-level dependency selectors to only watch the specific fields they care about.
