# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`crisp_chat` is a multi-platform Flutter plugin for the Crisp live chat SDK. It supports Android, iOS, Web, macOS, Windows, and Linux. Current version: **2.5.0**.

- Mobile (Android/iOS): wraps the native Crisp SDKs via platform channels
- Web: embeds the official Crisp Web Chat SDK in an iframe via a JavaScript bridge
- Desktop (macOS/Windows/Linux): uses `desktop_webview_window` to open a WebView, falling back to the system browser

## Common Commands

```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/flutter_crisp_chat_test.dart

# Analyze (lint)
flutter analyze

# Run the example app (pass credentials via --dart-define or a config file)
cd example && flutter run --dart-define=websiteId=YOUR_WEBSITE_ID

# Run example with a config file (for REST API methods like getUnreadMessageCount)
cd example && flutter run --dart-define-from-file=config.json
```

The `example/config.json` shape (not committed — create locally):
```json
{
  "websiteId": "...",
  "identifier": "...",
  "crispApiKey": "..."
}
```

## Architecture

### Plugin Entry Points

| File | Purpose |
|------|---------|
| `lib/crisp_chat.dart` | Main public API — `FlutterCrispChat` class |
| `lib/src/config.dart` | `CrispConfig`, `User`, `Company`, enums |
| `lib/src/flutter_crisp_chat_platform_interface.dart` | Abstract `FlutterCrispChatPlatform` base |
| `lib/src/flutter_crisp_chat_method_channel.dart` | Method channel impl (mobile) |
| `lib/src/flutter_crisp_chat_web.dart` | Web impl (delegates to `CrispWebSdk`) |
| `lib/src/flutter_crisp_chat_desktop.dart` | Desktop impl (delegates to `CrispDesktopWeb`) |
| `lib/src/crisp_web_sdk*.dart` | Web SDK wrapper with conditional imports |
| `lib/src/crisp_js_bridge.dart` | JavaScript bridge for web embedding |
| `lib/src/platform_register*.dart` | Conditional platform registration (IO/web/stub) |

### Platform Channel API (Mobile)

The method channel name is `flutter_crisp_chat`. All `FlutterCrispChat` static methods that target mobile route through `FlutterCrispChatPlatform.instance`. The platform interface uses a method channel for calls and an event channel for notification callbacks.

### Native SDKs

- **iOS**: Crisp iOS SDK 2.13.0, min iOS 13.0. Integrated via CocoaPods or SPM.
  - Optional WebRTC (video calls): set `$CrispChatWebRTC = true` in the app's `ios/Podfile` (CocoaPods) or `CRISP_CHAT_WEBRTC=true` env var (SPM).
- **Android**: Crisp Android SDK 2.0.20, minSdkVersion 23, compileSdkVersion 36.

### REST API Methods

`getUnreadMessageCount()` and `markMessagesAsRead()` are REST calls (using `package:http`) to the Crisp REST API — they require `crispApiKey` and `identifier` set on the config, and are not native SDK calls.

### Web SDK Conditional Imports

The web SDK uses the Flutter conditional import pattern:
- `crisp_web_sdk.dart` — exports the correct implementation
- `crisp_web_sdk_web.dart` — actual web implementation
- `crisp_web_sdk_stub.dart` — no-op stub for non-web platforms

Similarly, `platform_register_*.dart` registers the correct platform implementation at startup.

## Testing

Tests live in `/test/`. Three test files cover:
- `flutter_crisp_chat_test.dart` — main API surface
- `flutter_crisp_chat_method_channel_test.dart` — method channel behavior
- `crisp_js_bridge_test.dart` — JavaScript bridge URL/config generation

CI runs `flutter analyze` and `flutter test` on Ubuntu via `.github/workflows/ci.yml` on pushes/PRs to `main`.

## iOS-Specific Notes

- The Swift source is in `ios/crisp_chat/Sources/crisp_chat/` (SPM package layout).
- `modalPresentationStyle` in `CrispConfig` is an iOS-only parameter.
- Push notification handling uses `CrispChatNotificationService` and requires Firebase on the example app.

## Android-Specific Notes

- Native plugin class: `com.alaminkarno.flutter_crisp_chat.FlutterCrispChatPlugin`
- Push notifications: `CrispChatNotificationService` (Firebase Messaging)
- `enableNotifications` in `CrispConfig` controls whether the Crisp SDK registers the FCM token.
