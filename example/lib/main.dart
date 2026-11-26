// Example app for the crisp_chat plugin.
//
// Run it with your Crisp website ID:
//
//   flutter run --dart-define=websiteId=YOUR_WEBSITE_ID
//
// or, to also try the unread-messages REST API, with a config.json holding
// `websiteId`, `identifier` and `crispApiKey`:
//
//   flutter run --dart-define-from-file=config.json
//
// The minimal integration is:
//
//   await FlutterCrispChat.openCrispChat(
//     config: CrispConfig(websiteID: 'YOUR_WEBSITE_ID'),
//   );
//
// Every plugin call the example makes lives in `src/demo_controller.dart`,
// one method per feature. The `src/pages/` folder holds the UI.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/demo_controller.dart';
import 'src/platform_support.dart';

/// Handles push messages while the app is in the background. Must be a
/// top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crisp push notifications use Firebase Cloud Messaging on Android and
  // iOS. Web and desktop don't need Firebase.
  if (PlatformSupport.pushNotifications) {
    await _setUpFirebase();
  }

  final controller = DemoController(
    websiteId: const String.fromEnvironment('websiteId'),
    identifier: const String.fromEnvironment('identifier'),
    apiKey: const String.fromEnvironment('crispApiKey'),
  );

  // Listens to Crisp events and opens the chat when the app was launched
  // from a Crisp notification.
  controller.start();

  runApp(CrispExampleApp(controller: controller));
}

Future<void> _setUpFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Required on iOS and on Android 13+ to show notifications.
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  } catch (e) {
    // Firebase config files are not committed. The chat still works
    // without them; only push notifications are missing.
    if (kDebugMode) debugPrint('Firebase not set up: $e');
  }
}
