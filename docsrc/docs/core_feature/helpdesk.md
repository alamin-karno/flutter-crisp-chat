---
head:
  - - meta
    - name: description
      content: Open the Crisp Helpdesk or FAQ screen directly in your Flutter app — Android, iOS, Web, and desktop. API reference, platform implementation details, and troubleshooting.

  - - meta
    - name: keywords
      content: "flutter crisp helpdesk, crisp faq flutter, openHelpdesk flutter, crisp helpdesk article flutter, crisp_chat helpdesk"

prev:
  text: 'Unread Messages'
  link: '/core_feature/unread_messages'

next:
  text: 'Firebase Setup'
  link: '/notifications/firebase_setup'
---

# Helpdesk / FAQ

Open the Crisp Helpdesk search screen or a specific helpdesk article directly — without showing live chat first. This is useful for apps that want to direct users to self-service content before escalating to a live agent.

## Platform support

| Platform          | `openHelpdesk`                                        | `openHelpdeskArticle`                                        |
|-------------------|-------------------------------------------------------|--------------------------------------------------------------|
| **Android**       | Native SDK: `Crisp.searchHelpdesk()`                  | Native SDK: `Crisp.openHelpdeskArticle()`                    |
| **iOS**           | Native SDK: `CrispSDK.searchHelpdesk()`               | Native SDK: `CrispSDK.openHelpdeskArticle()`                 |
| **Web**           | `$crisp.push(["do", "helpdesk:search"])`              | `$crisp.push(["do", "helpdesk:article:open", [...]])`        |
| **Desktop**       | Same `$crisp` command in the embedded WebView         | Same `$crisp` command in the embedded WebView                |

## Open the helpdesk search screen

```dart
await FlutterCrispChat.openHelpdesk(websiteId: 'YOUR_WEBSITE_ID');
```

Opens the Crisp Helpdesk search interface where users can browse and search FAQ articles.

| Parameter   | Type     | Required | Description           |
|-------------|----------|----------|-----------------------|
| `websiteId` | `String` | Yes      | Your Crisp website ID |

**Throws:** `ArgumentError` if `websiteId` is empty or whitespace-only.

## Open a specific article

```dart
await FlutterCrispChat.openHelpdeskArticle(
  websiteId: 'YOUR_WEBSITE_ID',
  locale: 'en',
  slug: 'getting-started',
  title: 'Getting Started',    // optional
  category: 'General',         // optional
);
```

| Parameter   | Type      | Required | Description                                      |
|-------------|-----------|----------|--------------------------------------------------|
| `websiteId` | `String`  | Yes      | Your Crisp website ID                            |
| `locale`    | `String`  | Yes      | Language code (e.g. `'en'`, `'fr'`, `'de'`)     |
| `slug`      | `String`  | Yes      | Article slug from the Crisp Helpdesk dashboard   |
| `title`     | `String?` | No       | Optional display title override                  |
| `category`  | `String?` | No       | Optional category name                           |

**Throws:** `ArgumentError` if `websiteId`, `locale`, or `slug` is empty.

::: tip Finding the article slug
Go to your [Crisp Dashboard](https://app.crisp.chat/) → **Helpdesk** → open an article. The slug appears in the article URL and in the article settings panel.
:::

## Platform implementation

### Web

**`openHelpdesk`:** Calls `CrispWebSdk.ensureLoaded(websiteId)` (loads `client.crisp.chat/l.js` if not already loaded), then executes `$crisp.push(["do", "helpdesk:search"])`. The chatbox opens to the Helpdesk search panel.

**`openHelpdeskArticle`:** Same setup, then executes `$crisp.push(["do", "helpdesk:article:open", [locale, slug, title?, category?]])`. The chatbox opens directly to the specified article.

### Desktop (macOS / Windows / Linux)

**`openHelpdesk`:** If the WebView is not already open, calls `openCrispChat(config: CrispConfig(websiteID: websiteId))` to initialise the embedded window. Then executes `$crisp.push(["do", "helpdesk:search"])` via `evaluateJavaScript`. Falls back gracefully if no WebView is available (browser fallback opens the Crisp app page).

**`openHelpdeskArticle`:** Same — opens the WebView if needed, then executes `$crisp.push(["do", "helpdesk:article:open", [...]])`.

### Android

**`openHelpdesk`:**
1. Calls `Crisp.configure(context, websiteId)` to initialise the SDK for this website.
2. Calls `Crisp.searchHelpdesk(context)` — sets an internal pending flag inside the Crisp SDK.
3. Starts `ChatActivity` — once the WebSocket connects and the server settings arrive, the pending flag triggers the helpdesk search screen.

**`openHelpdeskArticle`:**
1. Calls `Crisp.configure(context, websiteId)`.
2. Calls the appropriate `Crisp.openHelpdeskArticle()` overload based on which optional parameters (`title`, `category`) are provided, passing `locale` and `slug`.

### iOS

**`openHelpdesk`:**
1. Calls `CrispSDK.configure(websiteID:)`.
2. Calls `CrispSDK.searchHelpdesk()`.
3. Presents `ChatViewController` via a dedicated `UIWindow` at `.alert` level (same mechanism as `openCrispChat`).

**`openHelpdeskArticle`:**
1. Calls `CrispSDK.configure(websiteID:)`.
2. Calls `CrispSDK.openHelpdeskArticle(locale:slug:title:category:)` with the provided parameters.
3. Presents `ChatViewController` in the same way.

## Full example

```dart
import 'package:flutter/material.dart';
import 'package:crisp_chat/crisp_chat.dart';

class SupportPage extends StatelessWidget {
  final String websiteId = 'YOUR_WEBSITE_ID';

  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await FlutterCrispChat.openHelpdesk(websiteId: websiteId);
              },
              child: const Text('Browse FAQ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await FlutterCrispChat.openHelpdeskArticle(
                  websiteId: websiteId,
                  locale: 'en',
                  slug: 'getting-started',
                );
              },
              child: const Text('Getting Started Article'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Troubleshooting

### The helpdesk screen doesn't appear (Android)

The helpdesk is loaded after the Crisp WebSocket connects. If your website has **domain lock** enabled, the connection is rejected before the helpdesk can load. Disable **Lock the chatbox to website domain** under **Settings → Website Settings → Chatbox & Email Settings → Chatbox Security**. See [Configuration — Chatbox Security](/core_feature/configuration#crisp-dashboard-chatbox-security).

### The helpdesk panel doesn't open on Web or desktop

Make sure the **Crisp chatbox is allowed to load** on your domain (Web) or from `file://` origins (desktop). On Web, check your Content-Security-Policy allows `https://client.crisp.chat`. On desktop, make sure the WebView runtime is installed (WebView2 on Windows, WebKitGTK on Linux) and that the macOS sandbox has **Outgoing Connections (Client)** enabled.

If the WebView opens but then shows an error, check that domain lock is **disabled** in the Crisp dashboard (see above).

## Next Steps

- [API Reference](/reference/api_documentation#openhelpdesk) — Full method signatures
- [Configuration](/core_feature/configuration) — Set up `CrispConfig`
- [Session Management](/core_feature/session_management) — Manage sessions alongside helpdesk
