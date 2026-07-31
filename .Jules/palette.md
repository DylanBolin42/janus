# Palette's Journal - Critical UX & Accessibility Learnings

## 2026-07-22 - Destructive Action Confirmation in Storage Settings
**Learning:** Destructive actions such as "Delete Database" should never be immediate or a silent no-op. They must have a clear, context-aware visual confirmation dialog (`AlertDialog`) outlining the irreversible consequences (e.g., loss of all local data) to prevent accidental data loss and build user trust.
**Action:** Always add an interactive confirmation modal/dialog with distinct "Cancel" and "Confirm Delete" action buttons (styled appropriately using error/warning colors) for any action that deletes, removes, or clears user-created data.
