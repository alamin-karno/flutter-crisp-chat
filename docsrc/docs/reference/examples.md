---
head:
  - - meta
    - name: description
      content: Access examples for using the Flutter Crisp Chat plugin.

  - - meta
    - name: keywords
      content: "examples Flutter Crisp Chat, Crisp Chat usage examples, Flutter Crisp Chat sample code"

prev:
  text: 'API Documentation'
  link: '/reference/api_documentation.md'

next:
  text: 'FAQ'
  link: '/reference/faq.md'
---

# Examples

This section provides practical examples for using the **Flutter Crisp Chat** plugin.

## Example 1: Basic Integration

```dart
import 'package:flutter_crisp_chat/flutter_crisp_chat.dart';

void main() {
  final config = CrispConfig(websiteID: "YOUR_WEBSITE_ID");
  FlutterCrispChat.openCrispChat(config: config);
}
```

## Example 2: Customization

```dart
CrispConfig config = CrispConfig(
  websiteID: "YOUR_WEBSITE_ID",
  enableNotifications: true,
);
FlutterCrispChat.openCrispChat(config: config);
```

## Next Steps

For frequently asked questions, refer to the [FAQ](faq.md) section.
