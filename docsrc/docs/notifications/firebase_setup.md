---
head:
  - - meta
    - name: description
      content: Set up Firebase Cloud Messaging for Crisp push notifications in your Flutter app — project creation, dependencies, and Crisp dashboard configuration.

  - - meta
    - name: keywords
      content: "crisp firebase setup, flutter crisp fcm, crisp push notifications firebase, crisp cloud messaging"

prev:
  text: 'Unread Messages'
  link: '/core_feature/unread_messages'

next:
  text: 'Android Notifications'
  link: '/notifications/android'
---

# Firebase Setup

Crisp uses Firebase Cloud Messaging (FCM) on Android and Apple Push Notification service (APNs) on iOS to deliver push notifications. This page covers the Firebase project setup required for both platforms.

## 1. Create a Firebase Project

If you don't already have a Firebase project:

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** and follow the setup wizard
3. Add your Android and iOS apps to the project

For detailed instructions, see the [Firebase Get Started guide](https://firebase.google.com/docs/android/setup).

## 2. Add Firebase Dependencies

Add the Firebase packages to your Flutter project:

```shell
flutter pub add firebase_core
flutter pub add firebase_messaging
```

## 3. Initialize Firebase

In your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}
```

::: tip Background Handler Requirements
- Must **not** be an anonymous function
- Must be a **top-level** function (not a class method)
- Must be annotated with `@pragma('vm:entry-point')` (Flutter 3.3.0+)
:::

## 4. Request Notification Permission

On iOS and Android 13+, you must request permission before receiving notifications:

```dart
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

print('Permission: ${settings.authorizationStatus}');
```

## 5. Configure Crisp Dashboard for Android (FCM)

1. Go to your Firebase **Project Settings** > **Cloud Messaging** tab
2. In the **Firebase Cloud Messaging API (V1)** section, copy your **Sender ID**

![Copy Sender ID](https://github.com/user-attachments/assets/778fcfdd-a9ad-465b-b425-a0b45bf5f0eb)

3. Go to **Service accounts** tab > click **Generate new private key** and save the file

![Generate Private Key](https://github.com/user-attachments/assets/99d7faf3-c1db-41b4-afc9-4bbd64bec1f7)

4. Go to your [Crisp Dashboard](https://app.crisp.chat/) > **Settings** > **ChatBox Settings** > **Push Notifications**
5. Under **Firebase Cloud Messaging**:
   - Enable **Notify users using Android**
   - Paste the **Sender ID** into the **Project ID** field
   - Upload your **Firebase Admin private key** file
   - Click **Verify Credentials**

![Enable Push Notifications](https://github.com/user-attachments/assets/1fe0225e-4a1b-49bd-8814-c4d662fbf703)

6. Wait for Crisp to verify your credentials:

![Checking Credentials](https://github.com/user-attachments/assets/66623e73-3b92-4c79-b6ed-9db696ff1bd9)

7. Once verified, the status will show **live**:

![Credentials Verified](https://github.com/user-attachments/assets/9e6f902a-f37b-4d79-a5d6-8fe25e6a8e7f)

## Next Steps

- [Android Notifications](/notifications/android) — Configure your Android app to receive and handle Crisp notifications
- [iOS Notifications](/notifications/ios) — Configure APNs for iOS
- [Notification Handling](/notifications/handling) — Choose between auto-open and app-first notification behavior
