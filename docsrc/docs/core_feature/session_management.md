---
head:
  - - meta
    - name: description
      content: Manage Crisp chat sessions in Flutter — set custom data, segments, events, bot scenarios, get session IDs, and reset sessions.

  - - meta
    - name: keywords
      content: "crisp session management, flutter crisp session data, crisp session segments, crisp session events, crisp bot scenario, reset crisp session"

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

| Parameter   | Type           | Default | Description                                                 |
|-------------|----------------|---------|-------------------------------------------------------------|
| `segments`  | `List<String>` | —       | List of segment strings                                     |
| `overwrite` | `bool`         | `false` | If `true`, replaces existing segments. If `false`, appends. |

## Push Session Events

Log custom events to the Crisp session timeline. Events are visible in the Crisp dashboard and can be used for tracking user actions.

```dart
await FlutterCrispChat.pushSessionEvent(
  name: 'completed_onboarding',
  color: SessionEventColor.green,
);
```

### Available Colors

| Color                      | Value          |
|----------------------------|----------------|
| `SessionEventColor.black`  | Black          |
| `SessionEventColor.blue`   | Blue (default) |
| `SessionEventColor.brown`  | Brown          |
| `SessionEventColor.green`  | Green          |
| `SessionEventColor.grey`   | Grey           |
| `SessionEventColor.orange` | Orange         |
| `SessionEventColor.pink`   | Pink           |
| `SessionEventColor.purple` | Purple         |
| `SessionEventColor.red`    | Red            |
| `SessionEventColor.yellow` | Yellow         |

## Run Bot Scenarios

Trigger a Bot scenario configured in the Bot plugin on your Crisp website — useful for kicking off an automated flow (e.g. onboarding, FAQ triage) from within your app.

```dart
await FlutterCrispChat.runBotScenario(scenarioId: 'YOUR_SCENARIO_ID');
```

The scenario ID can be found in the Crisp dashboard under **Settings** → **Chatbot**.

::: warning
`scenarioId` must be non-empty. An `ArgumentError` is thrown otherwise.
:::

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

## Check if the Session Is Ongoing

Find out whether messages have been sent or received in the current session, e.g. to show "Continue conversation" instead of "Chat with us" to a returning visitor.

```dart
final ongoing = await FlutterCrispChat.isSessionOngoing();
final label = switch (ongoing) {
  true => 'Continue conversation',
  false || null => 'Chat with us',
};
```

`isSessionOngoing()` returns `true` or `false`, or `null` when it can't tell:

| Platform        | Behavior                                                                                         |
|-----------------|--------------------------------------------------------------------------------------------------|
| iOS             | `CrispSDK.session.isOngoing` (Crisp iOS SDK 3.1.1+); `null` until the session has loaded          |
| Web / desktop   | `$crisp.is("session:ongoing")`; `null` until Crisp and its session have loaded (desktop: WebView only) |
| Android         | Always `null` — the Crisp Android SDK 2.x has no such check                                       |

::: tip
The session loads when the chat is opened. To check right after opening, wait for a `sessionLoaded` event on [`FlutterCrispChat.onCrispEvent`](/reference/api_documentation#oncrispevent) first.
:::

## Reset Session

Reset the current chat session. This clears all session data and starts fresh. **Call this when your app user logs out** to ensure the next user doesn't see the previous user's chat history.

```dart
await FlutterCrispChat.resetCrispChatSession();
```

::: danger Important
Always reset the session when a user logs out of your app. Failing to do so means the next user could see the previous user's chat history and personal data.
:::

## Login and Logout

If you use a [token ID](/core_feature/configuration#token-id), set and clear it with `setTokenId` so the session follows your app's user. A new or cleared token only takes effect after `resetCrispChatSession`, so always call the two together, in this order. None of these calls opens the chat.

```dart
// On login
await FlutterCrispChat.configure(websiteId: 'YOUR_WEBSITE_ID');
await FlutterCrispChat.setTokenId(user.id);
await FlutterCrispChat.resetCrispChatSession();
// Then set user details and segments: a reset clears them
await FlutterCrispChat.setUserEmail(user.email);
FlutterCrispChat.setSessionSegments(segments: ['premium'], overwrite: true);

// On logout
await FlutterCrispChat.setTokenId(null); // null clears the token
await FlutterCrispChat.resetCrispChatSession();
```

| Method | Description |
|--------|-------------|
| `configure({required String websiteId})` | Configures the SDK without opening the chat. Call it before the other methods when the chat hasn't been opened yet. Does nothing on Web and desktop, which take the website ID from `openCrispChat`. |
| `setTokenId(String? tokenId)` | Sets the token; `null` or an empty string clears it. A `CrispConfig.tokenId` passed to `openCrispChat` still takes precedence. |

::: warning Call these while the chat is closed
The Android SDK ignores a new token while the chat is connected. Close the chat before logging the user in or out.
:::

::: info Web and desktop
The token is applied right away if the chat is loaded, otherwise when it next opens. The same goes for `resetCrispChatSession`: if the chat isn't loaded, it returns at once and the reset runs when the chat next opens, before your config is applied.
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

// 5. Clear the token and reset on logout
await FlutterCrispChat.setTokenId(null);
await FlutterCrispChat.resetCrispChatSession();
```

## Next Steps

- [Unread Messages](/core_feature/unread_messages) — Check for unread messages via the Crisp REST API
- [Push Notifications](/notifications/firebase_setup) — Set up push notifications
