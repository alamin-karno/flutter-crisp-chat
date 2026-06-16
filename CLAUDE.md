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
# or: dart analyze lib test  (matches CI exactly)

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

CI runs `dart analyze lib test` and `flutter test` on Ubuntu via `.github/workflows/ci.yml`, but **only on pushes/PRs to `main`**. Day-to-day development happens on `dev`.

## Architecture

### Plugin Entry Points

| File                                                 | Purpose                                         |
|------------------------------------------------------|-------------------------------------------------|
| `lib/crisp_chat.dart`                                | Main public API — `FlutterCrispChat` class      |
| `lib/src/config.dart`                                | `CrispConfig`, `User`, `Company`, enums         |
| `lib/src/helper.dart`                                | `HelperExtensions` — `isEmail`/`isUrl` on `String?` |
| `lib/src/flutter_crisp_chat_platform_interface.dart` | Abstract `FlutterCrispChatPlatform` base        |
| `lib/src/flutter_crisp_chat_method_channel.dart`     | Method channel impl (mobile)                    |
| `lib/src/flutter_crisp_chat_web.dart`                | Web impl (delegates to `CrispWebSdk`)           |
| `lib/src/flutter_crisp_chat_desktop.dart`            | Desktop impl (delegates to `CrispDesktopWeb`)   |
| `lib/src/crisp_web_sdk*.dart`                        | Web SDK wrapper with conditional imports        |
| `lib/src/crisp_js_bridge.dart`                       | JavaScript bridge for web/desktop embedding     |
| `lib/src/platform_register*.dart`                    | Conditional platform registration (IO/web/stub) |

### Platform Channel API (Mobile)

The method channel name is `flutter_crisp_chat`. All `FlutterCrispChat` static methods that target mobile route through `FlutterCrispChatPlatform.instance`.

The channel is **bidirectional**: native code calls `onCrispNotificationTapped` on the Dart side when a notification is tapped while the app is running. The handler is registered lazily (only when `setOnNotificationTappedCallback` or `openChatboxFromNotification` is first called) via `_ensureNativeHandlerRegistered()` in `MethodChannelFlutterCrispChat`.

`openCrispChat` caches `_sessionIdentifier` with a deliberate 3-second delay after opening, to give the native SDK time to establish the session before querying it.

### Native SDKs

- **iOS**: Crisp iOS SDK 2.13.0, min iOS 13.0. Integrated via CocoaPods or SPM.
  - Optional WebRTC (video calls): set `$CrispChatWebRTC = true` in the app's `ios/Podfile` (CocoaPods) or `CRISP_CHAT_WEBRTC=true` env var (SPM). The Swift code uses `#if CRISP_WEBRTC` to switch imports.
- **Android**: Crisp Android SDK 2.0.20, minSdkVersion 23, compileSdkVersion 36.

### iOS UIWindow Architecture

The iOS plugin presents the Crisp chat in a **dedicated `UIWindow`** at `.alert` level, not as a modal over `FlutterViewController`. This prevents Flutter's rendering engine from pausing (which causes the black-screen-on-dismiss bug). A `CrispDismissalSentinel` (invisible zero-size UIView) detects dismissal via `didMoveToWindow` and tears down the window cleanly, handling re-entrant Crisp-presented VCs (e.g. camera picker).

### REST API Methods

`getUnreadMessageCount()` and `markMessagesAsRead()` are REST calls (using `package:http`) to the Crisp REST API — they require a `crispApiKey` and `identifier` obtained from a Crisp Marketplace plugin token. See `CONTRIBUTING.md` for how to get these. They are not native SDK calls.

On iOS, the native Crisp SDK may not send read receipts when the visitor reads messages, so `unread.visitor` stays non-zero until `markMessagesAsRead()` is called. See `docs/ios-unread-workaround-decision.md`.

### Web SDK Conditional Imports

The web SDK uses the Flutter conditional import pattern:
- `crisp_web_sdk.dart` — exports the correct implementation
- `crisp_web_sdk_web.dart` — actual web implementation
- `crisp_web_sdk_stub.dart` — no-op stub for non-web platforms

