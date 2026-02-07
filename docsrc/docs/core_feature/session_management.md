---
head:
  - - meta
    - name: description
      content: Manage Crisp chat sessions in Flutter — set custom data, segments, events, get session IDs, and reset sessions.

  - - meta
    - name: keywords
      content: "crisp session management, flutter crisp session data, crisp session segments, crisp session events, reset crisp session"

prev:
  text: 'User & Company'
  link: '/core_feature/user_and_company'

next:
  text: 'Unread Messages'
  link: '/core_feature/unread_messages'
---

# Session Management

The Flutter Crisp Chat plugin provides several methods to manage chat sessions — set custom data, categorize users with segments, push events, retrieve session identifiers, and reset sessions.

## Set Session Data

Store custom key-value pairs in the current session. This data is visible to your support agents in the Crisp dashboard.

### String Data

```dart
FlutterCrispChat.setSessionString(
  key: 'subscription_plan',
  value: 'premium',
);
```

### Integer Data

```dart
FlutterCrispChat.setSessionInt(
  key: 'login_count',
  value: 42,
);
```

::: warning
Both `key` and `value` must be non-empty for `setSessionString`. The `key` must be non-empty for `setSessionInt`. An `ArgumentError` is thrown otherwise.
:::

## Session Segments

Segments categorize users for filtering and targeting in the Crisp dashboard.

```dart
// Add segments (appended to existing ones)
FlutterCrispChat.setSessionSegments(
  segments: ['registered_user', 'newsletter_subscriber'],
  overwrite: false, // default
);

// Replace all existing segments
FlutterCrispChat.setSessionSegments(
  segments: ['vip_customer'],
  overwrite: true,
);
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `segments` | `List<String>` | — | List of segment strings |
| `overwrite` | `bool` | `false` | If `true`, replaces existing segments. If `false`, appends. |

## Push Session Events

Log custom events to the Crisp session timeline. Events are visible in the Crisp dashboard and can be used for tracking user actions.

```dart
await FlutterCrispChat.pushSessionEvent(
  name: 'completed_onboarding',
  color: SessionEventColor.green,
);
```

### Available Colors

| Color | Value |
|---|---|
| `SessionEventColor.black` | Black |
| `SessionEventColor.blue` | Blue (default) |
| `SessionEventColor.brown` | Brown |
| `SessionEventColor.green` | Green |
| `SessionEventColor.grey` | Grey |
| `SessionEventColor.orange` | Orange |
| `SessionEventColor.pink` | Pink |
| `SessionEventColor.purple` | Purple |
| `SessionEventColor.red` | Red |
| `SessionEventColor.yellow` | Yellow |

## Get Session Identifier

Retrieve the current Crisp session ID. This is useful for logging, debugging, or linking the chat session to your backend.

```dart
String? sessionId = await FlutterCrispChat.getSessionIdentifier();
if (sessionId != null) {
  print('Session ID: $sessionId');
}
```

::: tip
The session identifier is cached internally after `openCrispChat` is called. If the native SDK returns `null` (e.g., the chat was closed), the cached value is returned instead.
:::

## Reset Session

Reset the current chat session. This clears all session data and starts fresh. **Call this when your app user logs out** to ensure the next user doesn't see the previous user's chat history.

```dart
await FlutterCrispChat.resetCrispChatSession();
```

::: danger Important
Always reset the session when a user logs out of your app. Failing to do so means the next user could see the previous user's chat history and personal data.
:::

## Typical Flow

```dart
// 1. Set session data before opening chat
FlutterCrispChat.setSessionString(key: 'plan', value: 'enterprise');
FlutterCrispChat.setSessionInt(key: 'seats', value: 50);
FlutterCrispChat.setSessionSegments(segments: ['enterprise']);

// 2. Open the chat
await FlutterCrispChat.openCrispChat(config: config);

// 3. Push events during the session
await FlutterCrispChat.pushSessionEvent(
  name: 'viewed_pricing',
  color: SessionEventColor.blue,
);

// 4. Get session ID for logging
String? sessionId = await FlutterCrispChat.getSessionIdentifier();

// 5. Reset on logout
await FlutterCrispChat.resetCrispChatSession();
```

## Next Steps

- [Unread Messages](/core_feature/unread_messages) — Check for unread messages via the Crisp REST API
- [Push Notifications](/notifications/firebase_setup) — Set up push notifications
