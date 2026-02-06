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

## FlutterCrispChat

All methods are `static` on the `FlutterCrispChat` class.

```dart
import 'package:crisp_chat/crisp_chat.dart';
```

---

### openCrispChat

Opens the native Crisp chat UI.

```dart
static Future<void> openCrispChat({required CrispConfig config})
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `config` | `CrispConfig` | Yes | Configuration object with website ID, user details, etc. |

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

| Parameter | Type | Required | Description |
|---|---|---|---|
| `key` | `String` | Yes | Data key (must not be empty) |
| `value` | `String` | Yes | String value (must not be empty) |

**Throws:** `ArgumentError` if `key` or `value` is empty.

---

### setSessionInt

Sets a custom integer value in the current session.

```dart
static void setSessionInt({required String key, required int value})
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `key` | `String` | Yes | Data key (must not be empty) |
| `value` | `int` | Yes | Integer value |

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

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `segments` | `List<String>` | Yes | — | Segment strings |
| `overwrite` | `bool` | No | `false` | Replace existing segments if `true` |

---

### pushSessionEvent

Sends a custom event to the Crisp session timeline.

```dart
static Future<void> pushSessionEvent({
  required String name,
  SessionEventColor color = SessionEventColor.blue,
})
```

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `name` | `String` | Yes | — | Event name |
| `color` | `SessionEventColor` | No | `blue` | Event color in the dashboard |

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

| Parameter | Type | Required | Description |
|---|---|---|---|
| `websiteId` | `String` | Yes | Your Crisp Website ID |
| `identifier` | `String` | Yes | Crisp REST API Identifier |
| `key` | `String` | Yes | Crisp REST API Key |

**Returns:** Unread count as `int`, or `null` if no session or error.

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

| Parameter | Type | Required | Description |
|---|---|---|---|
| `callback` | `VoidCallback?` | Yes | Callback function, or `null` to remove |

**Note:** Requires `import 'dart:ui';` for `VoidCallback`. Only fires on Android.

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
