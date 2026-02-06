---
head:
  - - meta
    - name: description
      content: Open your first Crisp chat in 5 minutes with the Flutter Crisp Chat plugin.

  - - meta
    - name: keywords
      content: "flutter crisp chat quick start, crisp chat hello world, flutter crisp chat example, open crisp chat flutter"

prev:
  text: 'Platform Setup'
  link: '/getting_started/platform_setup'

next:
  text: 'Configuration'
  link: '/core_feature/configuration'
---

# Quick Start

Open your first Crisp chat in under 5 minutes.

## Prerequisites

1. You have [installed](/getting_started/install) the `crisp_chat` package
2. You have completed [platform setup](/getting_started/platform_setup)
3. You have a Crisp Website ID from your [Crisp Dashboard](https://app.crisp.chat/)

### Get Your Website ID

Go to your [Crisp Dashboard](https://app.crisp.chat/), navigate to **Settings** > **Website Settings**, and copy your **Website ID**:

![Crisp Dashboard](https://github.com/user-attachments/assets/ef6b9932-8141-4108-8f11-f5f3b40cbe15)

## Minimal Example

```dart
import 'package:flutter/material.dart';
import 'package:crisp_chat/crisp_chat.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Crisp Chat')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              final config = CrispConfig(
                websiteID: 'YOUR_WEBSITE_ID', // Replace with your Website ID
              );
              FlutterCrispChat.openCrispChat(config: config);
            },
            child: const Text('Open Chat'),
          ),
        ),
      ),
    );
  }
}
```

Replace `YOUR_WEBSITE_ID` with your actual Website ID from the Crisp dashboard. That's it — tap the button and the native Crisp chat UI will open.

## What's Next?

Now that you have a basic chat working, explore the full capabilities:

- [Configuration](/core_feature/configuration) — Customize `CrispConfig` with user details, tokens, and segments
- [User & Company](/core_feature/user_and_company) — Identify users with email, name, phone, avatar, and company info
- [Session Management](/core_feature/session_management) — Set custom session data, segments, events, and reset sessions
- [Push Notifications](/notifications/firebase_setup) — Enable FCM and APNs notifications
- [Unread Messages](/core_feature/unread_messages) — Query unread message count via REST API
