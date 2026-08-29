---
head:
  - - meta
    - name: description
      content: Configure Android, iOS, Web, and desktop platform settings for the Flutter Crisp Chat plugin.

  - - meta
    - name: keywords
      content: "flutter crisp chat android setup, flutter crisp chat ios setup, crisp chat platform configuration"

prev:
  text: 'Installation'
  link: '/getting_started/install'

next:
  text: 'Supported Platforms'
  link: '/getting_started/supported_platforms'
---

# Platform Setup

After installing the `crisp_chat` package, configure settings for the targets you ship. **Web and desktop** need little or no native setup; **Android and iOS** need the steps below. Push notification setup is **mobile-only** — see [Firebase Setup](/notifications/firebase_setup).

## Enable Flutter targets

If your project was created before adding Web or desktop, enable the platforms you need:

```bash
flutter create . --platforms=web,macos,windows,linux
```

See the [API availability matrix](/getting_started/supported_platforms#api-availability-by-platform) for behavior differences per platform.

## Android

### 1. Internet Permission

Add Internet permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 2. Compile SDK Version

Set `compileSdkVersion` to 36 (or higher) in `android/app/build.gradle`:

```groovy
android {
    compileSdkVersion 36
}
```

### 3. Minimum SDK Version

Set `minSdkVersion` to 23 (or higher) in `android/app/build.gradle`:

```groovy
defaultConfig {
    minSdkVersion 23
}
```

### 4. FileProvider (Optional)

If your app already declares a `FileProvider` in `AndroidManifest.xml`, add Crisp's authority and path for the file upload feature:

```xml
<provider android:name="androidx.core.content.FileProvider"
  android:authorities="${applicationId}.fileprovider;${applicationId}.im.crisp.client.uploadfileprovider"
  android:exported="false"
  android:grantUriPermissions="true"
  tools:replace="android:authorities">
  <meta-data android:name="android.support.FILE_PROVIDER_PATHS"
    android:resource="@xml/file_paths"
    tools:replace="android:resource" />
</provider>
```

And in `res/xml/file_paths.xml`:

```xml
<files-path name="crisp_sdk_attachments" path="im.crisp.client/attachments/" />
```

## iOS

### 1. Privacy Permissions

Add the following keys to `ios/Runner/Info.plist` for camera, photo library, and microphone access (required by the Crisp SDK for file uploads and media):

```xml
<key>NSCameraUsageDescription</key>
<string>Used to take photos for chat attachments</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Used to save photos from chat</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used for voice messages in chat</string>
```

### 2. Minimum Deployment Target

The Crisp iOS SDK requires iOS 13.0+. Ensure your `ios/Podfile` has:

```ruby
platform :ios, '13.0'
```

### Enable video calls (iOS only) {#enable-video-calls-ios-only}

Video and audio calls require the **`Crisp/CrispWebRTC`** CocoaPods subspec (or SPM product **`CrispWebRTC`**) instead of the default **`Crisp/Crisp`** / **`Crisp`** library. Both expose the same Swift API (`import CrispWebRTC` vs `import Crisp`); the WebRTC variant adds roughly **10 MB** to your iOS binary.

This is a **build-time** choice — there is no `CrispConfig` runtime flag. Check support with `FlutterCrispChat.isVideoCallsSupported()`.

When enabled, update the microphone usage description in `ios/Runner/Info.plist` to cover calls (camera and photo keys from step 1 are still required):

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used for video and audio calls in chat</string>
```

#### CocoaPods (Podfile)

Add the following to your `ios/Podfile` **before** `flutter_install_all_ios_pods`:

```ruby
$CrispChatWebRTC = true
```

Then reinstall pods:

```bash
cd ios && rm -f Podfile.lock && pod install --repo-update && cd ..
```

#### Swift Package Manager (Flutter 3.24+, default in Flutter 3.44+)

When your app uses SPM (`flutter config --enable-swift-package-manager`, or enabled by default on newer Flutter), set an environment variable **before** building:

```bash
CRISP_CHAT_WEBRTC=true flutter build ios
# or
CRISP_CHAT_WEBRTC=true flutter run
```

Alternatively, add `CRISP_CHAT_WEBRTC` = `true` under **Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables** in Xcode.

The plugin's [`ios/crisp_chat/Package.swift`](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/ios/crisp_chat/Package.swift) selects the `CrispWebRTC` product and defines `CRISP_WEBRTC` automatically when this variable is set. No manual edit of `Package.swift` is required.

After changing the video setting, run a clean build (`flutter clean && flutter pub get`) so SPM/CocoaPods re-resolve dependencies.

**Limitations:**

- **Android:** native video/audio calls are [not supported yet](https://github.com/crisp-im/crisp-sdk-android/issues/181) by the Crisp Android SDK.
- **Mac Catalyst:** Crisp calls are not supported.
- **WebRTC conflicts:** if your app embeds another WebRTC library, you may hit symbol or module conflicts ([crisp-sdk-ios#103](https://github.com/crisp-im/crisp-sdk-ios/issues/103)).

**Web / desktop:** video calls work through the web chatbox when enabled in your Crisp dashboard — no extra native setup.

## Crisp dashboard (Android & iOS)

Before opening chat on native mobile targets:

- Disable **Lock the chatbox to website domain (and subdomains)** under **Settings** → **Website Settings** → **Chatbox & Email Settings** → **Chatbox Security**. See [Configuration — Chatbox Security](/core_feature/configuration#crisp-dashboard-chatbox-security).

## Web

No native Crisp SDK install. When you call `openCrispChat`, the plugin loads the official script from `https://client.crisp.chat/l.js` and opens the Crisp chatbox in the page.

1. Ensure **Web** is enabled for your app (`flutter create . --platforms=web` if needed).
2. Use a valid **Website ID** from the [Crisp Dashboard](https://app.crisp.chat/).
3. **Identity verification:** only set `User.signature` when it is a real HMAC-SHA256 hex string from your server (32+ hex characters). Fake placeholders can leave the chat on the loading skeleton.
4. **Content-Security-Policy (optional):** if your site uses CSP, allow scripts and connections to `https://client.crisp.chat` and `https://*.crisp.chat`.
5. **REST API on web:** `getUnreadMessageCount` / `markMessagesAsRead` accept credentials in Dart; those values are visible in the browser — use a **backend proxy** in production.
6. **Domain lock (optional):** if **Lock the chatbox to website domain** is enabled, host the app on an allowed domain or subdomain and verify the page origin if chat fails to connect. See [Configuration — Chatbox Security](/core_feature/configuration#crisp-dashboard-chatbox-security).

`openChatboxFromNotification`, `setOnNotificationTappedCallback`, `CrispConfig.enableNotifications`, and `modalPresentationStyle` have no effect on Web.

More detail: [Supported Platforms — Web](/getting_started/supported_platforms#web-setup).

## Desktop (macOS, Windows, Linux)

Desktop uses the same Crisp Web Chat SDK inside an embedded window (`desktop_webview_window`), or opens the system browser if WebView is unavailable.

### 1. `main()` — title bar helper (embedded WebView)

Add this **before** `runApp` when you target desktop:

```dart
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    if (runWebViewTitleBarWidget(args)) {
      return;
    }
  }

  runApp(const MyApp());
}
```

### 2. macOS — network entitlement (embedded chat)

If your macOS app uses the **App Sandbox**, enable **Outgoing Connections (Client)** in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

Without this, the WebView stays blank. The plugin loads embed HTML from a temporary `file://` page so external `l.js` can load (WKWebView blocks scripts on `data:` URLs).

### 3. Windows — WebView2

Install the [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/) for an embedded chat window. Without it, chat opens in the default browser.

### 4. Linux — WebKitGTK

```bash
sudo apt install libwebkit2gtk-4.1-dev
```

(Or `libwebkit2gtk-4.0-dev` on older distributions.)

### 5. Domain lock

Disable **Lock the chatbox to website domain** for desktop chat:

- **Embedded WebView** loads chat from a temporary `file://` page — there is no website origin to match (same constraint as mobile).
- **Browser fallback** opens `https://app.crisp.chat/website/{id}/`, which also conflicts with domain lock.

See [Configuration — Chatbox Security](/core_feature/configuration#crisp-dashboard-chatbox-security).

### Browser fallback

When WebView is unavailable, `openCrispChat` opens Crisp in the system browser. In that mode, `resetCrispChatSession`, session setters, and `getSessionIdentifier` are no-ops or return `null` because there is no embedded bridge.

More detail: [Supported Platforms — Desktop](/getting_started/supported_platforms#desktop-setup).

## Next Steps

- [Supported Platforms](/getting_started/supported_platforms) — Platform support matrix for Android, iOS, Web, and desktop
- [Quick Start](/getting_started/quick_start) — Open your first chat in 5 minutes

For push notification setup (Firebase, APNs) on **Android and iOS only**, see [Firebase Setup](/notifications/firebase_setup).
