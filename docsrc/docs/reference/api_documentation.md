---
head:
  - - meta
    - name: description
      content: Complete API reference for the Flutter Crisp Chat plugin — all methods, parameters, return types, and exceptions.

  - - meta
    - name: keywords
      content: "flutter crisp chat api, crisp_chat api reference, FlutterCrispChat methods, crisp chat dart api"

prev:
  text: 'Notification Handling'
  link: '/notifications/handling'

next:
  text: 'Full Example'
  link: '/reference/examples'
---

# API Documentation

Complete reference for all public methods in the `FlutterCrispChat` class.

## Platform support

| API                                                         | Android / iOS       | Web           | Desktop            |
|-------------------------------------------------------------|---------------------|---------------|--------------------|
| `openCrispChat`                                             | Native SDK UI       | Web chatbox   | WebView or browser |
| `resetCrispChatSession`                                     | Yes                 | Yes           | WebView only       |
| `setSessionString` / `setSessionInt` / `setSessionSegments` | Yes                 | Yes           | WebView only       |
| `pushSessionEvent`                                          | Yes                 | Yes           | WebView only       |
| `getSessionIdentifier`                                      | Yes                 | Yes           | WebView only       |
| `getUnreadMessageCount` / `markMessagesAsRead`              | Yes                 | Yes*          | Yes*               |
| `openHelpdesk`                                              | Native SDK UI       | Web chatbox   | WebView or browser |
| `openHelpdeskArticle`                                       | Native SDK UI       | Web chatbox   | WebView or browser |
| `openChatboxFromNotification`                               | Android (primarily) | No-op         | No-op              |
| `setOnNotificationTappedCallback`                           | Android             | No-op         | No-op              |
| `isVideoCallsSupported`                                     | iOS (opt-in WebRTC) | No (upstream) | Yes (web widget)   |

\* Prefer a backend proxy for REST credentials on Web. See [Supported Platforms](/getting_started/supported_platforms).

## FlutterCrispChat

All methods are `static` on the `FlutterCrispChat` class.

```dart
import 'package:crisp_chat/crisp_chat.dart';
```

---

### openCrispChat

Opens Crisp chat: **native UI** on Android/iOS, **web chatbox** on Web, **embedded WebView** (or browser fallback) on desktop.

```dart
static Future<void> openCrispChat({required CrispConfig config})
```

| Parameter | Type          | Required | Description                                              |
|-----------|---------------|----------|----------------------------------------------------------|
| `config`  | `CrispConfig` | Yes      | Configuration object with website ID, user details, etc. |

**Throws:**
- `ArgumentError` if `config.user.email` is provided but invalid
- `ArgumentError` if `config.user.company.url` is provided but invalid

**Behavior:** After opening the chat, the method waits 3 seconds and then caches the session identifier internally.

---

### resetCrispChatSession

Resets the current chat session and clears cached data.

```dart
static Future<void> resetCrispChatSession()
```

Call this when your app user logs out to clear their chat history from the device.

---

### setSessionString

Sets a custom string value in the current session.

```dart
static void setSessionString({required String key, required String value})
```

| Parameter | Type     | Required | Description                      |
|-----------|----------|----------|----------------------------------|
| `key`     | `String` | Yes      | Data key (must not be empty)     |
| `value`   | `String` | Yes      | String value (must not be empty) |

**Throws:** `ArgumentError` if `key` or `value` is empty.

---

### setSessionInt

Sets a custom integer value in the current session.

```dart
static void setSessionInt({required String key, required int value})
```

| Parameter | Type     | Required | Description                  |
|-----------|----------|----------|------------------------------|
| `key`     | `String` | Yes      | Data key (must not be empty) |
| `value`   | `int`    | Yes      | Integer value                |

**Throws:** `ArgumentError` if `key` is empty.

---

### getSessionIdentifier

Retrieves the current Crisp session identifier.

```dart
static Future<String?> getSessionIdentifier()
```

**Returns:** The session ID string, or `null` if no session exists. Falls back to a cached value if the native SDK returns `null`.

