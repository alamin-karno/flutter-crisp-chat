---
head:
  - - meta
    - name: description
      content: Frequently asked questions about the Flutter Crisp Chat plugin — setup, notifications, sessions, and troubleshooting.

  - - meta
    - name: keywords
      content: "flutter crisp chat faq, crisp chat questions, crisp_chat help, crisp chat flutter troubleshooting"

prev:
  text: 'Full Example'
  link: '/reference/examples'

next:
  text: 'Changelog'
  link: '/reference/changelog'
---

# FAQ

## General

### What platforms does this plugin support?

Android and iOS. The plugin wraps the official Crisp Android SDK (`2.0.17`) and Crisp iOS SDK (`~> 2.13.0`).

### What is the minimum Flutter version required?

Flutter 3.0+ with Dart 2.15.0+. Android requires API 23+ (Android 6.0) and iOS requires 13.0+.

### Is this an official Crisp plugin?

No. This is a community-maintained Flutter plugin created by [Md. Al-Amin](https://github.com/alamin-karno). It wraps the official native Crisp SDKs.

### Where do I get my Website ID?

Go to your [Crisp Dashboard](https://app.crisp.chat/) > **Settings** > **Website Settings** and copy your Website ID.

## Configuration

### What is `tokenId` used for?

The `tokenId` identifies returning users. When a user opens the chat with the same `tokenId`, Crisp restores their previous conversation. Use a stable unique identifier like your app's user ID.

### Do I need to set user details?

No. All fields in `User` and `Company` are optional. If you don't set them, the user appears as anonymous in the Crisp dashboard.

### When should I call `resetCrispChatSession`?

Call it when your app user **logs out**. This clears the chat session so the next user doesn't see the previous user's conversation history.

## Push Notifications

### What's the difference between Option A and Option B for Android notifications?

- **Option A** (`CrispNotificationService`): Tapping a notification auto-opens the Crisp ChatActivity directly. Zero Flutter code needed.
- **Option B** (`CrispChatNotificationService`): Tapping a notification opens your app first. You then call `openChatboxFromNotification()` to open the chatbox when ready.

### Do iOS notifications work in development/sandbox mode?

Currently, Crisp push notifications on iOS are only sent to **production APNs channels**. They will not work with development provisioning profiles or sandbox mode.

### Why am I not receiving notifications on Android?

1. Ensure you've declared the notification service in `AndroidManifest.xml`
2. Verify your Firebase credentials are configured in the Crisp dashboard
3. Check that `enableNotifications: true` is set in `CrispConfig`
4. Make sure `firebase_messaging` is added to your project

### Do I need `firebase_messaging` in my app?

Yes. Even though the Crisp SDK handles the notification display, you need `firebase_core` and `firebase_messaging` in your Flutter project for Firebase initialization and permission handling.

## Unread Messages

### How do I get the unread message count?

Use `FlutterCrispChat.getUnreadMessageCount()` with your Website ID and Crisp REST API credentials. See [Unread Messages](/core_feature/unread_messages) for details.

### Where do I get the API `identifier` and `key`?

These come from the [Crisp Marketplace](https://marketplace.crisp.chat/), not your regular Crisp dashboard login. You need to create a plugin and get development tokens. See [Unread Messages](/core_feature/unread_messages#obtaining-api-credentials).

### Why does `getUnreadMessageCount` return null?

It returns `null` if:
- No active session exists (the user hasn't opened the chat yet)
- The API credentials are invalid
- A network error occurred

## Sessions

### Why does `getSessionIdentifier` return null?

The session identifier is only available after `openCrispChat` has been called and the chat has been initialized. The plugin caches the session ID internally, so subsequent calls may return the cached value even after the chat is closed.

### Can I set session data before opening the chat?

Yes. Call `setSessionString`, `setSessionInt`, and `setSessionSegments` before `openCrispChat`. The data will be associated with the session when it's created.

## Still Have Questions?

- [Open an issue on GitHub](https://github.com/alamin-karno/flutter-crisp-chat/issues)
- Check the [Troubleshooting](/troubleshooting/common_issues) page
- See the [Crisp Help Center](https://help.crisp.chat/en/) for Crisp-specific questions
