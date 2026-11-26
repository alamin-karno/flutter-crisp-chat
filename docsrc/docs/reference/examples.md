---
head:
  - - meta
    - name: description
      content: Full working example app for the Flutter Crisp Chat plugin with Firebase, notifications, user config, and unread messages.

  - - meta
    - name: keywords
      content: "flutter crisp chat example, crisp chat full example, crisp chat sample app, flutter crisp chat demo"

prev:
  text: 'API Documentation'
  link: '/reference/api_documentation'

next:
  text: 'FAQ'
  link: '/reference/faq'
---

# Full Example

This is the working example app from the plugin's `example/` directory.

| Target            | What the example demonstrates                                                                                                                  |
|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| **Android / iOS** | Firebase, push notification hooks, live `onCrispEvent` log, login and logout, sessions, local messages, unread REST API; built-in iOS video calls (camera + microphone keys in `Info.plist`) and modal presentation styles |
| **Web**           | Web Chat SDK, login and logout, sessions, local messages, color mode and locale (no Firebase)                                                  |
| **Desktop**       | Embedded WebView chat in a native window, with the same features as Web (no Firebase)                                                         |

### What's in the app

The app uses Crisp's colors, supports light and dark mode, and has five tabs:

| Tab          | Shows                                                                                                                                         |
|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| **Home**     | Open the chat and helpdesk, check and clear unread messages, real-world scenarios (order support, bug report, sales, fresh start), and the color mode, locale and iOS presentation options |
| **Identity** | Sign in as a demo user with `configure()`, `setTokenId()` and `resetCrispChatSession()`, sign out, and set the email, nickname, phone and avatar on their own |
| **Session**  | Session ID, `isSessionOngoing()`, session data, segments, colored session events, bot scenarios, and reset                                    |
| **Messages** | Welcome messages through `CrispConfig.localMessages`, and one sample of every `showMessage()` content type                                    |
| **Activity** | A live log of every action's result and of native Crisp events                                                                                |

When a platform ignores an option, such as `colorMode` on Android, the app says so where the option appears. Every plugin call the app makes is in [`example/lib/src/demo_controller.dart`](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/example/lib/src/demo_controller.dart), one method per feature, so you can copy the one you need. The `main.dart` below is a shorter, single-file version.

### Run without Firebase (Web / desktop)

```bash
cd example
flutter run -d chrome --dart-define=websiteId=YOUR_WEBSITE_ID
flutter run -d macos --dart-define=websiteId=YOUR_WEBSITE_ID
```

### Run with Firebase (Android / iOS)

Use `--dart-define-from-file=config.json` as shown below. Firebase config files are gitignored.

The snippet below shows the **mobile-oriented** `main()`; the repository example also skips Firebase on Web and desktop — see [Platform Setup](/getting_started/platform_setup).

## main.dart

```dart
import 'package:crisp_chat/crisp_chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

// Background message handler — must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permission (required on iOS and Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (kDebugMode) {
    print('Permission: ${settings.authorizationStatus}');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Pass these via --dart-define-from-file=config.json
  static const String websiteID = String.fromEnvironment('websiteId');
  static const String identifier = String.fromEnvironment('identifier');
  static const String crispApiKey = String.fromEnvironment('crispApiKey');

  int count = 0;
  late CrispConfig config;

  @override
  void initState() {
    super.initState();

    // Handle Crisp notification tap — terminated state (Option B)
    FlutterCrispChat.openChatboxFromNotification();

    // Handle Crisp notification tap — background state (Option B)
    FlutterCrispChat.setOnNotificationTappedCallback(() {
      if (kDebugMode) {
        print('Crisp notification tapped while app was in background');
      }
      FlutterCrispChat.openChatboxFromNotification();
    });

    // Configure Crisp
    config = CrispConfig(
      websiteID: websiteID,
      tokenId: "Token Id",
      sessionSegment: 'test_segment',
      user: User(
        avatar: "https://avatars.githubusercontent.com/u/56608168?v=4",
        email: "alamin.karno@gmail.com",
        signature: "USER_EMAIL_HMAC_SHA256_SIGNATURE",
        nickName: "Md. Al-Amin",
        phone: "5555555555",
        company: Company(
          companyDescription: "Unlock superior software solutions"
              " with Vivasoft, a leading offshore development firm"
              " delivering creativity and expertise.",
          name: "Vivasoft Limited",
          url: "https://vivasoftltd.com/",
          employment: Employment(
            role: "Mobile Application Developer",
            title: "Software Engineer L-II",
          ),
          geoLocation: GeoLocation(
            city: "Dhaka",
            country: "Bangladesh",
          ),
        ),
      ),
      // Shown locally as an operator message the first time the chat opens.
      localMessages: const [
        CrispTextContent('👋 Hi! How can we help you today?'),
      ],
    );
  }

  void _checkUnreadMessages() async {
    int? unreadCount = await FlutterCrispChat.getUnreadMessageCount(
      websiteId: websiteID,
      identifier: identifier,
      key: crispApiKey,
    );

    if (unreadCount != null && unreadCount > 0) {
      if (kDebugMode) {
        print('You have $unreadCount unread messages.');
      }
      setState(() {
        count = unreadCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Crisp Chat')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  FlutterCrispChat.openCrispChat(config: config);

                  FlutterCrispChat.setSessionString(
                    key: "a_string",
                    value: "Crisp Chat",
                  );
                  FlutterCrispChat.setSessionInt(
                    key: "a_number",
                    value: 12345,
                  );

                  await Future.delayed(Duration(seconds: 1), () {
                    FlutterCrispChat.pushSessionEvent(
                      name: 'test_event',
                      color: SessionEventColor.green,
                    );
                  });

                  await Future.delayed(const Duration(seconds: 5), () async {
                    String? sessionId =
                        await FlutterCrispChat.getSessionIdentifier();
                    if (kDebugMode) {
                      print('Session ID: $sessionId');
                    }
                  });
                },
                child: const Text('Open Crisp Chat'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FlutterCrispChat.openCrispChat(config: config);
                  await FlutterCrispChat.showMessage(
                    const CrispFieldContent(
                      id: 'email',
                      text: 'What email can we reach you at?',
                      explain: 'name@example.com',
                    ),
                  );
                },
                child: const Text('Show Local Message'),
              ),
              SizedBox(height: 20),
              Badge.count(
                count: count,
                isLabelVisible: count != 0,
                maxCount: 9,
                child: ElevatedButton(
                  onPressed: _checkUnreadMessages,
                  child: Text('Unread'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Running the Example

The example app uses `--dart-define-from-file` to pass secrets. Create a `config.json` file:

```json
{
  "websiteId": "YOUR_WEBSITE_ID",
  "identifier": "YOUR_CRISP_API_IDENTIFIER",
  "crispApiKey": "YOUR_CRISP_API_KEY"
}
```

Then run:

```shell
cd example
flutter run --dart-define-from-file=config.json
```

## AndroidManifest.xml (Option B)

```xml
<service
    android:name="com.alaminkarno.flutter_crisp_chat.CrispChatNotificationService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

## Screenshot

![Crisp Chat SDK Demo](https://github.com/user-attachments/assets/436a53d5-f37b-4aa4-982d-e023fe35ab30)

## Next Steps

- [FAQ](/reference/faq) — Frequently asked questions
- [Changelog](/reference/changelog) — Version history and release notes
