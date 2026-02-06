---
head:
  - - meta
    - name: description
      content: How to contribute to the Flutter Crisp Chat plugin — fork, setup, code style, and pull request guidelines.

  - - meta
    - name: keywords
      content: "contribute flutter crisp chat, crisp chat open source, flutter crisp chat pull request"

prev:
  text: 'Platform-Specific'
  link: '/troubleshooting/platform_specific'

next:
  text: 'Author & Maintainer'
  link: '/community/author'
---

# Contributing

Thanks for your interest in contributing to **Flutter Crisp Chat**! Contributions help improve the experience for everyone using this package.

## Getting Started

### 1. Fork & Clone

```bash
# Fork the repo on GitHub, then:
git clone https://github.com/<your-username>/flutter-crisp-chat.git
cd flutter-crisp-chat
```

### 2. Set Up the Example App

The `example/` folder contains a Flutter project to test the plugin.

#### Add Firebase Configuration

Create a Firebase project at [Firebase Console](https://console.firebase.google.com/) and add:

- `example/android/app/google-services.json` (Android)
- `example/ios/Runner/GoogleService-Info.plist` (iOS)

These files are gitignored for security.

#### Add Crisp Credentials

Create `example/lib/config.json`:

```json
{
  "websiteId": "YOUR_WEBSITE_ID",
  "identifier": "YOUR_CRISP_API_IDENTIFIER",
  "crispApiKey": "YOUR_CRISP_API_KEY"
}
```

#### Run the Example

```bash
cd example
flutter run --dart-define-from-file=config.json
```

## Making Changes

### 1. Open an Issue

Before starting work, [open an issue](https://github.com/alamin-karno/flutter-crisp-chat/issues) describing what you want to fix or add.

### 2. Create a Feature Branch

```bash
git checkout -b fix/issue-23-fix-push-notification
```

Use clear naming: `fix/`, `feature/`, or `docs/` prefixes.

### 3. Make Your Changes

- Follow the existing code style
- Keep commits atomic and descriptive
- Test native code changes in the example app
- Update `README.md` if your change affects the public API

### 4. Push & Open a PR

```bash
git push origin fix/issue-23-fix-push-notification
```

Open a pull request on GitHub, referencing the issue number.

## Code Style

- Use meaningful commit messages:
  ```
  fix(iOS): handle missing deviceToken crash on launch
  feat(android): add custom notification service
  docs: update notification handling section
  ```
- Always test using the example project
- Follow Dart conventions for Flutter code
- Follow Java/Swift conventions for native code

## Project Structure

```
flutter-crisp-chat/
├── android/                    # Android native plugin code
│   └── src/main/java/com/alaminkarno/flutter_crisp_chat/
│       ├── FlutterCrispChatPlugin.java
│       └── CrispChatNotificationService.java
├── ios/                        # iOS native plugin code
│   └── Classes/
│       └── SwiftFlutterCrispChatPlugin.swift
├── lib/                        # Dart plugin code
│   ├── crisp_chat.dart         # Main entry point
│   └── src/
│       ├── config.dart         # CrispConfig, User, Company classes
│       ├── flutter_crisp_chat_platform_interface.dart
│       └── flutter_crisp_chat_method_channel.dart
├── example/                    # Example Flutter app
├── test/                       # Dart unit tests
├── docsrc/                     # VitePress documentation site
└── README.md
```

## Need Help?

- Create a [GitHub Discussion or Issue](https://github.com/alamin-karno/flutter-crisp-chat/issues)
- Message the [maintainer](/community/author) for clarification

Thank you for contributing!
