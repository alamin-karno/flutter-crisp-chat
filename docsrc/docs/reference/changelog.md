---
head:
  - - meta
    - name: description
      content: Changelog for the Flutter Crisp Chat plugin — version history, new features, bug fixes, and breaking changes.

  - - meta
    - name: keywords
      content: "flutter crisp chat changelog, crisp_chat version history, crisp chat updates"

prev:
  text: 'FAQ'
  link: '/reference/faq'

next: false
---

# Changelog

All notable changes to the `crisp_chat` package are documented here. For the full changelog, see [CHANGELOG.md on GitHub](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/CHANGELOG.md).

## [Unreleased]

## 2.6.0

### Added
* `FlutterCrispChat.openHelpdesk()` — opens the Crisp Helpdesk/FAQ search screen directly on **all platforms** (closes [#158](https://github.com/alamin-karno/flutter-crisp-chat/issues/158)). Android/iOS use the native SDK; Web and desktop push `$crisp.push(["do", "helpdesk:search"])` via the Crisp Web Chat SDK.
* `FlutterCrispChat.openHelpdeskArticle()` — opens a specific helpdesk article by `locale` and `slug`, with optional `title` and `category`, on **all platforms**. Android/iOS use the native SDK; Web and desktop push `$crisp.push(["do", "helpdesk:article:open", [...]])`. See [Helpdesk / FAQ](/core_feature/helpdesk) for full details.

### Fixed
* Fixed iOS **Swift Package Manager** build error — added explicit `UIKit` linker setting to `Package.swift` ([#161](https://github.com/alamin-karno/flutter-crisp-chat/pull/161)).
* Fixed spurious `"can not find webview for id: 0"` log noise on desktop — added startup delay before polling and suppressed transient initialisation error.

### Security
* Fixed high-severity esbuild RCE vulnerability ([GHSA-gv7w-rqvm-qjhr](https://github.com/advisories/GHSA-gv7w-rqvm-qjhr)) in `docsrc/` dev tooling — bumped esbuild override to `^0.28.0` ([#159](https://github.com/alamin-karno/flutter-crisp-chat/pull/159)).
* Fixed low-severity esbuild path traversal vulnerability ([GHSA-g7r4-m6w7-qqqr](https://github.com/advisories/GHSA-g7r4-m6w7-qqqr)) in `docsrc/` dev tooling — bumped esbuild override to `^0.28.1` ([#160](https://github.com/alamin-karno/flutter-crisp-chat/pull/160)).

### Documentation
* Added blog post covering the multi-platform `crisp_chat` Flutter plugin expansion to Web and desktop.
* Added [Helpdesk / FAQ](/core_feature/helpdesk) documentation page with full usage examples for all platforms.
* docsrc PageSpeed / SEO improvements: local asset hosting, non-render-blocking font loading, Open Graph / Twitter Card meta, canonical links, JSON-LD structured data, and CLS fixes.

## 2.5.0

### Added
* Web support (Crisp Web Chat SDK via `client.crisp.chat`).
* Desktop support for macOS, Windows, and Linux (`desktop_webview_window` + browser fallback).
* `FlutterCrispChat.markMessagesAsRead()` — REST `PATCH` to clear `unread.visitor` (iOS read-receipt workaround; also on Android/Web/desktop with REST credentials).
* `FlutterCrispChat.isVideoCallsSupported()` — check whether the current build supports Crisp calls (iOS WebRTC variant, or Web/desktop).
* Optional **iOS video/audio calls** (build-time opt-in):
  * **CocoaPods:** `$CrispChatWebRTC = true` in `ios/Podfile` (`Crisp/CrispWebRTC`, ~10 MB larger).
  * **SPM:** `CRISP_CHAT_WEBRTC=true` before build; [`Package.swift`](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/ios/crisp_chat/Package.swift) selects `CrispWebRTC` automatically.
  * Android native video not supported yet ([Crisp Android SDK #181](https://github.com/crisp-im/crisp-sdk-android/issues/181)).
* Documentation: [Supported platforms](/getting_started/supported_platforms) guide; Crisp dashboard **domain lock** guidance ([#148](https://github.com/alamin-karno/flutter-crisp-chat/issues/148)); iOS unread-count limitation (troubleshooting and [unread messages](/core_feature/unread_messages)).

### Changed
* Minimum Dart SDK 3.5.0 and Flutter 3.24.0.
* `openChatboxFromNotification` and `setOnNotificationTappedCallback` are no-ops on Web/desktop.
* Example app extended with **linux**, **macos**, and **windows** runners.
* GitHub Actions **CI** (analyze + test on Ubuntu).

### Breaking
* Apps on **Flutter < 3.24** or **Dart < 3.5** must stay on **2.4.8** for mobile-only usage.
* New dependencies: `desktop_webview_window`, `http`, `url_launcher`, `web`.

## 2.4.8

### Fixed
* Fixed iOS **Swift Package Manager** integration (broken since `2.4.2`): package resolution, product name `crisp-chat`, and Swift-only SPM target.
* Consolidated iOS Swift sources under `ios/crisp_chat/Sources/crisp_chat/` for SPM and CocoaPods.
* Restored `ModalPresentationStyle.popover` mapping to `UIModalPresentationStyle.popover` with iPad popover anchor configuration.

## 2.4.7

### Added
* Added `signature` parameter to `User` for Crisp Identity Verification on Android and iOS.

### Changed
* Upgraded Crisp Android SDK from `2.0.18` to `2.0.20`.
    - Added mobile SDK specific strings localization.
    - [#232](https://github.com/crisp-im/crisp-sdk-android/issues/232) Added missing mobile SDK specific strings localization.

### Fixed
* Fixed issue: [#132](https://github.com/alamin-karno/flutter-crisp-chat/issues/132) - [iOS] Black screen after closing chat (fullScreen) / tap-through when open (overFullScreen)

## 2.4.6

### Added
- `modalPresentationStyle` parameter to `CrispConfig` for iOS modal presentation style configuration
- `ModalPresentationStyle` enum with options: `fullScreen`, `pageSheet`, `formSheet`, `overFullScreen`, `overCurrentContext`, and `popover`
- Default modal presentation style is set to `fullScreen` to prevent touch events from passing through to the underlying Flutter UI

### Changed
- Upgraded Crisp Android SDK from `2.0.17` to `2.0.18`
  - Fixed crash on message deserialization when origin is null

### Fixed
- Fixed issue where `enableNotifications: false` in `CrispConfig` was being ignored on iOS, causing the Crisp SDK to still prompt for push notification permissions after sending the first message

## 2.4.5

### Changed
- Upgraded Crisp Android SDK from `2.0.16` to `2.0.17`
  - Scroll to last message after visitor sent it
  - Updated smileys sorting according to Web dashboard

## 2.4.4

### Added
- `CrispChatNotificationService` — a custom `FirebaseMessagingService` that handles Crisp push notifications without auto-opening `ChatActivity`
- `openChatboxFromNotification()` method to open the Crisp chatbox from a notification intent
- `setOnNotificationTappedCallback()` method to listen for notification taps while the app is in the background
- `firebase-messaging` as a `compileOnly` dependency in the SDK's `build.gradle`

### Changed
- Upgraded Crisp iOS SDK from `2.12.0` to `2.13.0`
- Updated `FlutterCrispChatPlugin.java` to implement `NewIntentListener` for detecting notification taps
- Updated `README.md` with two notification handling approaches: **Option A** (auto-open) and **Option B** (app-first)

### Fixed
- [#79](https://github.com/alamin-karno/flutter-crisp-chat/issues/79) — Crisp notification tap directly opens ChatActivity instead of the app's main screen on terminated state

## 2.4.3

### Fixed
- [#98](https://github.com/alamin-karno/flutter-crisp-chat/issues/98) — `getSessionIdentifier()` returns null after closing chat, preventing unread message checks

## 2.4.2

### Added
- `getUnreadMessageCount` to get unread message count
- **Swift Package Manager** support for iOS
- Validation for websiteID on iOS & Android SDK level

### Changed
- Upgraded Crisp Android SDK from `2.0.13` to `2.0.16`
- Increased `minSdkVersion` from `21` to `23`
- Updated `compileSdkVersion` from `35` to `36`
- Upgraded AGP from `8.6.1` to `8.9.1`
- Upgraded Gradle from `8.7` to `8.11.1`
- Upgraded Crisp iOS SDK from `2.8.2` to `2.12.0`
- Increased minimum iOS deployment target from `9.0` to `13.0`

## 2.4.1

### Added
- Google Play's 16KB page size requirement support

### Changed
- Updated Crisp Android SDK `2.0.12` to `2.0.13`
- Updated AGP from `8.6` to `8.7`
- Updated Gradle from `8.4.1` to `8.6.1`
- Updated example project Kotlin from `1.7.10` to `2.1.0`

## 2.4.0

### Added
- `pushSessionEvent` — sends a custom event to the Crisp session with `name` and `color`

### Changed
- Increased minimum Dart SDK constraint from `>=2.12.0` to `>=2.15.0`

## 2.3.0

### Added
- Comprehensive usage examples in README
- `{@category}` tags for improved documentation
- Supported native SDK versions section in README

### Changed
- Updated Crisp Android SDK `2.0.11` to `2.0.12`
- Upgraded `compileSdk` and `targetSdk` to `35`
- Enhanced error handling for `getSessionIdentifier`
- Switched from `Exception` to `ArgumentError` for input validation

### Fixed
- [#57](https://github.com/alamin-karno/flutter-crisp-chat/issues/57) — Android mailto: links fail to launch email app on some devices

## 2.2.5
- Updated Crisp Android SDK `2.0.10` to `2.0.11`
- Fixed [#45](https://github.com/alamin-karno/flutter-crisp-chat/issues/45): Push view up when keyboard is open
- Added remote notification registration for iOS

## 2.2.4
- Updated Crisp Android SDK `2.0.9` to `2.0.10`
- Updated Crisp iOS SDK `2.8.1` to `2.8.2`
- Added `enableNotifications` flag in `CrispConfig`
- Added `setSessionSegments` method

## 2.2.0
- Updated Crisp Android SDK `2.0.5` to `2.0.8`
- Added notification support for missing messages
- Fixed [#10](https://github.com/alamin-karno/flutter-crisp-chat/issues/10), [#17](https://github.com/alamin-karno/flutter-crisp-chat/issues/17), [#24](https://github.com/alamin-karno/flutter-crisp-chat/issues/24)

## 2.0.4
- Added `setSessionString` and `setSessionInt` methods

## 2.0.0
- Major UI update to match Web & iOS chat boxes
- Take photo support, carousel messages, HelpDesk APIs
- Fixed [#4](https://github.com/alamin-karno/flutter-crisp-chat/issues/4): Build fail due to dependency

## 1.0.0
- Added Markdown support
- Updated Android Crisp SDK `1.0.16` to `1.0.18`

## 0.0.1
- Initial release — Crisp Chat for native Android & iOS platforms

## Next Steps

- [Common Issues](/troubleshooting/common_issues) — Troubleshooting guide
