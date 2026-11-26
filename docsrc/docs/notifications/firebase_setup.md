---
head:
  - - meta
    - name: description
      content: Set up Firebase Cloud Messaging for Crisp push notifications in your Flutter app — project creation, dependencies, and Crisp dashboard configuration.

  - - meta
    - name: keywords
      content: "crisp firebase setup, flutter crisp fcm, crisp push notifications firebase, crisp cloud messaging"

prev:
  text: 'Local Messages'
  link: '/core_feature/local_messages'

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

<img src="/graphics/docs/firebase-sender-id.webp" alt="Copy Sender ID" width="1300" height="924" loading="lazy" decoding="async">

3. Go to **Service accounts** tab > click **Generate new private key** and save the file

<img src="/graphics/docs/firebase-private-key.webp" alt="Generate Private Key" width="1297" height="847" loading="lazy" decoding="async">

4. Go to your [Crisp Dashboard](https://app.crisp.chat/) > **Settings** > **ChatBox Settings** > **Push Notifications**
5. Under **Firebase Cloud Messaging**:
   - Enable **Notify users using Android**
   - Paste the **Sender ID** into the **Project ID** field
   - Upload your **Firebase Admin private key** file
   - Click **Verify Credentials**

<img src="/graphics/docs/crisp-push-settings.webp" alt="Enable Push Notifications" width="1281" height="872" loading="lazy" decoding="async">

6. Wait for Crisp to verify your credentials:

<img src="/graphics/docs/crisp-push-checking.webp" alt="Checking Credentials" width="545" height="44" loading="lazy" decoding="async">

7. Once verified, the status will show **live**:

<img src="/graphics/docs/crisp-push-live.webp" alt="Credentials Verified" width="138" height="17" loading="lazy" decoding="async">

## Next Steps

- [Android Notifications](/notifications/android) — Configure your Android app to receive and handle Crisp notifications
- [iOS Notifications](/notifications/ios) — Configure APNs for iOS
- [Notification Handling](/notifications/handling) — Choose between auto-open and app-first notification behavior
