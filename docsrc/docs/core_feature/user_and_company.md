---
head:
  - - meta
    - name: description
      content: Set user and company details in Flutter Crisp Chat — email, name, phone, avatar, company info, employment, and geolocation.

  - - meta
    - name: keywords
      content: "crisp chat user details, flutter crisp chat user, crisp company info, crisp user identification"

prev:
  text: 'Configuration'
  link: '/core_feature/configuration'

next:
  text: 'Session Management'
  link: '/core_feature/session_management'
---

# User & Company

You can identify users in Crisp by providing their details through the `User` and `Company` classes. This information appears in the Crisp dashboard alongside the conversation.

## User

The `User` class holds personal details about the chat user. All fields are optional.

```dart
final user = User(
  email: 'jane@example.com',
  nickName: 'Jane Smith',
  phone: '+1234567890',
  avatar: 'https://example.com/jane-avatar.png',
  company: myCompany, // See Company section below
);
```

### User Fields

| Field | Type | Description |
|---|---|---|
| `email` | `String?` | User's email address (validated format) |
| `nickName` | `String?` | Display name shown in the Crisp dashboard |
| `phone` | `String?` | Phone number |
| `avatar` | `String?` | URL to the user's avatar image |
| `company` | `Company?` | Company details (see below) |

::: warning Email Validation
If you provide an `email`, it must be a valid email format. `openCrispChat` will throw an `ArgumentError` if the email is invalid.
:::

## Company

The `Company` class provides information about the user's organization.

```dart
final company = Company(
  name: 'Acme Corporation',
  url: 'https://acme.com',
  companyDescription: 'Building innovative solutions for modern businesses.',
  employment: Employment(
    title: 'Senior Developer',
    role: 'Engineering',
  ),
  geoLocation: GeoLocation(
    city: 'San Francisco',
    country: 'USA',
  ),
);
```

### Company Fields

| Field | Type | Description |
|---|---|---|
| `name` | `String?` | Company name |
| `url` | `String?` | Company website URL (validated format) |
| `companyDescription` | `String?` | Short description of the company |
| `employment` | `Employment?` | User's role within the company |
| `geoLocation` | `GeoLocation?` | Company location |

### Employment

| Field | Type | Description |
|---|---|---|
| `title` | `String?` | Job title (e.g., "Software Engineer L-II") |
| `role` | `String?` | Department or role (e.g., "Engineering") |

### GeoLocation

| Field | Type | Description |
|---|---|---|
| `city` | `String?` | City name |
| `country` | `String?` | Country name |

## Full Example

```dart
final config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  tokenId: 'user_12345',
  user: User(
    email: 'jane@acme.com',
    nickName: 'Jane Smith',
    phone: '+1-555-0123',
    avatar: 'https://avatars.githubusercontent.com/u/12345',
    company: Company(
      name: 'Acme Corporation',
      url: 'https://acme.com',
      companyDescription: 'Innovative solutions for modern businesses.',
      employment: Employment(
        title: 'Senior Developer',
        role: 'Engineering',
      ),
      geoLocation: GeoLocation(
        city: 'San Francisco',
        country: 'USA',
      ),
    ),
  ),
);

await FlutterCrispChat.openCrispChat(config: config);
```

## How It Appears in Crisp

When user and company details are set, they appear in the Crisp dashboard sidebar next to the conversation. Your support agents can see the user's name, email, company, and other details without asking.

::: tip
Set user details **before** calling `openCrispChat`. The details are sent to Crisp when the chat is opened.
:::

## Next Steps

- [Session Management](/core_feature/session_management) — Set custom session data, segments, and events
- [Unread Messages](/core_feature/unread_messages) — Check for unread messages via REST API
