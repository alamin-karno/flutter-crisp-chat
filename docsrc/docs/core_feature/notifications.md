---
head:
  - - meta
    - name: description
      content: Learn how to enable and handle notifications in the Flutter Crisp Chat plugin.

  - - meta
    - name: keywords
      content: "notifications Flutter Crisp Chat, Crisp Chat notifications, Flutter Crisp Chat push notifications"

prev:
  text: 'Customizations'
  link: '/core_feature/customizations.md'

next:
  text: 'Multi Language Support'
  link: '/advanced_feature/multi_language_support.md'
---

# Notifications

The **Flutter Crisp Chat** plugin supports push notifications for incoming messages. Follow these steps to enable and handle notifications:

## Enable Notifications

Ensure that notifications are enabled in your Crisp configuration:

```dart
CrispConfig config = CrispConfig(
  websiteID: "YOUR_WEBSITE_ID",
  enableNotifications: true,
);
```

## Handle Notifications

Implement notification handling in your app. For example:

```dart
// Example code for handling notifications
// Add your implementation here
```

## Next Steps

After enabling notifications, you can manage user sessions. Refer to the  section for more details.
