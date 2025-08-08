import 'package:crisp_chat/crisp_chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

// Background message handler
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

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permission
  await _requestNotificationPermission();

  runApp(const MyApp());
}

Future<void> _requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    if (kDebugMode) {
      print('✅ User granted permission');
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    if (kDebugMode) {
      print('⚠️ User granted provisional permission');
    }
  } else {
    if (kDebugMode) {
      print('❌ User declined or has not accepted permission');
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String websiteID = String.fromEnvironment('WEBSITE_ID');
  late CrispConfig config;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Crisp Chat'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  FlutterCrispChat.openCrispChat(config: config);

                  /// Setting session data
                  FlutterCrispChat.setSessionString(
                    key: "a_string",
                    value: "Crisp Chat",
                  );

                  /// Setting session data
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

                  /// Checking session ID After 5 sec
                  await Future.delayed(const Duration(seconds: 5), () async {
                    String? sessionId =
                        await FlutterCrispChat.getSessionIdentifier();
                    if (sessionId != null) {
                      if (kDebugMode) {
                        print('Session ID: $sessionId');
                      }
                    } else {
                      if (kDebugMode) {
                        print('No active session found!');
                      }
                    }
                  });

                  /// Reset crisp Chat Session
                  /// This will remove all the session data after 5 minutes
                  /// and close the chat window
                  await Future.delayed(const Duration(minutes: 5), () async {
                    await FlutterCrispChat.resetCrispChatSession();
                  });
                },
                child: const Text('Open Crisp Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
