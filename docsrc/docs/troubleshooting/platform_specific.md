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

### CocoaPods vs Swift Package Manager

The plugin supports both CocoaPods and Swift Package Manager (SPM) for iOS dependency management. If you encounter issues with one, try the other:

- **CocoaPods:** Default for most Flutter projects. Uses `ios/crisp_chat.podspec`.
- **SPM:** Available since version `2.4.2`. Uses `ios/crisp_chat/Package.swift`.

## Need More Help?

- [Open an issue on GitHub](https://github.com/alamin-karno/flutter-crisp-chat/issues)
- [Crisp Help Center](https://help.crisp.chat/en/)
- [Crisp Android SDK docs](https://docs.crisp.chat/guides/chatbox-sdks/android-sdk/)
- [Crisp iOS SDK docs](https://docs.crisp.chat/guides/chatbox-sdks/ios-sdk/)
