---
head:
  - - meta
    - name: description
      content: Platform support matrix for flutter-crisp-chat — Android, iOS, Web, macOS, Windows, Linux, and optional iOS video calls.

  - - meta
    - name: keywords
      content: "flutter crisp chat web, crisp chat desktop, flutter crisp platforms"

prev:
  text: 'Platform Setup'
  link: '/getting_started/platform_setup'

next:
  text: 'Quick Start'
  link: '/getting_started/quick_start'
---

# Supported platforms

`crisp_chat` supports the following Flutter targets:

| Platform    | Integration                                   | Notes                                                                                                                                                  |
|-------------|-----------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Android** | Official Crisp Android SDK (method channel)   | Push notifications, native chat UI                                                                                                                     |
| **iOS**     | Official Crisp iOS SDK (method channel)       | Push notifications, modal presentation styles; optional video via `CrispWebRTC` ([setup](/getting_started/platform_setup#enable-video-calls-ios-only)) |
| **Web**     | Official Crisp Web Chat SDK (`$crisp` via JS) | Same Dart API; no mobile push helpers                                                                                                                  |
| **macOS**   | Crisp Web SDK in a desktop WebView window     | Requires [WebKit](https://developer.apple.com/documentation/webkit) (system)                                                                           |
| **Windows** | WebView2 window, or browser fallback          | Install [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/) for embedded chat                                                 |
| **Linux**   | WebKitGTK WebView window, or browser fallback | Install `libwebkit2gtk-4.1-dev` (or 4.0) for embedded chat                                                                                             |

## API availability by platform

| API                                  | Mobile                    | Web             | Desktop                  |
|--------------------------------------|---------------------------|-----------------|--------------------------|
| `openCrispChat`                      | Yes                       | Yes             | Yes (WebView or browser) |
| `resetCrispChatSession`              | Yes                       | Yes             | Yes (WebView only)       |
| `setSessionString` / `setSessionInt` | Yes                       | Yes             | Yes (WebView only)       |
| `setSessionSegments`                 | Yes                       | Yes             | Yes (WebView only)       |
| `pushSessionEvent`                   | Yes                       | Yes             | Yes (WebView only)       |
| `getSessionIdentifier`               | Yes                       | Yes             | Yes (WebView only)       |
| `getUnreadMessageCount`              | Yes                       | Yes*            | Yes*                     |
| `markMessagesAsRead`                 | Yes                       | Yes*            | Yes*                     |
| `openChatboxFromNotification`        | Android (primarily)       | No-op (`false`) | No-op (`false`)          |
| `setOnNotificationTappedCallback`    | Android                   | No-op           | No-op                    |
| `CrispConfig.modalPresentationStyle` | iOS only                  | Ignored         | Ignored                  |
| `CrispConfig.enableNotifications`    | Android/iOS native        | Ignored         | Ignored                  |
| `isVideoCallsSupported()`            | iOS (opt-in WebRTC build) | No (upstream)   | Yes (web widget)         |

\* REST helpers need a session id from `getSessionIdentifier()`. Do not embed Crisp REST API secrets in client-side web builds; use a backend proxy in production.

## Video and audio calls

| Platform    | Native video/audio calls | How to enable                                                                                                                                                                                              |
|-------------|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **iOS**     | Yes (opt-in)             | **CocoaPods:** `$CrispChatWebRTC = true` in `ios/Podfile`. **SPM:** `CRISP_CHAT_WEBRTC=true flutter build ios`. Adds ~10 MB. See [Platform setup — Enable video calls](/getting_started/platform_setup#enable-video-calls-ios-only). |
| **Android** | Not yet                  | [Crisp Android SDK #181](https://github.com/crisp-im/crisp-sdk-android/issues/181) — no WebRTC variant exists today.                                                                                       |
| **Web**     | Via web chatbox          | Enable in Crisp dashboard; browser WebRTC handles calls.                                                                                                                                                   |
| **Desktop** | Via web chatbox          | Same as Web when using embedded WebView.                                                                                                                                                                   |

Use `FlutterCrispChat.isVideoCallsSupported()` to check whether the **current build** supports calls (iOS WebRTC variant, or Web/desktop).

## Desktop setup

### macOS sandbox (required for embedded chat)

If your app uses the **App Sandbox**, enable **Outgoing Connections (Client)** so the WebView can load `https://client.crisp.chat/l.js`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

Add this to `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`. Without it, the chat window stays blank.

The plugin loads embed HTML from a temporary `file://` page (not `data:`), because WKWebView blocks external scripts on `data:` URLs.

### Example app (`desktop_webview_window`)

If you use embedded chat on desktop, add this to your app `main` (see the [example app](https://github.com/alamin-karno/flutter-crisp-chat/tree/main/example)):

```dart
import 'package:desktop_webview_window/desktop_webview_window.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (runWebViewTitleBarWidget(args)) {
    return;
  }
  runApp(const MyApp());
}
```

### Linux system packages

```bash
sudo apt install libwebkit2gtk-4.1-dev
```

## Run the example

```bash
cd example
flutter pub get

# Web
flutter run -d chrome --dart-define=websiteId=YOUR_WEBSITE_ID

# Desktop (after setup in this guide)
flutter run -d macos --dart-define=websiteId=YOUR_WEBSITE_ID
flutter run -d windows --dart-define=websiteId=YOUR_WEBSITE_ID
flutter run -d linux --dart-define=websiteId=YOUR_WEBSITE_ID

# Mobile (requires Firebase config files — see Contributing)
flutter run --dart-define-from-file=lib/config.json
```

## Web setup

No extra native setup. The plugin loads `https://client.crisp.chat/l.js` when you call `openCrispChat`.

If you use a strict Content-Security-Policy, allow scripts and connections to `https://client.crisp.chat` and `https://*.crisp.chat`.

## Crisp dashboard: domain lock

**Lock the chatbox to website domain (and subdomains)** is under **Settings** → **Website Settings** → **Chatbox & Email Settings** → **Chatbox Security**. Behavior by platform:

- **Android / iOS** — disable domain lock (native SDK has no browser origin).
- **Web** — can stay enabled if your app is served from an allowed domain or subdomain.
- **Desktop** — disable domain lock (embedded WebView uses `file://`; browser fallback opens `app.crisp.chat`).

Full details: [Configuration — Chatbox Security](/core_feature/configuration#crisp-dashboard-chatbox-security).

## Minimum versions

- **Dart SDK**: 3.5.0+
- **Flutter**: 3.24.0+
- **Android**: API 23+ (unchanged)
- **iOS**: 13.0+ (unchanged)

## Next Steps

- [Quick Start](/getting_started/quick_start) — Open your first chat in 5 minutes
- [Configuration](/core_feature/configuration) — Customize `CrispConfig` with user details, tokens, and segments
