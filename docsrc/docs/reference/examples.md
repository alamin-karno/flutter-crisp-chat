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

This is the complete working example app from the plugin's `example/` directory. It demonstrates Firebase initialization, notification handling, user configuration, session management, and unread message checking.

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
