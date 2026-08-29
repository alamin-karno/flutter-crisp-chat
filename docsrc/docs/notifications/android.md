---
head:
  - - meta
    - name: description
      content: Configure Android push notifications for Crisp Chat in Flutter — FirebaseMessagingService, AndroidManifest, and notification customization.

  - - meta
    - name: keywords
      content: "crisp android notifications, flutter crisp fcm android, crisp notification service android, crisp androidmanifest"

prev:
  text: 'Firebase Setup'
  link: '/notifications/firebase_setup'

next:
  text: 'iOS Notifications'
  link: '/notifications/ios'
---

# Android Notifications

After completing [Firebase Setup](/notifications/firebase_setup), configure your Android app to receive and display Crisp push notifications.

## Declare the Notification Service

You need to declare a `FirebaseMessagingService` in your `AndroidManifest.xml` to handle incoming Crisp notifications. The plugin provides **two options**:

### Option A: Auto-Open ChatActivity

Use Crisp's built-in service. When the user taps a notification, the Crisp `ChatActivity` opens automatically.

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application>
    <!-- ... other declarations ... -->

    <service
        android:name="im.crisp.client.external.notification.CrispNotificationService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
</application>
```

**Behavior:** Notification tap → `MainActivity` launches → `ChatActivity` opens automatically.

### Option B: App-First (Recommended)

Use the plugin's custom service. When the user taps a notification, your app opens first — you decide when to show the chatbox.

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application>
    <!-- ... other declarations ... -->

    <service
        android:name="com.alaminkarno.flutter_crisp_chat.CrispChatNotificationService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
</application>
```

**Behavior:** Notification tap → `MainActivity` launches → Your app UI shows → You call `openChatboxFromNotification()` when ready.

See [Notification Handling](/notifications/handling) for the Flutter code to handle Option B.

::: tip Which Option Should I Choose?
- **Option A** is simpler — zero Flutter code needed for notification handling
- **Option B** gives you control — useful if you want to show your app's home screen first, or run logic before opening the chat
:::

## Customize Notifications

### Icon and Color

Customize the notification icon and color in `AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@drawable/my_notification_icon"
        tools:replace="android:resource" />
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_color"
        android:resource="@color/my_notification_color"
        tools:replace="android:resource" />
</application>
```

### Sound

Add a raw audio resource named `crisp_chat_message_receive` to your app. This sound will play when a Crisp notification is received:

```
android/app/src/main/res/raw/crisp_chat_message_receive.mp3
```

## Next Steps

- [iOS Notifications](/notifications/ios) — Configure APNs for iOS
- [Notification Handling](/notifications/handling) — Handle notification taps in Flutter (Option B)
