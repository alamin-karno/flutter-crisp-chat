---
head:
  - - meta
    - name: description
      content: Check unread message count in Flutter Crisp Chat using the Crisp REST API with authentication tokens.

  - - meta
    - name: keywords
      content: "crisp unread messages, flutter crisp unread count, crisp rest api flutter, crisp api identifier key"

prev:
  text: 'Session Management'
  link: '/core_feature/session_management'

next:
  text: 'Firebase Setup'
  link: '/notifications/firebase_setup'
---

# Unread Messages

The plugin provides a method to check the number of unread messages for the current visitor session using the Crisp REST API.

## Usage

```dart
int? unreadCount = await FlutterCrispChat.getUnreadMessageCount(
  websiteId: 'YOUR_WEBSITE_ID',
  identifier: 'YOUR_CRISP_API_IDENTIFIER',
  key: 'YOUR_CRISP_API_KEY',
);

if (unreadCount != null && unreadCount > 0) {
  print('You have $unreadCount unread messages.');
}
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `websiteId` | `String` | Your Crisp Website ID |
| `identifier` | `String` | Your Crisp REST API Identifier |
| `key` | `String` | Your Crisp REST API Key |

### Return Value

- Returns an `int` with the unread message count if successful
- Returns `null` if no active session exists or an error occurs
- Returns `0` if the session exists but has no unread messages

## Obtaining API Credentials

The `identifier` and `key` are **not** the same as your Crisp dashboard login. They are REST API credentials from the Crisp Marketplace.

### Step-by-Step

1. Go to the [Crisp Marketplace](https://marketplace.crisp.chat/)
2. Sign in or create an account (this is separate from your main Crisp account)
3. Go to **Plugins** > click **New Plugin**
4. Select **Private** as the plugin type
5. Name your plugin (e.g., "My Flutter App") and click **Create**
6. Go to the **Tokens** tab > scroll to **Development Token**
7. Copy your `identifier` and `key`

### Link Your Workspace

Before using the token, associate your marketplace account with your Crisp workspace:

1. Go to **Settings** in your Crisp Marketplace account
2. Click **Add Trusted Workspace** and submit your `website_id`
3. Enter your main Crisp account credentials and 2FA token (if enabled)

::: tip Production Tokens
Development tokens have rate limits. For production use, obtain a production token from the Crisp Marketplace once your plugin is ready.
:::

## Example: Badge with Unread Count

```dart
class ChatButton extends StatefulWidget {
  const ChatButton({super.key});

  @override
  State<ChatButton> createState() => _ChatButtonState();
}

class _ChatButtonState extends State<ChatButton> {
  int unreadCount = 0;

  void _checkUnread() async {
    int? count = await FlutterCrispChat.getUnreadMessageCount(
      websiteId: 'YOUR_WEBSITE_ID',
      identifier: 'YOUR_IDENTIFIER',
      key: 'YOUR_KEY',
    );

    if (count != null && count > 0) {
      setState(() => unreadCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Badge.count(
      count: unreadCount,
      isLabelVisible: unreadCount > 0,
      child: ElevatedButton(
        onPressed: _checkUnread,
        child: const Text('Messages'),
      ),
    );
  }
}
```

## How It Works

Internally, `getUnreadMessageCount` does the following:

1. Calls `getSessionIdentifier()` to get the current session ID
2. Makes a GET request to `https://api.crisp.chat/v1/website/{websiteId}/conversation/{sessionId}`
3. Authenticates with Basic auth using your `identifier:key`
4. Parses the `data.unread.visitor` field from the response

If there is no active session (e.g., the user hasn't opened the chat yet), the method returns `null`.

## Next Steps

- [Firebase Setup](/notifications/firebase_setup) — Set up push notifications for your app
