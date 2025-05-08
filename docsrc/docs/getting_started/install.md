---
head:
  - - meta
    - name: description
      content: Learn how to install the Flutter Crisp Chat plugin in your Flutter project. Follow these steps to integrate Crisp Chat seamlessly.

  - - meta
    - name: keywords
      content: "install Flutter Crisp Chat, add Flutter Crisp Chat, Flutter Crisp Chat plugin installation, Flutter Crisp Chat setup, install Crisp Chat Flutter plugin, steps to install Flutter Crisp Chat"

prev:
  text: 'Benchmark'
  link: 'getting_started/benchmark.md'

next:
  text: 'Uninstall'
  link: 'getting_started/uninstall.md'
---

# Installation

## pubspec.yaml

To install the **Flutter Crisp Chat** plugin in your Flutter project, follow these steps:

1. Open your project in an editor, such as Visual Studio Code or Android Studio.
2. Open your project's `pubspec.yaml` file and add the following line to the `dependencies` section:

```yaml
dependencies:
  flutter_crisp_chat: ^latest_version
```

3. Save the changes to your `pubspec.yaml` file.
4. Run the following command in your terminal to fetch the package:

```shell
flutter pub get
```

This will download and install the **Flutter Crisp Chat** plugin and its dependencies.

## Import the Package

After installation, you can import the package in your Dart code using the following statement:

```dart
import 'package:flutter_crisp_chat/flutter_crisp_chat.dart';
```

## Initialization

To initialize the **Flutter Crisp Chat** plugin, follow these steps:

1. Import the package into your `main.dart` file:

```dart
import 'package:flutter_crisp_chat/flutter_crisp_chat.dart';
```

2. Initialize the Crisp Chat plugin in your app's main method or wherever required. For example:

```dart
void main() {
  runApp(MyApp());
}
```

3. Use the plugin's API to integrate Crisp Chat into your app. Refer to the [documentation](https://github.com/alamin-karno/flutter-crisp-chat) for detailed usage instructions.

## Flutter CLI

Alternatively, you can install the **Flutter Crisp Chat** plugin using the Flutter CLI. Run the following command in your terminal:

```shell
flutter pub add flutter_crisp_chat
```

This command will add the plugin to your `pubspec.yaml` file and install it. Afterward, run:

```shell
flutter pub get
```

This ensures all dependencies are downloaded and installed.

## Next Steps

Once the plugin is installed and initialized, you can start using its features to integrate Crisp Chat into your Flutter application. Check out the [official repository](https://github.com/alamin-karno/flutter-crisp-chat) for more details and examples.
