---
head:
  - - meta
    - name: description
      content: Listen to native Crisp SDK chat events in Flutter — session loaded, chat opened/closed, message sent/received, and Android-only notification received.

  - - meta
    - name: keywords
      content: "flutter crisp events, crisp chat events flutter, onCrispEvent, crisp EventsCallback flutter, crisp_chat message received"

prev:
  text: 'Helpdesk / FAQ'
  link: '/core_feature/helpdesk'

next:
  text: 'Firebase Setup'
  link: '/notifications/firebase_setup'
---

# Chat Events

Listen to native Crisp SDK events through a single broadcast stream — session loaded, chat opened/closed, and message sent/received. Useful for updating an unread badge in real time instead of polling [`getUnreadMessageCount`](/core_feature/unread_messages).

## Platform support

| Platform          | Support                                                          |
|-------------------|-------------------------------------------------------------------|
| **Android**       | Native SDK: `Crisp.addCallback(EventsCallback)`                  |
| **iOS**           | Native SDK: `CrispSDK.addCallback(Callback)`                     |
| **Web**           | Not supported — the stream never emits                          |
| **Desktop**       | Not supported — the stream never emits                          |

`CrispEventType.notificationReceived` is **Android-only** — the iOS Crisp SDK has no matching callback, so iOS never emits it.

## Listening to events

```dart
final subscription = FlutterCrispChat.onCrispEvent.listen((event) {
  switch (event.type) {
    case CrispEventType.sessionLoaded:
      print('Session loaded: ${event.sessionId}');
    case CrispEventType.chatOpened:
      print('Chat opened');
    case CrispEventType.chatClosed:
      print('Chat closed');
    case CrispEventType.messageSent:
    case CrispEventType.messageReceived:
      print('Message from ${event.message?.from}: ${event.message?.text}');
    case CrispEventType.notificationReceived:
      print('Notification data: ${event.notificationData}'); // Android-only
  }
});

// Later, when no longer needed:
await subscription.cancel();
```

`onCrispEvent` is a broadcast stream — the native event callback is registered on the **first** `.listen()` call and unregistered once the **last** listener cancels. It's safe to listen and cancel freely; there's no need to manage a single global subscription.

## `CrispChatEvent`

| Field              | Type                    | Populated for                                      |
|---------------------|-------------------------|----------------------------------------------------|
| `type`              | `CrispEventType`         | Always                                              |
| `sessionId`         | `String?`                | `sessionLoaded` only                                |
| `message`           | `CrispMessage?`          | `messageSent` / `messageReceived` only              |
| `notificationData`  | `Map<String, String>?`   | `notificationReceived` only (Android-only)          |

## `CrispMessage`

`CrispMessage` is a **minimal summary**, not a full mapping of every native content type:

| Field         | Type                       | Notes                                                                                          |
|---------------|----------------------------|--------------------------------------------------------------------------------------------------|
| `isMe`        | `bool`                     | Whether this device's visitor sent the message                                                |
| `from`        | `CrispMessageSender`       | `user` or `operatorUser`                                                                       |
| `origin`      | `String?`                  | Raw origin string from the native SDK (e.g. `"chat"`, `"local"`, `"network"`, `"update"`) — kept as a raw string rather than a strict enum, since Android reports up to 8 distinct values and iOS only 3 |
| `timestamp`   | `DateTime`                 | When the message was sent                                                                       |
| `fingerprint` | `int`                      | Unique identifier for this message within the session                                          |
| `contentType` | `CrispMessageContentType`  | `text`, `file`, `animation`, `audio`, `picker`, `field`, `carousel`, or `unknown`               |
| `text`        | `String?`                  | Only populated when `contentType` is `text`. iOS's `textWithAttachment`/`textWithVideoAttachment` cases both map to `contentType: text` |

Rich content (carousel targets, picker choices, file/audio metadata) is not mapped in this version — only whether a message is text and what that text is.

## Next Steps

- [API Reference](/reference/api_documentation#oncrispevent) — Full type signatures
- [Unread Messages](/core_feature/unread_messages) — REST-based unread count, complementary to this event stream
- [Session Management](/core_feature/session_management) — Session identifiers and segments
