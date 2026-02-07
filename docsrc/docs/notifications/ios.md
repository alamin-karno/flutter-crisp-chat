---
head:
  - - meta
    - name: description
      content: Configure iOS push notifications for Crisp Chat in Flutter — APNs setup, Xcode capabilities, and AppDelegate configuration.

  - - meta
    - name: keywords
      content: "crisp ios notifications, flutter crisp apns, crisp ios push notifications, crisp xcode setup"

prev:
  text: 'Android Notifications'
  link: '/notifications/android'

next:
  text: 'Notification Handling'
  link: '/notifications/handling'
---

# iOS Notifications

Crisp uses Apple Push Notification service (APNs) to deliver push notifications on iOS. The Flutter plugin handles most of the integration automatically, but you need to configure a few things.

## 1. Create an APNs Key

1. Go to your [Apple Developer Account](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles** > **Keys**
3. Create a new key with **Apple Push Notifications service (APNs)** enabled
4. Download the `.p8` key file and note the **Key ID**

See the [Apple documentation](https://developer.apple.com/help/account/manage-keys/create-a-private-key/) for detailed instructions.

## 2. Configure Crisp Dashboard

1. Go to your [Crisp Dashboard](https://app.crisp.chat/)
2. Navigate to **Settings** > **ChatBox Settings** > **Push Notifications**
3. Under the **Apple Push Notification** section:
   - Upload your `.p8` key file
   - Enter your **Key ID** and **Team ID**
   - Click **Verify Credentials**

## 3. Add Push Notifications Capability

In Xcode:

1. Open your project (`ios/Runner.xcworkspace`)
2. Select your target (Runner)
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** and add **Push Notifications**

![Push Notifications Capability](https://github.com/user-attachments/assets/8581c872-f836-45f6-9a8c-7a5c5a998cea)

## 4. Register for Remote Notifications

Add the following to your `ios/Runner/AppDelegate.swift` inside `didFinishLaunchingWithOptions`:

```swift
DispatchQueue.main.async {
    UIApplication.shared.registerForRemoteNotifications()
}
```

This ensures the app registers for remote notifications on launch.

## How It Works

The Flutter Crisp Chat plugin's iOS implementation automatically:

- Forwards the device token to Crisp via `CrispSDK.setDeviceToken(deviceToken)`
- Handles incoming notifications with `CrispSDK.handlePushNotification(notification)`
- Shows notification banners when the app is in the foreground
- Opens the chat when a notification is tapped

You don't need to write any additional Swift code — the plugin handles all of this internally.

::: warning Production Only
Currently, Crisp push notifications on iOS are only sent to **production APNs channels**. Notifications will **not** be received when testing with development provisioning profiles or in sandbox mode. This limitation may be resolved in a future Crisp SDK update.
:::

## Next Steps

- [Notification Handling](/notifications/handling) — Handle notification taps in Flutter (Android Option B)
