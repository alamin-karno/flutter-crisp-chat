---
head:
  - - meta
    - name: description
      content: Learn how to uninstall the Flutter Crisp Chat plugin from your Flutter project. Follow these steps to remove the plugin seamlessly.

  - - meta
    - name: keywords
      content: "uninstall Flutter Crisp Chat, remove Flutter Crisp Chat, Flutter Crisp Chat plugin uninstallation, Flutter Crisp Chat removal, delete Flutter Crisp Chat, uninstalling Flutter Crisp Chat, Flutter Crisp Chat package removal guide, steps to uninstall Flutter Crisp Chat"

prev:
  text: 'Install'
  link: 'getting_started/install.md'

next:
  text: 'Initialize'
  link: 'core_feature/initialize.md'
---

# Uninstall

## pubspec.yaml

You can uninstall the **Flutter Crisp Chat** plugin from your Flutter project by removing it from the `pubspec.yaml` file and then updating the project dependencies. Follow these steps:

1. Open your project's `pubspec.yaml` file in an editor.
2. Remove the following line from the `dependencies` section:

```yaml
flutter_crisp_chat: ^latest_version
```

3. Save the changes to your `pubspec.yaml` file.
4. Run the following command in your terminal to update the project dependencies:

```shell
flutter pub get
```

This command will update your project dependencies and remove the **Flutter Crisp Chat** plugin from your project.

## Flutter CLI

Alternatively, you can uninstall the **Flutter Crisp Chat** plugin using the Flutter CLI. Follow these steps:

1. Open a terminal window and navigate to the root directory of your Flutter project.
2. Run the following command:

```shell
flutter pub remove flutter_crisp_chat
```

This command will remove the **Flutter Crisp Chat** plugin from your `pubspec.yaml` file and uninstall it from your project.

3. If there are any other dependencies that are no longer needed after removing the plugin, you can run the following command to clean up:

```shell
flutter pub autoremove
```

That's it! You have now successfully uninstalled the **Flutter Crisp Chat** plugin from your Flutter project.

## Next Steps

After uninstalling the plugin, ensure that you remove any references to it in your Dart code to avoid errors. For more details, visit the [official repository](https://github.com/alamin-karno/flutter-crisp-chat).
