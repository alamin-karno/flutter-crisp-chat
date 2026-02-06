---
head:
  - - meta
    - name: description
      content: Configure Android and iOS platform settings for the Flutter Crisp Chat plugin.

  - - meta
    - name: keywords
      content: "flutter crisp chat android setup, flutter crisp chat ios setup, crisp chat platform configuration"

prev:
  text: 'Installation'
  link: '/getting_started/install'

next:
  text: 'Quick Start'
  link: '/getting_started/quick_start'
---

# Platform Setup

After installing the `crisp_chat` package, you need to configure platform-specific settings for Android and iOS.

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

## Next Steps

With platform setup complete, you're ready to open your first chat. See [Quick Start](/getting_started/quick_start).

For push notification setup (Firebase, APNs), see [Firebase Setup](/notifications/firebase_setup).
