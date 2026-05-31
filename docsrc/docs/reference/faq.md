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

**Android and iOS** use the official native Crisp SDKs (method channel). **Web** uses the official Crisp Web Chat SDK (`$crisp`). **macOS, Windows, and Linux** embed the same web chatbox in a desktop WebView (with a browser fallback when WebView is unavailable).

See [Supported platforms](/getting_started/supported_platforms) for the full API matrix, desktop dependencies, and security notes for REST helpers on web.

### What is the minimum Flutter version required?

- **Web and desktop (2.5.0+):** Flutter **3.24.0+**, Dart **3.5.0+**
- **Mobile-only usage:** Flutter 3.0+, Dart 2.15.0+ may still work; Android API 23+, iOS 13.0+

### Is this an official Crisp plugin?

No. This is a community-maintained Flutter plugin created by [Md. Al-Amin](https://github.com/alamin-karno). It wraps the official **native** Crisp SDKs on mobile and the official **Web Chat SDK** on Web/desktop.

### Do push notifications work on Web or desktop?

No. FCM/APNs setup in the docs applies to **Android and iOS** only. `openChatboxFromNotification` and `setOnNotificationTappedCallback` are no-ops on Web and desktop.

### Do I need Firebase for Web or desktop?

No. Firebase is only required if you test **mobile push notifications** in the example app. For Web/desktop, run with `--dart-define=websiteId=YOUR_ID` only.

### Where do I get my Website ID?

Go to your [Crisp Dashboard](https://app.crisp.chat/) > **Settings** > **Website Settings** and copy your Website ID.

## Configuration

### Why does chat show "Error starting chat" even with a valid Website ID?

On **Android and iOS**, **Lock the chatbox to website domain (and subdomains)** must be **disabled** in the Crisp dashboard. Domain lock validates browser origins; the native mobile SDK has no matching origin, so the session is rejected. Logs may show a misleading `invalid_website_id` WebSocket error even though REST `GET /v1/website/{id}` still returns 200.

Disable the setting under **Settings** → **Website Settings** → **Chatbox & Email Settings** → **Chatbox Security**, restart the app, and try again. See [Configuration — Chatbox Security](/core_feature/configuration#crisp-dashboard-chatbox-security) and [Common Issues — Chat not opening](/troubleshooting/common_issues#chat-not-opening).

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

Only if you use **Android/iOS push notifications** with Crisp. Web and desktop do not use Firebase for chat. Even on mobile, the Crisp SDK handles notification display; you still need `firebase_core` and `firebase_messaging` for initialization and permission handling.

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

### Why does `getUnreadMessageCount` stay non-zero on iOS after reading chat?

The Crisp iOS SDK may not send read receipts to the server. Call `markMessagesAsRead()` after the visitor closes chat. See [Unread Messages — iOS limitation](/core_feature/unread_messages#ios-limitation-unread-count-not-clearing-after-reading-chat).

## Sessions

### Why does `getSessionIdentifier` return null?

The session identifier is only available after `openCrispChat` has been called and the chat has been initialized. The plugin caches the session ID internally, so subsequent calls may return the cached value even after the chat is closed.

### Can I set session data before opening the chat?

Yes. Call `setSessionString`, `setSessionInt`, and `setSessionSegments` before `openCrispChat`. The data will be associated with the session when it's created.

## Still Have Questions?

- [Open an issue on GitHub](https://github.com/alamin-karno/flutter-crisp-chat/issues)
- Check the [Troubleshooting](/troubleshooting/common_issues) page
- See the [Crisp Help Center](https://help.crisp.chat/en/) for Crisp-specific questions
