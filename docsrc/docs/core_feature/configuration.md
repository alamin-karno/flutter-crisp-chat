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
  text: 'User & Company'
  link: '/core_feature/user_and_company'
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
);
```

### Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `websiteID` | `String` | Yes | — | Your Crisp Website ID from the [dashboard](https://app.crisp.chat/) |
| `tokenId` | `String?` | No | `null` | A unique token to identify returning users across sessions |
| `sessionSegment` | `String?` | No | `null` | A segment string to categorize users (e.g., `"premium"`, `"trial"`) |
| `user` | `User?` | No | `null` | User details like email, name, phone, avatar, and company |
| `enableNotifications` | `bool` | No | `true` | Whether to enable push notifications for this site |

## Website ID

Your Website ID is found in the [Crisp Dashboard](https://app.crisp.chat/) under **Settings** > **Website Settings**.

![Crisp Dashboard](https://github.com/user-attachments/assets/ef6b9932-8141-4108-8f11-f5f3b40cbe15)

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

## Next Steps

- [User & Company](/core_feature/user_and_company) — Detailed guide on setting user and company information
- [Session Management](/core_feature/session_management) — Set custom session data, segments, and events