Similarly, `platform_register_*.dart` registers the correct platform implementation at startup.

### Desktop WebView Embedding

The desktop implementation writes a full HTML page (generated by `CrispJsBridge.embedHtml()`) to a temporary `file://` URI before loading it in the WebView. This is required because WKWebView (macOS) and WebView2 (Windows) block external scripts on `data:` URLs. Falls back to opening `https://app.crisp.chat` in the system browser if `desktop_webview_window` is unavailable.

## Testing

Tests live in `/test/`. Three test files cover:
- `flutter_crisp_chat_test.dart` — main API surface
- `flutter_crisp_chat_method_channel_test.dart` — method channel behavior
- `crisp_js_bridge_test.dart` — JavaScript bridge URL/config generation

## iOS-Specific Notes

- The Swift source is in `ios/crisp_chat/Sources/crisp_chat/` (SPM package layout).
- `modalPresentationStyle` in `CrispConfig` is an iOS-only parameter.
- Push notification handling intercepts `UNUserNotificationCenterDelegate` and chains to the previous delegate for non-Crisp notifications.

## Android-Specific Notes

- Native plugin class: `com.alaminkarno.flutter_crisp_chat.FlutterCrispChatPlugin`
- Push notifications: `CrispChatNotificationService` (Firebase Messaging)
- `enableNotifications` in `CrispConfig` controls whether the Crisp SDK registers the FCM token.
- Android fires `onCrispNotificationTapped` via `onNewIntent` when a notification is tapped while the app is backgrounded.

## Docsrc (VitePress documentation site)

The docs site lives in `docsrc/`. Build commands (run from `docsrc/`):

```bash
npm run dev      # local dev server
npm run build    # production build → docsrc/docs/.vitepress/dist/
npm run preview  # preview the production build
```

Deploy: GitHub Actions (`.github/workflows/deploy-docs.yml`) builds and publishes to GitHub Pages on push to `main`.

### Docsrc conventions
- Static assets (images, logos) go in `docsrc/docs/public/graphics/`. Reference them as `/flutter-crisp-chat/graphics/<file>` in source, not as external URLs.
- All "Powered By" logos (`flutter-logo.png`, `crisp-logo.png`, `firebase-logo.png`) are locally hosted — do not replace with hotlinks from third-party CDNs (Bing, Webflow, etc.).
- Always add `width` and `height` attributes to `<img>` tags to prevent CLS.
- Google Fonts are loaded via `<link rel="stylesheet">` in `config.mjs` head — never via CSS `@import` (render-blocking).
- `transformPageData` in `config.mjs` injects `og:*`, `twitter:*`, canonical, and JSON-LD on every page — update it when adding new meta tag types.

## Project Workflow Rules

These rules apply to **every feature, fix, or doc change** — follow them without being asked:

### 1. Unreleased changelog
After every code change, add a bullet to the matching category (`Added`, `Changed`, `Fixed`, `Security`, `Documentation`) under `# [Unreleased]` in `CHANGELOG.md`. Keep the same style as existing entries (imperative verb, reference issue/PR if relevant).

### 2. README updates
If a change adds, removes, or alters public API, configuration options, supported platforms, or setup steps, update `README.md` accordingly.

### 3. Docsrc updates
If a change affects user-facing behaviour, platform support, configuration, or API, update the relevant `docsrc/docs/` markdown page(s). Pages live under:
- `getting_started/` — install, platform setup, quick start
- `core_feature/` — CrispConfig, session, user/company, helpdesk, unread messages
- `notifications/` — Firebase, Android, iOS, handling
- `reference/` — API docs, examples, FAQ, changelog
- `troubleshooting/`

### 4. Branch naming
Feature branches: `feat/<topic>`. Bug fixes: `fix/<topic>`. Doc-only: `docs/<topic>`. Docsrc perf/SEO: `fix/docsrc-<topic>`.
