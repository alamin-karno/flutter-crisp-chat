---
head:
  - - meta
    - name: description
      content: Install the Flutter Crisp Chat plugin in your Flutter project using pub.dev or the Flutter CLI.

  - - meta
    - name: keywords
      content: "install crisp_chat, flutter crisp chat installation, add crisp chat flutter, crisp_chat pub add"

prev:
  text: 'Overview'
  link: '/getting_started/overview'

next:
  text: 'Platform Setup'
  link: '/getting_started/platform_setup'
---

# Installation

## Add the Dependency

Run this command in your project directory:

```shell
flutter pub add crisp_chat
```

Or manually add it to your `pubspec.yaml`:

```yaml
dependencies:
  crisp_chat: ^2.4.5
```

Then run:

```shell
flutter pub get
```

## Import

Add the import to any Dart file where you want to use the plugin:

```dart
import 'package:crisp_chat/crisp_chat.dart';
```

This single import gives you access to all classes: `FlutterCrispChat`, `CrispConfig`, `User`, `Company`, `Employment`, `GeoLocation`, and `SessionEventColor`.

## Uninstall

To remove the plugin:

```shell
flutter pub remove crisp_chat
```

Or manually remove `crisp_chat` from your `pubspec.yaml` and run `flutter pub get`.

::: warning
After removing the plugin, make sure to remove all `import 'package:crisp_chat/crisp_chat.dart'` statements and any usage of the plugin's classes from your code.
:::

## Next Steps

After installing the package, you need to configure platform-specific settings for Android and iOS. See [Platform Setup](/getting_started/platform_setup).
