---
head:
  - - meta
    - name: description
      content: Troubleshoot common issues with the Flutter Crisp Chat plugin — build errors, notifications, sessions, and runtime problems.

  - - meta
    - name: keywords
      content: "flutter crisp chat issues, crisp chat troubleshooting, crisp_chat build error, crisp chat not working"

prev:
  text: 'Changelog'
  link: '/reference/changelog'

next:
  text: 'Platform-Specific'
  link: '/troubleshooting/platform_specific'
---

# Common Issues

## Build Errors

### `compileSdkVersion` too low

```
ERROR: uses-sdk:minSdkVersion 21 cannot be smaller than version 23
```

**Fix:** Set `compileSdkVersion 36` and `minSdkVersion 23` in `android/app/build.gradle`.

### Missing Internet permission

```
java.net.SocketException: Permission denied
```

**Fix:** Add `<uses-permission android:name="android.permission.INTERNET"/>` to your `AndroidManifest.xml`.

### CocoaPods version conflict

```
CocoaPods could not find compatible versions for pod "Crisp"
```

**Fix:** Delete `ios/Podfile.lock` and run `pod install --repo-update` in the `ios/` directory.

### Firebase Messaging not found (SDK build)

```
error: package com.google.firebase.messaging does not exist
```

This happens if `firebase_messaging` is not in your app's dependencies. The SDK uses `compileOnly` for Firebase Messaging.

**Fix:** Ensure `firebase_messaging` is added to your `pubspec.yaml`:
```shell
flutter pub add firebase_messaging
```

## Notification Issues

### Not receiving notifications on Android

1. Verify the notification service is declared in `AndroidManifest.xml` (either `CrispNotificationService` or `CrispChatNotificationService`)
2. Check that Firebase credentials are configured in the Crisp dashboard
3. Ensure `enableNotifications: true` in `CrispConfig`
4. Verify `firebase_core` and `firebase_messaging` are in your dependencies

### Notification tap opens ChatActivity directly (unwanted)

You're using **Option A** (`CrispNotificationService`). Switch to **Option B** (`CrispChatNotificationService`) in your `AndroidManifest.xml`. See [Notification Handling](/notifications/handling).

### Notification tap does nothing (Option B)

Ensure you've added both handlers in your `initState`:

```dart
// Terminated state
FlutterCrispChat.openChatboxFromNotification();

// Background state
FlutterCrispChat.setOnNotificationTappedCallback(() {
  FlutterCrispChat.openChatboxFromNotification();
});
```

### iOS notifications not received in development

Crisp push notifications on iOS currently only work with **production APNs channels**. Development/sandbox provisioning profiles won't receive notifications.

## Session Issues

### `getSessionIdentifier` returns null

The session ID is only available after `openCrispChat` has been called. The plugin caches the ID internally, so it may return a cached value even after the chat is closed.

### `getUnreadMessageCount` returns null

Possible causes:
- No active session (user hasn't opened the chat yet)
- Invalid API credentials (`identifier` and `key`)
- Network error
- The `websiteId` doesn't match your Crisp workspace

### `ArgumentError` when opening chat

The plugin validates `email` and `company URL` formats. Ensure:
- Email follows standard format (e.g., `user@example.com`)
- Company URL is a valid absolute URL (e.g., `https://example.com`)

## Runtime Issues

### Chat not opening

1. Verify your `websiteID` is correct (copy from Crisp dashboard)
2. Check that `websiteID` is not empty
3. Ensure the device has internet connectivity
4. Check the debug console for error messages

### Session data not appearing in Crisp dashboard

- Call `setSessionString`/`setSessionInt`/`setSessionSegments` **before** `openCrispChat`
- Ensure key names are not empty
- Check that the values are being set (no exceptions thrown)

## Still Stuck?

- Check [Platform-Specific Issues](/troubleshooting/platform_specific)
- [Open an issue on GitHub](https://github.com/alamin-karno/flutter-crisp-chat/issues)
- See the [Crisp Help Center](https://help.crisp.chat/en/) for Crisp-specific questions
