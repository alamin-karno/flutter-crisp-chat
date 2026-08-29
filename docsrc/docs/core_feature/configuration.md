---
head:
  - - meta
    - name: description
      content: Configure the Flutter Crisp Chat plugin with CrispConfig — website ID, token ID, user details, segments, and notification settings.

  - - meta
    - name: keywords
      content: "CrispConfig flutter, crisp chat configuration, flutter crisp chat setup, crisp website id"

prev:
  text: 'Quick Start'
  link: '/getting_started/quick_start'

next:
  text: 'iOS Features'
  link: '/core_feature/ios_features'
---

# Configuration

The `CrispConfig` class is the central configuration object for the Flutter Crisp Chat plugin. It defines your website ID, user details, session settings, and notification preferences.

## CrispConfig

```dart
CrispConfig config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',       // [required] Your Crisp Website ID
  tokenId: 'unique_user_token',        // [optional] Unique token to identify returning users
  sessionSegment: 'premium',           // [optional] Segment to categorize users
  user: crispUser,                     // [optional] User details (see User & Company)
  enableNotifications: true,           // [optional] Enable push notifications (default: true)
  modalPresentationStyle: ModalPresentationStyle.fullScreen, // [optional] iOS modal style (default: fullScreen)
);
```

### Parameters

| Parameter                | Type                      | Required | Default      | Description                                                              |
|--------------------------|---------------------------|----------|--------------|--------------------------------------------------------------------------|
| `websiteID`              | `String`                  | Yes      | —            | Your Crisp Website ID from the [dashboard](https://app.crisp.chat/)      |
| `tokenId`                | `String?`                 | No       | `null`       | A unique token to identify returning users across sessions               |
| `sessionSegment`         | `String?`                 | No       | `null`       | A segment string to categorize users (e.g., `"premium"`, `"trial"`)      |
| `user`                   | `User?`                   | No       | `null`       | User details like email, name, phone, avatar, and company                |
| `enableNotifications`    | `bool`                    | No       | `true`       | Push notifications (Android/iOS native SDK only; ignored on Web/desktop) |
| `modalPresentationStyle` | `ModalPresentationStyle?` | No       | `fullScreen` | iOS modal presentation style (ignored on Android, Web, desktop)          |

::: info Web and desktop
`websiteID`, `tokenId`, `sessionSegment`, and `user` apply on all platforms. See [Supported Platforms](/getting_started/supported_platforms) for API differences.
:::

## Website ID

Your Website ID is found in the [Crisp Dashboard](https://app.crisp.chat/) under **Settings** > **Website Settings**.

![Crisp Dashboard](https://github.com/user-attachments/assets/ef6b9932-8141-4108-8f11-f5f3b40cbe15)

## Crisp dashboard: Chatbox Security

In the [Crisp Dashboard](https://app.crisp.chat/), go to **Settings** → **Website Settings** → **Chatbox & Email Settings** → **Chatbox Security** and find **Lock the chatbox to website domain (and subdomains)**.

::: warning Android and iOS (native SDK)
This setting must be **disabled** when using the native Crisp SDK on **Android and iOS**. Domain lock validates browser page origins; mobile apps have no matching website domain, so the SDK session is rejected. You may see **"Error starting chat"** or a misleading `invalid_website_id` WebSocket error even when your Website ID is valid — `GET https://api.crisp.chat/v1/website/{websiteId}` can still return 200.

See [Crisp Android SDK](https://docs.crisp.chat/guides/chatbox-sdks/android-sdk/) and [Crisp iOS SDK](https://docs.crisp.chat/guides/chatbox-sdks/ios-sdk/) for the same requirement. Reported in [#148](https://github.com/alamin-karno/flutter-crisp-chat/issues/148).
:::

### Domain lock by platform

| Platform                       | Domain lock            | Guidance                                                                                                                                                                                                                                                                                        |
|--------------------------------|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Android / iOS**              | Must be **disabled**   | Native SDK has no browser origin; session is rejected → `Error starting chat` / misleading `invalid_website_id` ([#148](https://github.com/alamin-karno/flutter-crisp-chat/issues/148))                                                                                                         |
| **Web**                        | Can stay **enabled**   | Crisp validates the **page origin**. Host your Flutter web app on a domain (or subdomain) allowed in the dashboard lock list — e.g. if lock allows `example.com`, deploy at `https://app.example.com` or `https://example.com`. Local dev (`localhost`) may fail unless that origin is allowed. |
| **Desktop (embedded WebView)** | Should be **disabled** | Chat loads from a temporary `file://` page; there is no website origin to match, similar to mobile.                                                                                                                                                                                             |
| **Desktop (browser fallback)** | Should be **disabled** | Opens `https://app.crisp.chat/website/{id}/`, which is not your locked domain. Prefer disabling domain lock or use embedded WebView after fixing WebView2/WebKitGTK.                                                                                                                            |

If chat fails to connect on Web with domain lock enabled, check `window.location.origin` in DevTools against your allowed domains. See [Platform-Specific — Web](/troubleshooting/platform_specific#domain-lock-enabled) and [Platform-Specific — Desktop](/troubleshooting/platform_specific#domain-lock-enabled-1).

## Token ID

The `tokenId` is used to identify returning users. When a user opens the chat with the same `tokenId`, Crisp will restore their previous conversation history. This is useful for:

- Maintaining chat history across app reinstalls
- Linking a user's chat session to your backend user ID
- Ensuring the same user always sees their conversation

```dart
CrispConfig config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  tokenId: 'user_12345', // Your internal user ID
);
```

::: tip
Use a stable, unique identifier for `tokenId` — such as your app's user ID or a UUID. Don't use email addresses, as they may change.
:::

## Session Segment

Segments help you categorize users in the Crisp dashboard:

```dart
CrispConfig config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  sessionSegment: 'beta_testers',
);
```

## Opening the Chat

Pass the config to `openCrispChat`:

```dart
await FlutterCrispChat.openCrispChat(config: config);
```

This launches the native Crisp chat UI. The method validates the email and company URL (if provided) before opening.

::: warning
`openCrispChat` will throw an `ArgumentError` if:
- The user email is provided but is not a valid email format
- The company URL is provided but is not a valid URL
:::

## Full Example

```dart
final config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  tokenId: 'user_12345',
  sessionSegment: 'premium',
  user: User(
    email: 'john@example.com',
    signature: 'USER_EMAIL_HMAC_SHA256_SIGNATURE',
    nickName: 'John Doe',
    phone: '+1234567890',
    avatar: 'https://example.com/avatar.png',
    company: Company(
      name: 'Acme Inc',
      url: 'https://acme.com',
      companyDescription: 'Building great products',
      employment: Employment(title: 'CTO', role: 'Engineering'),
      geoLocation: GeoLocation(city: 'San Francisco', country: 'USA'),
    ),
  ),
  enableNotifications: true,
);

await FlutterCrispChat.openCrispChat(config: config);
```

## iOS Modal Presentation Styles

The `modalPresentationStyle` parameter controls how the Crisp chat view is presented on iOS devices. This is particularly important for preventing touch events from passing through to the underlying Flutter UI.

### Available Styles

| Style                | Description                                                        |
|----------------------|--------------------------------------------------------------------|
| `fullScreen`         | Covers the entire screen (default)                                 |
| `pageSheet`          | Standard page sheet with dimmed background                         |
| `formSheet`          | Centered form sheet                                                |
| `overFullScreen`     | Full screen with transparent overlay                               |
| `overCurrentContext` | Over current context                                               |
| `popover`            | Popover on iPad (centered anchor); adapts to full screen on iPhone |

### Example Usage

```dart
final config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  modalPresentationStyle: ModalPresentationStyle.pageSheet,
);

await FlutterCrispChat.openCrispChat(config: config);
```

::: tip Platform Specific
The `modalPresentationStyle` parameter only affects iOS devices. On Android, Crisp chat always opens as a full-screen activity. See [iOS Features](/core_feature/ios_features) for detailed iOS-specific configurations.
:::

## Next Steps

- [iOS Features](/core_feature/ios_features) — Detailed guide on iOS specific feature configuration
- [User & Company](/core_feature/user_and_company) — Set user and company details in CrispConfig