---

### setSessionSegments

Sets user segments for the current session.

```dart
static void setSessionSegments({
  required List<String> segments,
  bool overwrite = false,
})
```

| Parameter   | Type           | Required | Default | Description                         |
|-------------|----------------|----------|---------|-------------------------------------|
| `segments`  | `List<String>` | Yes      | —       | Segment strings                     |
| `overwrite` | `bool`         | No       | `false` | Replace existing segments if `true` |

---

### pushSessionEvent

Sends a custom event to the Crisp session timeline.

```dart
static Future<void> pushSessionEvent({
  required String name,
  SessionEventColor color = SessionEventColor.blue,
})
```

| Parameter | Type                | Required | Default | Description                  |
|-----------|---------------------|----------|---------|------------------------------|
| `name`    | `String`            | Yes      | —       | Event name                   |
| `color`   | `SessionEventColor` | No       | `blue`  | Event color in the dashboard |

---

### getUnreadMessageCount

Fetches the unread message count via the Crisp REST API.

```dart
static Future<int?> getUnreadMessageCount({
  required String websiteId,
  required String identifier,
  required String key,
})
```

| Parameter    | Type     | Required | Description               |
|--------------|----------|----------|---------------------------|
| `websiteId`  | `String` | Yes      | Your Crisp Website ID     |
| `identifier` | `String` | Yes      | Crisp REST API Identifier |
| `key`        | `String` | Yes      | Crisp REST API Key        |

**Returns:** Unread count as `int`, or `null` if no session or error.

