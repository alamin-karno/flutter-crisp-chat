---
head:
  - - meta
    - name: description
      content: Learn how to send messages using the Flutter Crisp Chat plugin.

  - - meta
    - name: keywords
      content: "send message Flutter Crisp Chat, Crisp Chat message sending, Flutter Crisp Chat API"

prev:
  text: 'Initialize'
  link: '/core_feature/initialize.md'

next:
  text: 'Receive Message'
  link: '/core_feature/receive_message.md'
---

# Send Message

The **Flutter Crisp Chat** plugin allows you to send messages to users easily. Follow these steps:

## Set Session Data

Before sending a message, you can set session data using the following methods:

```dart
FlutterCrispChat.setSessionString(
  key: "a_string",
  value: "Crisp Chat",
);

FlutterCrispChat.setSessionInt(
  key: "a_number",
  value: 12345,
);
```

## Send a Message

To send a message, use the `openCrispChat` method and include the session data:

```dart
FlutterCrispChat.openCrispChat(config: config);
```

## Next Steps

After sending a message, you can learn how to receive messages in the [Receive Message](receive_message.md) section.
