# crisp_chat example

A demo app for the [`crisp_chat`](https://pub.dev/packages/crisp_chat) plugin. It runs on Android, iOS, Web, macOS, Windows and Linux, uses Crisp's colors in light and dark mode, and covers every API in the plugin.

## Quick start

The smallest integration opens the chat with your website ID:

```dart
import 'package:crisp_chat/crisp_chat.dart';

await FlutterCrispChat.openCrispChat(
  config: CrispConfig(
    websiteID: 'YOUR_WEBSITE_ID',
    user: User(email: 'jane@example.com', nickName: 'Jane'), // optional
  ),
);
```

## Run the example

```bash
cd example
flutter run --dart-define=websiteId=YOUR_WEBSITE_ID
```

To also try the unread-messages REST API, put your credentials in `example/config.json` (it is git-ignored) and run with `--dart-define-from-file=config.json`:

```json
{
  "websiteId": "YOUR_WEBSITE_ID",
  "identifier": "YOUR_CRISP_API_IDENTIFIER",
  "crispApiKey": "YOUR_CRISP_API_KEY"
}
```

Push notifications on Android and iOS also need Firebase config files. The [contributing guide](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/CONTRIBUTING.md) explains how to add them. Without them, the app still runs and only push notifications are missing.

## What's inside

| Tab          | Shows                                                                                                                       |
|--------------|-----------------------------------------------------------------------------------------------------------------------------|
| **Home**     | Open the chat and helpdesk, unread messages, real-world scenarios, and the color mode, locale and iOS presentation options |
| **Identity** | The recommended login and logout sequence, and setting user details without opening the chat                              |
| **Session**  | Session ID, session data, segments, events, bot scenarios and reset                                                         |
| **Messages** | Welcome messages, and one sample of every local message type                                                                |
| **Activity** | A live log of action results and native Crisp events                                                                        |

| File                                                       | Contents                                             |
|------------------------------------------------------------|------------------------------------------------------|
| [`lib/main.dart`](lib/main.dart)                           | Firebase setup and app start-up                      |
| [`lib/src/demo_controller.dart`](lib/src/demo_controller.dart) | Every `FlutterCrispChat` call, one method per feature |
| [`lib/src/sample_data.dart`](lib/src/sample_data.dart)     | Demo users and local message samples                 |
| [`lib/src/pages/`](lib/src/pages/)                         | One file per tab                                     |
| [`lib/src/theme.dart`](lib/src/theme.dart)                 | Light and dark themes in Crisp's colors              |

See the [documentation](https://alamin-karno.github.io/flutter-crisp-chat/) for setup guides and the full API reference.