::: warning iOS
On iOS, `unread.visitor` may not reset after reading chat in the native SDK. Use [markMessagesAsRead](#markmessagesasread) as a workaround.
:::

---

### markMessagesAsRead

Marks all operator messages as read via the Crisp REST API. Workaround for iOS when the native SDK does not sync read receipts.

```dart
static Future<bool?> markMessagesAsRead({
  required String websiteId,
  required String identifier,
  required String key,
})
```

| Parameter    | Type     | Required | Description               |
|--------------|----------|----------|---------------------------|
| `websiteId`  | `String` | Yes      | Your Crisp Website ID     |
| `identifier` | `String` | Yes      | Crisp REST API Identifier |
| `key`        | `String` | Yes      | Crisp REST API Key        |

**Returns:** `true` if accepted (HTTP 202), `false` on error, `null` if no session.

---

### openChatboxFromNotification

Opens the Crisp chatbox from a notification intent (Android only).

```dart
static Future<bool> openChatboxFromNotification()
```

**Returns:** `true` if the chatbox was opened from a notification, `false` otherwise. Always returns `false` on iOS.

---

### setOnNotificationTappedCallback

Sets a callback for when a Crisp notification is tapped while the app is in the background.

```dart
static void setOnNotificationTappedCallback(VoidCallback? callback)
```

| Parameter  | Type            | Required | Description                            |
|------------|-----------------|----------|----------------------------------------|
| `callback` | `VoidCallback?` | Yes      | Callback function, or `null` to remove |

**Note:** Requires `import 'dart:ui';` for `VoidCallback`. Only fires on Android.

---

### isVideoCallsSupported

Returns whether the **current build** supports Crisp video/audio calls.

```dart
static Future<bool> isVideoCallsSupported()
```

| Platform          | Returns `true` when                                                                                       |
|-------------------|-----------------------------------------------------------------------------------------------------------|
| **iOS**           | App was built with video enabled: `$CrispChatWebRTC = true` (CocoaPods) or `CRISP_CHAT_WEBRTC=true` (SPM) |
| **Android**       | Never (native video not supported yet by Crisp)                                                           |
| **Web / desktop** | Web chatbox handles calls via browser WebRTC when enabled in your Crisp dashboard                         |

**Important:** This is a **build-time** capability check, not a runtime toggle. There is no `CrispConfig` flag for video. Setup: [Enable video calls (iOS only)](/getting_started/platform_setup#enable-video-calls-ios-only).

**Example:**

```dart
if (await FlutterCrispChat.isVideoCallsSupported()) {
  // iOS WebRTC build, or Web/desktop
}
```

---

### openHelpdesk

Opens the Crisp Helpdesk/FAQ search screen directly, without first opening live chat. Supported on **all platforms**.

```dart
static Future<void> openHelpdesk({required String websiteId})
```

| Parameter   | Type     | Required | Description           |
|-------------|----------|----------|-----------------------|
| `websiteId` | `String` | Yes      | Your Crisp website ID |

**Throws:** `ArgumentError` if `websiteId` is empty or whitespace-only.

**Example:**

```dart
await FlutterCrispChat.openHelpdesk(websiteId: 'YOUR_WEBSITE_ID');
```

| Platform            | Behaviour                                                              |
|---------------------|------------------------------------------------------------------------|
| **Android / iOS**   | Native SDK: calls `Crisp.searchHelpdesk()` / `CrispSDK.searchHelpdesk()` |
| **Web**             | `$crisp.push(["do", "helpdesk:search"])` via the Crisp Web Chat SDK   |
| **Desktop**         | Same `$crisp` command injected into the embedded WebView              |

See [Helpdesk / FAQ](/core_feature/helpdesk) for full details.

---

### openHelpdeskArticle

Opens a specific helpdesk article by locale and slug. Supported on **all platforms**.

```dart
static Future<void> openHelpdeskArticle({
  required String websiteId,
  required String locale,
  required String slug,
  String? title,
  String? category,
})
```

| Parameter   | Type      | Required | Description                                     |
|-------------|-----------|----------|-------------------------------------------------|
| `websiteId` | `String`  | Yes      | Your Crisp website ID                           |
| `locale`    | `String`  | Yes      | Article language code (e.g. `'en'`, `'fr'`)    |
| `slug`      | `String`  | Yes      | Article slug from your Crisp Helpdesk dashboard |
| `title`     | `String?` | No       | Optional display title override                 |
| `category`  | `String?` | No       | Optional category name                          |

**Throws:** `ArgumentError` if `websiteId`, `locale`, or `slug` is empty.

**Example:**

```dart
await FlutterCrispChat.openHelpdeskArticle(
  websiteId: 'YOUR_WEBSITE_ID',
  locale: 'en',
  slug: 'getting-started',
  title: 'Getting Started',
  category: 'General',
);
```

The article `slug` can be found in your Crisp dashboard under **Helpdesk** → open an article → the URL and article settings contain the slug.

| Platform            | Behaviour                                                                                        |
|---------------------|--------------------------------------------------------------------------------------------------|
| **Android / iOS**   | Native SDK: `Crisp.openHelpdeskArticle()` / `CrispSDK.openHelpdeskArticle()`                    |
| **Web**             | `$crisp.push(["do", "helpdesk:article:open", [locale, slug, ...]])` via the Crisp Web Chat SDK  |
| **Desktop**         | Same `$crisp` command injected into the embedded WebView                                         |

See [Helpdesk / FAQ](/core_feature/helpdesk) for full details.

---

## CrispConfig

```dart
CrispConfig({
  required String websiteID,
  String? tokenId,
  String? sessionSegment,
  User? user,
  bool enableNotifications = true,
})
```

## User

```dart
User({
  String? email,
  String? signature,
  String? nickName,
  String? phone,
  String? avatar,
  Company? company,
})
```

## Company

```dart
Company({
  String? name,
  String? url,
  String? companyDescription,
  Employment? employment,
  GeoLocation? geoLocation,
})
```

## Employment

```dart
Employment({
  String? title,
  String? role,
})
```

## GeoLocation

```dart
GeoLocation({
  String? city,
  String? country,
})
```

## SessionEventColor

```dart
enum SessionEventColor {
  black, blue, brown, green, grey,
  orange, pink, purple, red, yellow,
}
```

## Next Steps

- [Full Example](/reference/examples) — Working example app code
- [FAQ](/reference/faq) — Frequently asked questions
