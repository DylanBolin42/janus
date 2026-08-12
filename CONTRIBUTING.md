# Contributing to Janus

First off, thank you for taking the time to contribute to **Janus**! 🎉 We appreciate your dedication to making this project better.

To ensure a smooth collaboration process and maintain engineering excellence, please follow the guidelines outlined in this document.

---

## 🧭 Code of Conduct

By participating in this project, you agree to abide by our core values:
- Be respectful, welcoming, and inclusive in all discussions and code reviews.
- Prioritize high code quality, readability, and testability.
- Maintain transparent communication linked with our project management tools.

---

## 🎫 Linear Workflow Integration

We use [Linear](https://linear.app) for issue tracking and project management.
- **Tasks & Issues:** Every pull request should ideally be tied to a Linear issue (e.g., `JANUS-44`).
- **Branch Naming:** Name your feature or fix branches following the pattern:
  `[username]/[issue-id]-[short-description]`
  *Example:* `dylanbolin09/janus-44-readme-and-contributing`
- **Commit Messages:** Reference the Linear issue ID in your commit messages:
  ```bash
  git commit -m "docs: add comprehensive readme and contributing guidelines [JANUS-44]"
  ```

---

## 🚀 How Can I Contribute?

### 1. Reporting Bugs
Before creating a bug report, please check existing issues to avoid duplicates. When filing a bug report, include:
- A clear, descriptive title and summary.
- Steps to reproduce the issue.
- Expected vs. actual behavior.
- Screenshots, logs, or stack traces (if applicable).
- Operating system and Flutter SDK version.

### 2. Suggesting Enhancements
Enhancement suggestions are tracked via Linear and GitHub issues. Please provide:
- A detailed description of the proposed feature or improvement.
- The use case or problem it solves.
- Mockups or architectural suggestions if UI/UX changes are involved.

### 3. Pull Request Process

1. **Fork & Clone:** Fork the repository and clone your fork locally.
2. **Create a Branch:** Create a dedicated branch from `main` following our branch naming convention.
3. **Make Changes:** Implement your feature or bug fix adhering to our coding standards.
4. **Run Code Generation:** If you modified data models (`Freezed`), database schema (`Drift`), or Riverpod providers, run:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. **Run Tests & Lints:** Ensure all tests pass and there are no lint warnings:
   ```bash
   flutter test
   flutter analyze
   ```
6. **Commit & Push:** Commit your changes using descriptive messages referencing the Linear issue. Push to your fork and open a Pull Request against the main repository.

---

## 💻 Coding Standards & Best Practices

- **Flutter & Dart Conventions:** Follow the official [Effective Dart](https://dart.dev/effective-dart) guidelines and ensure compliance with `analysis_options.yaml`.
- **State Management:** Use **Riverpod** for state management. Avoid global mutable state.
- **Data Persistence:** Use **Drift** for local database operations and maintain schema migration integrity.
- **UI & Styling:** Maintain consistency with the Liquid Glass design system. Avoid hardcoded magic numbers; use design tokens and theme extensions.

---

## 📦 Pull Request Checklist

Before submitting your PR, make sure you have completed the following:
- [ ] Code is formatted properly (`flutter format .`).
- [ ] Static analysis passes with zero warnings (`flutter analyze`).
- [ ] Unit or widget tests added/updated for new functionality (`flutter test`).
- [ ] Documentation updated (e.g., `README.md`, `docs/`, or code comments).
- [ ] Linear issue reference included in the PR title/description (e.g., `[JANUS-44]`).

Thank you once again for contributing to Janus! 🚀
