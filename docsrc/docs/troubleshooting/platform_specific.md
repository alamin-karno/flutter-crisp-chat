---
head:
  - - meta
    - name: description
      content: Platform-specific troubleshooting for Flutter Crisp Chat — Android and iOS specific issues and solutions.

  - - meta
    - name: keywords
      content: "crisp chat android issues, crisp chat ios issues, flutter crisp platform troubleshooting"

prev:
  text: 'Common Issues'
  link: '/troubleshooting/common_issues'

next:
  text: 'Contributing'
  link: '/community/contributing'
---

# Platform-Specific Issues

## Android

### FileProvider conflict

If your app already declares a `FileProvider`, you may see:

```
Manifest merger failed: Attribute provider#androidx.core.content.FileProvider@authorities
```

**Fix:** Merge the Crisp authority into your existing FileProvider declaration:

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

And add to `res/xml/file_paths.xml`:

```xml
<files-path name="crisp_sdk_attachments" path="im.crisp.client/attachments/" />
```

### ProGuard / R8 issues

If you're using code shrinking and encounter crashes, ensure ProGuard rules for Crisp are included. The Crisp SDK typically bundles its own rules, but if issues persist, add:

```proguard
-keep class im.crisp.client.** { *; }
```

### Camera crash on some devices

Some devices (especially Xiaomi/Redmi) may crash when using the camera feature. Ensure you're using Crisp Android SDK `2.0.5` or later, which includes a fix for this.

### Mailto links not working

