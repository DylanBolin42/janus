<div align="center">

# Janus ⚡

### A Next-Generation Productivity & Task Management Suite

[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.10.7-blue?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart SDK](https://img.shields.io/badge/Dart-%5E3.10.7-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Drift SQLite](https://img.shields.io/badge/Drift-SQLite-orange?style=for-the-badge&logo=sqlite)](https://drift.simonbinder.eu)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-purple?style=for-the-badge)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/DylanBolin42/janus?utm_source=oss&utm_medium=github&utm_campaign=DylanBolin42%2Fjanus&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)

*Janus is an engineering-grade, high-performance task management and personal productivity application built with Flutter, combining Liquid Glass aesthetics with Material 3 Expressive design, robust local-first SQLite persistence, and reactive state management.*

[Getting Started](#getting-started) • [Tech Stack](#tech-stack--architecture) • [Features](#features) • [Contributing](#contributing)

</div>

---

## 🌟 Overview

**Janus** is designed for power users who demand both exquisite visual aesthetics and uncompromising performance. Built using modern Flutter paradigms, Janus merges the principles of fluid glassmorphism and Material 3 Expressive design with enterprise-grade local-first data architecture. 

Whether you are managing complex multi-tiered tasks, tracking daily productivity metrics, or configuring granular notification styles, Janus provides a seamless, responsive experience across desktop and mobile platforms.

---

## ✨ Key Features

- **Liquid Glass & Material 3 Expressive UI**: Combines advanced translucent glass visual effects (`liquid_glass_widgets`) with Material 3 Expressive guidelines, pursuing a seamless balance between robust functionality and stunning aesthetics.
- **Local-First & High Performance**: Powered by **Drift** (type-safe reactive SQLite database for Flutter), ensuring lightning-fast data querying, offline-first reliability, and seamless synchronization.
- **Reactive State Management**: Built on top of **Riverpod** and **Freezed**, providing robust, immutable data models and predictable reactive state flows.
- **Granular Notification Engine**: Supports multi-tiered notification styles for urgent and approaching tasks, including notifier, shake, ring, and full-screen alerts.
- **Flexible Navigation & Theming**: Employs **GoRouter** for declarative routing and supports dynamic light/dark/system themes alongside customizable navigation naming styles (Classic, Latin, Professional).
- **Cross-Platform Ready**: Fully optimized for Android, iOS, macOS, Windows, Linux, and Web platforms.

---

## 🛠️ Tech Stack & Architecture

Janus adheres to strict engineering standards, separating concerns cleanly across data, domain, presentation, and service layers.

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) / [Dart](https://dart.dev) | Cross-platform UI toolkit |
| **State Management** | [Flutter Riverpod](https://riverpod.dev) | Compile-safe reactive dependency injection & state management |
| **Database & ORM** | [Drift (SQLite)](https://drift.simonbinder.eu) | Reactive, type-safe SQLite database for Dart & Flutter |
| **Immutability & Models** | [Freezed](https://pub.dev/packages/freezed) & JSON Serializable | Code generation for immutable classes and JSON serialization |
| **Routing** | [GoRouter](https://pub.dev/packages/go_router) | Declarative routing package for Flutter |
| **UI Enhancements** | `liquid_glass_widgets`, `flutter_card_swiper`, `google_fonts` | Modern visual components and glassmorphism styling |

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your development machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.10.7` or higher)
- [Dart SDK](https://dart.dev/get-dart) (`^3.10.7` or higher)
- [FVM (Flutter Version Management)](https://fvm.app/) *(Optional, project includes `.fvmrc`)*

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/DylanBolin42/janus.git
   cd janus
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (Freezed / Drift / Riverpod):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📂 Project Directory Structure

```text
janus/
├── android/            # Android platform integration
├── ios/                # iOS platform integration
├── macos/              # macOS platform integration
├── windows/            # Windows platform integration
├── linux/              # Linux platform integration
├── web/                # Web assets and entry point
├── lib/
│   ├── models/         # Immutable data models (Freezed)
│   ├── providers/      # Riverpod state providers
│   ├── services/       # Local storage & business services
│   ├── ui/             # Views, screens & widgets
│   └── main.dart       # Application entry point
├── docs/               # Technical documentation (e.g., SETTINGS.md)
├── guide/              # Development guides (e.g., ADD_NEW_SETTING.md)
├── assets/             # Images, fonts, and static resources
└── test/               # Unit and widget test suites
```

---

## 🤝 Contributing

We welcome contributions from the community! Whether it's bug reporting, feature proposals, or code submissions, please refer to our [CONTRIBUTING.md](CONTRIBUTING.md) guide for detailed instructions on our development workflow and coding standards.

---

## 📄 License

This project is licensed under the terms of the [MIT License](LICENSE).
