---
head:
  - - meta
    - name: description
      content: Handle Crisp notification taps in Flutter — auto-open vs app-first approaches, openChatboxFromNotification, and setOnNotificationTappedCallback.

  - - meta
    - name: keywords
      content: "crisp notification handling flutter, openChatboxFromNotification, crisp notification tap, crisp app first notification"

prev:
  text: 'iOS Notifications'
  link: '/notifications/ios'

next:
  text: 'API Documentation'
  link: '/reference/api_documentation'
---

# Notification Handling

This page explains how to handle Crisp notification taps in your Flutter app, specifically when using **Option B** (`CrispChatNotificationService`) on Android.

## Overview

| | Option A (Auto-Open) | Option B (App-First) |
|---|---|---|
| **Service** | `CrispNotificationService` | `CrispChatNotificationService` |
| **Tap behavior** | Opens ChatActivity directly | Opens your app first |
| **Flutter code needed** | None | `openChatboxFromNotification()` |
| **Use case** | Simple apps | Apps that need control over navigation |

If you're using **Option A**, you don't need any of the code on this page — notifications are handled entirely by the Crisp SDK.

## Option B: Flutter Integration

When using `CrispChatNotificationService`, tapping a notification opens your app's `MainActivity` without auto-opening the Crisp chat. You then use two methods to open the chatbox programmatically.

### Handle Terminated State

When the app is **not running** and the user taps a Crisp notification, the app launches fresh. Call `openChatboxFromNotification()` in your widget's `initState` to check if the app was launched from a notification:

```dart
@override
void initState() {
  super.initState();

  // Check if app was launched from a Crisp notification
  FlutterCrispChat.openChatboxFromNotification();
}
```

This method:
- Reads the launch intent
- If it contains Crisp notification data, opens the chatbox
- Returns `true` if the chatbox was opened, `false` otherwise

### Handle Background State

When the app is **already running** in the background and the user taps a Crisp notification, the app resumes. Use `setOnNotificationTappedCallback` to listen for this:

```dart
@override
void initState() {
  super.initState();

  // Terminated state
  FlutterCrispChat.openChatboxFromNotification();

  // Background state
  FlutterCrispChat.setOnNotificationTappedCallback(() {
    FlutterCrispChat.openChatboxFromNotification();
  });
}
```

### Complete Example

```dart
import 'package:crisp_chat/crisp_chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permission
  await FirebaseMessaging.instance.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Handle notification tap — terminated state
    FlutterCrispChat.openChatboxFromNotification();

    // Handle notification tap — background state
    FlutterCrispChat.setOnNotificationTappedCallback(() {
      FlutterCrispChat.openChatboxFromNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('My App')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              final config = CrispConfig(
                websiteID: 'YOUR_WEBSITE_ID',
                enableNotifications: true,
              );
              FlutterCrispChat.openCrispChat(config: config);
            },
            child: const Text('Open Chat'),
          ),
        ),
      ),
    );
  }
}
```

## API Reference

### `openChatboxFromNotification()`

```dart
static Future<bool> openChatboxFromNotification()
```

Attempts to open the Crisp chatbox from a notification intent. Returns `true` if the chatbox was opened (i.e., the app was launched from a Crisp notification), `false` otherwise.

**Platform behavior:**
- **Android:** Reads the activity intent and calls `CrispNotificationClient.openChatbox()`
- **iOS:** Always returns `false` (iOS handles notifications via APNs delegates)

### `setOnNotificationTappedCallback()`

```dart
static void setOnNotificationTappedCallback(VoidCallback? callback)
```

Sets a callback that fires when a Crisp notification is tapped while the app is running in the background. Pass `null` to remove the callback.

**Platform behavior:**
- **Android:** Listens for `onNewIntent` events from the native plugin
- **iOS:** The callback is never invoked (iOS handles notifications differently)

## How It Works Internally

1. `CrispChatNotificationService` receives the FCM message and calls `CrispNotificationClient.handleNotification(context, message, false)` — the `false` flag prevents auto-opening `ChatActivity`
2. When the user taps the notification, Android delivers a new `Intent` to `MainActivity`
3. The plugin's `NewIntentListener` detects the new intent and invokes `onCrispNotificationTapped` on the Flutter method channel
4. Your Dart callback fires, and you call `openChatboxFromNotification()`
5. The plugin calls `CrispNotificationClient.openChatbox(activity, intent)` to open the chat
