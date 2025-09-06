---
head:
  - - meta
    - name: description
      content: Learn how to initialize the Flutter Crisp Chat plugin in your Flutter project.

  - - meta
    - name: keywords
      content: "initialize Flutter Crisp Chat, Flutter Crisp Chat initialization, Crisp Chat setup, Crisp Chat configuration"

prev:
  text: 'Uninstall'
  link: '../getting_started/uninstall.md'

next:
  text: 'Send Message'
  link: '/core_feature/send_message.md'
---

# Initialize

To initialize the **Flutter Crisp Chat** plugin, follow these steps:

## Import the Package

Add the following import statement to your Dart file:

```dart
import 'package:flutter_crisp_chat/flutter_crisp_chat.dart';
```

## Create a Configuration Object

Create a `CrispConfig` object with your website ID and other optional parameters:

```dart
final String websiteID = "YOUR_WEBSITE_ID";
CrispConfig config = CrispConfig(
  websiteID: websiteID,
  enableNotifications: true,
);
```

## Initialize the Plugin

Call the `openCrispChat` method with the configuration object:

```dart
FlutterCrispChat.openCrispChat(config: config);
```

## Next Steps

Once initialized, you can start using the plugin's features, such as sending and receiving messages. Refer to the [Send Message](send_message.md) section for more details.
