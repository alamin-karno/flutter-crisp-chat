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

## [2.4.5]

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
