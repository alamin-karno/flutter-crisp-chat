---
head:
  - - meta
    - name: description
      content: iOS-specific features in Flutter Crisp Chat — modal presentation styles, notification control, and native iOS integrations.

  - - meta
    - name: keywords
      content: "flutter crisp chat ios, crisp chat modal presentation, ios crisp notifications, crisp chat uimodalpresentationstyle"

prev:
  text: 'Configuration'
  link: '/core_feature/configuration'

next:
  text: 'User & Company'
  link: '/core_feature/user_and_company'
---

# iOS Features

The Flutter Crisp Chat plugin provides several iOS-specific features to help you integrate Crisp seamlessly into your iOS app.

## Modal Presentation Styles

On iOS, you can control how the Crisp chat view is presented using the `modalPresentationStyle` parameter. This is particularly important for preventing touch events from passing through to the underlying Flutter UI.

### Why Modal Presentation Matters

By default, iOS 13+ uses `.pageSheet` presentation style, which can allow touch events to pass through to the Flutter UI underneath. This happens when:

- The user taps on the dimmed area at the top of the modal
- The underlying UI has interactive elements (buttons, text fields, etc.)
- The chat doesn't cover the entire screen

### Available Presentation Styles

| Style                | UIModalPresentationStyle | Best For                               |
|----------------------|--------------------------|----------------------------------------|
| `fullScreen`         | .fullScreen              | Preventing touch-through (recommended) |
| `pageSheet`          | .pageSheet               | Standard iOS modal appearance          |
| `formSheet`          | .formSheet               | Smaller, centered dialogs              |
| `overFullScreen`     | .overFullScreen          | Transparent overlay needs              |
| `overCurrentContext` | .overCurrentContext      | Custom transition animations           |
| `popover`            | .popover                 | iPad-only popover presentations        |

### Implementation

```dart
import 'package:crisp_chat/crisp_chat.dart';

// Full screen - prevents all touch-through issues
final fullScreenConfig = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  modalPresentationStyle: ModalPresentationStyle.fullScreen,
);

// Page sheet - standard iOS look
final pageSheetConfig = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  modalPresentationStyle: ModalPresentationStyle.pageSheet,
);

// Form sheet - centered and smaller
final formSheetConfig = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  modalPresentationStyle: ModalPresentationStyle.formSheet,
);

await FlutterCrispChat.openCrispChat(config: fullScreenConfig);
```

### Platform Detection

Since modal presentation styles are iOS-specific, you might want to detect the platform:

```dart
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

CrispConfig getConfig() {
  final baseConfig = CrispConfig(
    websiteID: 'YOUR_WEBSITE_ID',
    // ... other config
  );

  // Only apply modal style on iOS
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return CrispConfig(
      websiteID: baseConfig.websiteID,
      modalPresentationStyle: ModalPresentationStyle.fullScreen,
      // ... copy other properties
    );
  }

  return baseConfig;
}
```

## Notification Control

iOS provides granular control over notification permission prompts through the `enableNotifications` parameter.

### Disabling Notification Prompts

```dart
final config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  enableNotifications: false, // Don't prompt for permissions
);

await FlutterCrispChat.openCrispChat(config: config);
```

### When to Disable Notifications

You might want to disable notifications when:

- Your app doesn't need push notifications
- You want to handle notifications through a different service
- You're testing and don't want to see permission dialogs
- You're building a demo or prototype

### Notification Flow

1. **With `enableNotifications: true`** (default):
   - Crisp SDK prompts for permission on first chat interaction
   - Users can receive push notifications for new messages
   - Permission dialog appears after sending the first message

2. **With `enableNotifications: false`**:
   - No permission prompt is shown
   - Users can still chat normally
   - No push notifications will be delivered

## Native iOS Integration

The plugin handles several iOS-specific integrations automatically:

### Device Token Registration

```swift
// Handled automatically in SwiftFlutterCrispChatPlugin.swift
CrispSDK.setDeviceToken(deviceToken)
```

### Notification Handling

```swift
// Handled automatically
CrispSDK.handlePushNotification(notification)
```

### Permission Management

```swift
// Controlled by enableNotifications flag
CrispSDK.setShouldPromptForNotificationPermission(false)
```

## Best Practices

1. **Use `fullScreen` for production apps** to prevent touch-through issues
2. **Test notification behavior** on both development and production builds
3. **Consider user experience** when deciding on notification prompts
4. **Handle iPad differently** - popover style only works on iPad
5. **Test on different iOS versions** - modal behaviors vary between iOS 13, 14, 15+

## Troubleshooting

### Touch Events Passing Through

```dart
// Solution: Use fullScreen presentation style
modalPresentationStyle: ModalPresentationStyle.fullScreen
```

### Notification Permission Still Shows

Ensure `enableNotifications: false` is set in `CrispConfig` before opening chat:

```dart
final config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  enableNotifications: false, // Must be set before opening
);
```

### Modal Not Working on Android

Remember that `modalPresentationStyle` is iOS-only. On Android, Crisp always opens as a full-screen activity.

## Next Steps

- [User & Company](/core_feature/user_and_company) - Setting user information
- [Session Management](/core_feature/session_management) — Set custom session data, segments, and events
