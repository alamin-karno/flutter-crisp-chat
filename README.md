# Crisp Chat for Flutter

![Crisp Chat](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/example/screenshots/crisp_banner.png?raw=true)

[![pub version](https://img.shields.io/pub/v/crisp_chat?color=%2300b0ff&label=crisp_chat&style=flat-square)](https://pub.dev/packages/crisp_chat)
[![pub likes](https://img.shields.io/pub/likes/crisp_chat?style=flat-square)](https://pub.dev/packages/crisp_chat/score)
[![pub points](https://img.shields.io/pub/points/crisp_chat?style=flat-square)](https://pub.dev/packages/crisp_chat/score)
[![monthly downloads](https://img.shields.io/pub/dm/crisp_chat?style=flat-square)](https://pub.dev/packages/crisp_chat/score)
[![CI](https://img.shields.io/github/actions/workflow/status/alamin-karno/flutter-crisp-chat/ci.yml?branch=main&label=CI&style=flat-square)](https://github.com/alamin-karno/flutter-crisp-chat/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-online-5c6bc0?style=flat-square)](https://alamin-karno.github.io/flutter-crisp-chat/)
[![License: MIT](https://img.shields.io/github/license/alamin-karno/flutter-crisp-chat?style=flat-square)](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/LICENSE)

**Add [Crisp](https://crisp.chat/) live chat to your Flutter app on Android, iOS, Web, macOS, Windows, and Linux, with one Dart API.**

On mobile, the plugin wraps the official native Crisp SDKs. On Web and desktop, it embeds the official Crisp Web Chat SDK. Push notifications, a helpdesk, bot scenarios, chat events, and session data work across platforms with the same code.

📖 **[Documentation](https://alamin-karno.github.io/flutter-crisp-chat/)** · 🚀 **[Quick start](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/quick_start.html)** · 📚 **[API reference](https://alamin-karno.github.io/flutter-crisp-chat/reference/api_documentation.html)** · 🧪 **[Example app](https://github.com/alamin-karno/flutter-crisp-chat/tree/main/example)** · 📝 **[Changelog](https://pub.dev/packages/crisp_chat/changelog)**

## Highlights

- 💬 **Live chat everywhere:** the native Crisp UI on Android and iOS, the official chatbox on Web, and an embedded WebView on desktop.
- 👤 **Know your users:** email (with identity verification), nickname, phone, avatar, company, session data, and segments.
- 🔔 **Push notifications:** Firebase on Android and APNs on iOS, with an option to open your app first and then the chatbox.
- 📖 **Helpdesk:** open the Crisp knowledge base search, or go straight to an article.
- 🤖 **Bots and local messages:** trigger Crisp Bot scenarios, and greet visitors with welcome texts, pickers, or carousels.
- 📡 **Chat events:** react when a session loads, the chat opens or closes, or a message is sent or received.
- 🎨 **Make it yours:** light, dark, or automatic color mode, and iOS presentation styles.
- 📞 **Video and audio calls:** built into the iOS SDK, with no extra setup.

## Platform Support

| Feature                                                                   | Android | iOS | Web | Desktop¹ |
|---------------------------------------------------------------------------|:-------:|:---:|:---:|:--------:|
| Live chat, user and session data, helpdesk, bot scenarios, local messages |   ✅    | ✅  | ✅  |    ✅    |
| Session identifier and unread count (REST)                                |   ✅    | ✅  | ✅² |   ✅²    |
| `isSessionOngoing()` and `CrispConfig.colorMode`                          |    —    | ✅  | ✅  |    ✅    |
| Chat events (`onCrispEvent`) and push notifications                       |   ✅    | ✅  |  —  |    —     |
| Video and audio calls                                                     |    —    | ✅  | ✅  |    ✅    |

¹ macOS, Windows, and Linux, in an embedded WebView. Without WebView support, the chat opens in the system browser and most other APIs do nothing.
² On Web, keep your Crisp REST credentials on a backend proxy, not in the app.

The [full API matrix](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/supported_platforms.html) lists every method.

## Installation

```bash
flutter pub add crisp_chat
```

Then complete the setup for each platform you target:

| Platform    | What you need                                                                                                                                      | Guide                                                                                                                              |
|-------------|----------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| **Android** | `minSdkVersion 23`, `compileSdkVersion 36`, and the `INTERNET` permission                                                                          | [Android setup](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/platform_setup.html#android)                     |
| **iOS**     | iOS 14+ and Xcode 16.3+. Add `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` to `Info.plist`; **without them the chat won't start.** | [iOS setup](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/platform_setup.html#ios)                             |
| **Web**     | Nothing to install; the Crisp script loads at runtime. Allow `*.crisp.chat` if you use a Content Security Policy.                                  | [Web setup](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/platform_setup.html#web)                             |
| **Desktop** | No code changes. macOS needs the network client entitlement, Windows needs WebView2, and Linux needs WebKitGTK.                                    | [Desktop setup](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/platform_setup.html#desktop-macos-windows-linux) |

> **Important:** On Android and iOS, turn off **Lock the chatbox to website domain** in your Crisp dashboard (**Settings → Website Settings → Chatbox & Email Settings → Chatbox Security**). Otherwise the chat fails with "Error starting chat". [Learn more](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/configuration.html#crisp-dashboard-chatbox-security).

## Quick Start

Copy your **Website ID** from the [Crisp dashboard](https://app.crisp.chat/) (**Settings → Website Settings**), then open the chat:

```dart
import 'package:crisp_chat/crisp_chat.dart';

final config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  user: User(email: 'jane@example.com', nickName: 'Jane'), // optional
);

await FlutterCrispChat.openCrispChat(config: config);
```

When the user logs out, reset the session so the next user doesn't see their conversation:

```dart
await FlutterCrispChat.resetCrispChatSession();
```

Each feature has its own guide:

| Feature                 | API                                                                                                      | Guide                                                                                                        |
|-------------------------|----------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| Configuration           | `CrispConfig` (token ID, segment, color mode, iOS presentation style)                                    | [Configuration](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/configuration.html)           |
| Users and companies     | `User`, `Company`, identity verification                                                                 | [User & Company](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/user_and_company.html)       |
| Sessions                | `setSessionString`, `setSessionSegments`, `pushSessionEvent`, `getSessionIdentifier`, `isSessionOngoing` | [Session Management](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/session_management.html) |
| Helpdesk                | `openHelpdesk`, `openHelpdeskArticle`                                                                    | [Helpdesk](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/helpdesk.html)                     |
| Bots and local messages | `runBotScenario`, `showMessage`, `CrispConfig.localMessages`                                             | [Local Messages](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/local_messages.html)         |
| Chat events             | `onCrispEvent` stream                                                                                    | [Chat Events](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/chat_events.html)               |
| Unread messages         | `getUnreadMessageCount`, `markMessagesAsRead` (Crisp REST API)                                           | [Unread Messages](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/unread_messages.html)       |
| iOS extras              | Presentation styles, video calls                                                                         | [iOS Features](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/ios_features.html)             |

## Push Notifications

Crisp sends push notifications through Firebase Cloud Messaging on Android and APNs on iOS. Setup takes four steps:

1. [Connect Firebase and upload your credentials to Crisp](https://alamin-karno.github.io/flutter-crisp-chat/notifications/firebase_setup.html)
2. [Register the notification service on Android](https://alamin-karno.github.io/flutter-crisp-chat/notifications/android.html)
3. [Enable push and register for remote notifications on iOS](https://alamin-karno.github.io/flutter-crisp-chat/notifications/ios.html)
4. [Open the chat when a notification is tapped](https://alamin-karno.github.io/flutter-crisp-chat/notifications/handling.html)

## Try the Example App

```bash
git clone https://github.com/alamin-karno/flutter-crisp-chat.git
cd flutter-crisp-chat/example
flutter run -d chrome --dart-define=websiteId=YOUR_WEBSITE_ID   # or -d macos, -d windows, -d linux
```

Running the example on Android or iOS also needs Firebase config files; the [contributing guide](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/CONTRIBUTING.md) explains how to add them.

Stuck? Check [common issues](https://alamin-karno.github.io/flutter-crisp-chat/troubleshooting/common_issues.html) and the [FAQ](https://alamin-karno.github.io/flutter-crisp-chat/reference/faq.html), or [open an issue](https://github.com/alamin-karno/flutter-crisp-chat/issues).

## Native SDK Versions

| SDK                | Version                                         |
|--------------------|-------------------------------------------------|
| Crisp Android SDK  | `2.0.25`                                        |
| Crisp iOS SDK      | `~> 3.1.1` (Swift Package Manager or CocoaPods) |
| Crisp Web Chat SDK | Loaded at runtime from `client.crisp.chat`      |
| Flutter / Dart     | `>= 3.44.0` / `>= 3.5.0`                        |

## Used By

- [Rokomari.com](https://rkmri.co/32ESMmTSAeIe/)
- [L'Algo de Paulo](https://lalgodepaulo.com/)

Using `crisp_chat` in production? [Open a pull request](https://github.com/alamin-karno/flutter-crisp-chat/edit/dev/README.md) to add your app here.

## Support the Project

If `crisp_chat` saves you time, you can help keep it maintained:

- ⭐ Star the [GitHub repository](https://github.com/alamin-karno/flutter-crisp-chat) and 👍 like it on [pub.dev](https://pub.dev/packages/crisp_chat)
- ☕ [Buy me a coffee](https://buymeacoffee.com/alaminkarno) or become a [Patreon supporter](https://patreon.com/alamin_karno)
- 🛠️ Contribute a fix or feature: start with the [contributing guide](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/CONTRIBUTING.md)

## Maintainer and Contributors

Maintained by [**Md. Al-Amin**](https://github.com/alamin-karno), with help from these contributors:

[![Contributors](https://contrib.rocks/image?repo=alamin-karno/flutter-crisp-chat)](https://github.com/alamin-karno/flutter-crisp-chat/graphs/contributors)

## Credits and License

The Crisp Android, iOS, and Web Chat SDKs are owned and maintained by [Crisp IM SAS](https://crisp.chat/). This plugin is an independent, community-maintained project.

Released under the [MIT License](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/LICENSE).
