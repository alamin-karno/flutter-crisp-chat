---
head:
  - - meta
    - name: description
      content: Learn how to debug issues in the Flutter Crisp Chat plugin.

  - - meta
    - name: keywords
      content: "debugging Flutter Crisp Chat, Crisp Chat debug, Flutter Crisp Chat troubleshooting"

prev:
  text: 'Common Issues'
  link: '../troubleshooting/common_issues.md'

next:
  text: 'Error Handling'
  link: '../troubleshooting/error_handling.md'
---

# Debugging

This section provides tips and tools for debugging issues in the **Flutter Crisp Chat** plugin.

## Enable Debug Logs

Enable debug logs to get detailed information about the plugin's operations:

```dart
FlutterCrispChat.enableDebugLogs(true);
```

## Use Flutter DevTools

Use Flutter DevTools to inspect the app's state and debug issues:

```shell
flutter pub global activate devtools
flutter pub global run devtools
```

## Next Steps

For handling specific errors, refer to the [Error Handling](error_handling.md) section.