On some devices (Xiaomi/Redmi, Android 12+), `mailto:` links in the chat may fail to open the email app. This was fixed in version `2.3.0` ([#57](https://github.com/alamin-karno/flutter-crisp-chat/issues/57)).

### Keyboard pushes view up

If the keyboard pushes the chat view up unexpectedly, ensure you're using Crisp Android SDK `2.0.11` or later. Fixed in version `2.2.5` ([#45](https://github.com/alamin-karno/flutter-crisp-chat/issues/45)).

## iOS

### Minimum deployment target error

```
The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 11.0, but the range of supported deployment target versions is 13.0 to 18.0
```

**Fix:** Update your `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

Then delete `ios/Podfile.lock` and run `pod install --repo-update`.

### Push notifications not working in development

Crisp iOS push notifications only work with **production APNs**. They will not be received when using development provisioning profiles or sandbox mode.

### Missing privacy permissions

If the app crashes when the user tries to take a photo or access the camera in chat:

**Fix:** Add the required keys to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Used to take photos for chat attachments</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Used to save photos from chat</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used for voice messages in chat</string>
```

### Reset session crash on iOS

If `resetCrispChatSession` crashes on iOS, ensure you're using version `2.0.9` or later, which fixed this issue ([#20](https://github.com/alamin-karno/flutter-crisp-chat/issues/20)).

### iOS unread count not clearing

After opening chat, reading all operator messages, and closing the UI, `getUnreadMessageCount()` may still return a non-zero value. A direct `GET /v1/website/{website_id}/conversation/{session_id}` shows the same stale `unread.visitor` — this is a **Crisp iOS SDK limitation** (read receipts not synced to the server).

**Workaround:**

```dart
await FlutterCrispChat.markMessagesAsRead(
  websiteId: websiteId,
  identifier: identifier,
  key: key,
);
```

**Verify:** Run `./scripts/verify_unread_read_receipts.sh full` with your REST credentials. If manual `PATCH /read` clears the count but reading in chat does not, file an issue using [docs/crisp-sdk-ios-unread-issue.md](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/docs/crisp-sdk-ios-unread-issue.md).

Compare with Android using the same REST GET steps — if Android clears `unread.visitor` after reading but iOS does not, the bug is iOS-specific.

### CocoaPods vs Swift Package Manager

The plugin supports both CocoaPods and Swift Package Manager (SPM) for iOS dependency management.

- **CocoaPods:** Uses [`ios/crisp_chat.podspec`](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/ios/crisp_chat.podspec). Still used when SPM is off, or when Flutter falls back for plugins without SPM support.
- **SPM:** Uses [`ios/crisp_chat/Package.swift`](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/ios/crisp_chat/Package.swift) and sources in `ios/crisp_chat/Sources/crisp_chat/`.

**Enabling SPM**

- Flutter **3.24+:** `flutter config --enable-swift-package-manager`, then `flutter run` / `flutter build ios` (Flutter migrates the Xcode project automatically).
- Flutter **3.44+:** SPM is the **default** for iOS/macOS. Flutter uses SPM for plugins that ship a `Package.swift`; others fall back to CocoaPods with a warning.
- Disable per project: `flutter: config: enable-swift-package-manager: false` in `pubspec.yaml`.

**Video calls with SPM**

Set `CRISP_CHAT_WEBRTC=true` before building (or in the Xcode scheme). See [Enable video calls (iOS only)](/getting_started/platform_setup#enable-video-calls-ios-only).

**Flutter framework dependency**

Flutter injects the Flutter framework when building through the CLI (pre-action script + local package overrides). Plugin `Package.swift` files do not hardcode a FlutterFramework path — same pattern as first-party Flutter plugins.

If SPM resolution fails, try `flutter clean`, delete `ios/Flutter/ephemeral`, and rebuild. See [Flutter SPM docs for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers).

### Target Integrity: Firebase requires iOS 15.0 but target supports 13.0

**Symptom:** Xcode error when using SPM:

```text
The package product 'firebase-core' requires minimum platform version 15.0 for the iOS platform, but this target supports 13.0
```

**Cause:** `firebase_core` / `firebase_messaging` (and recent Firebase iOS SDKs) require **iOS 15.0+** when resolved via Swift Package Manager. The app or Xcode project may still declare **13.0** (the minimum for Crisp alone).

**Fix:**

1. Set **iOS Deployment Target** to **15.0** or higher in Xcode (**Runner** target → **General** → **Minimum Deployments**).
2. Update `ios/Podfile`: `platform :ios, '15.0'`
3. In `ios/Runner.xcodeproj/project.pbxproj`, set `IPHONEOS_DEPLOYMENT_TARGET = 15.0` for Debug, Release, and Profile.
4. Regenerate config: `flutter clean && flutter pub get && cd ios && pod install && cd ..`

`crisp_chat` itself still supports iOS **13.0+** when you do not use Firebase. If your app includes Firebase push notifications, use **iOS 15.0+** as the app minimum.

## Web

### Chat stuck on loading spinner (skeleton UI)

The gray/blue placeholder bars mean the chat **shell** opened but the **session** did not connect.

1. Confirm `websiteID` is correct.
2. **Identity verification:** only pass `User.signature` when it is a real HMAC-SHA256 hex string from your server (at least 32 hex characters). Placeholder values are ignored by the plugin; if you set a fake signature manually, Crisp may stay on the skeleton screen.
3. Allow **third-party cookies** for `crisp.chat` in Chrome (Settings → Privacy → third-party cookies). Crisp needs cookies for the visitor session.
4. Check DevTools → **Network** for failed requests to `client.crisp.chat` or `storage.crisp.chat`.
5. Hard-refresh the page (`Cmd+Shift+R`) after upgrading the plugin so `l.js` is not cached from an old run.

### Domain lock enabled

If **Lock the chatbox to website domain** is enabled in the Crisp dashboard:

- **Symptom:** skeleton UI / session never connects
- **Check:** run `window.location.origin` in DevTools and compare with allowed domains in the dashboard
- **Fix:** add the origin to the lock list, disable domain lock, or deploy to an allowed host

See [Configuration — Chatbox Security](/core_feature/configuration#crisp-dashboard-chatbox-security).

### Chat does not appear

1. Confirm `openCrispChat` was called with a valid `websiteID`.
2. If you use a Content-Security-Policy, allow `https://client.crisp.chat` and Crisp API hosts.
3. Check the browser console for blocked scripts.

### REST API keys in web builds

`getUnreadMessageCount` and `markMessagesAsRead` use your Crisp REST credentials from Dart. On Web, those values are visible to users — prefer a backend proxy for production.

## Desktop (macOS, Windows, Linux)

### Domain lock enabled

If **Lock the chatbox to website domain** is enabled in the Crisp dashboard:

- **Embedded WebView** loads chat from a temporary `file://` page — disable domain lock (same as mobile).
- **Browser fallback** opens `https://app.crisp.chat/website/{id}/`, which is also incompatible with domain lock — install WebView2 (Windows) or WebKitGTK (Linux) for embedded chat instead.

See [Configuration — Chatbox Security](/core_feature/configuration#crisp-dashboard-chatbox-security).

### Embedded WebView does not open

- **Windows:** Install the [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/).
- **Linux:** Install WebKitGTK (`libwebkit2gtk-4.1-dev` or `libwebkit2gtk-4.0-dev`).
- If WebView is unavailable, the plugin opens Crisp in the system browser instead.

### Session APIs return null after browser fallback

`resetCrispChatSession`, `setSessionString`, and `getSessionIdentifier` require an active desktop WebView. They are no-ops (or return `null`) when chat was opened in an external browser.

### `runWebViewTitleBarWidget` in `main`

When using `desktop_webview_window`, add the title-bar helper to your app `main` — see [Supported platforms](/getting_started/supported_platforms).

## Need More Help?

- [Open an issue on GitHub](https://github.com/alamin-karno/flutter-crisp-chat/issues)
- [Crisp Help Center](https://help.crisp.chat/en/)
- [Crisp Android SDK docs](https://docs.crisp.chat/guides/chatbox-sdks/android-sdk/)
- [Crisp iOS SDK docs](https://docs.crisp.chat/guides/chatbox-sdks/ios-sdk/)
