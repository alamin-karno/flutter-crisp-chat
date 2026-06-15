---
head:
  - - meta
    - name: description
      content: Flutter Crisp Chat — Crisp live chat for Android, iOS, Web, and desktop with push notifications on mobile, user management, and session control.

  - - meta
    - name: keywords
      content: "flutter crisp chat overview, crisp chat flutter plugin, flutter live chat, crisp sdk flutter integration"

prev: false

next:
  text: 'Installation'
  link: '/getting_started/install'
---

# Overview

**Flutter Crisp Chat** (`crisp_chat`) is a Flutter plugin that integrates the [Crisp](https://crisp.chat) live chat platform into your app on **Android, iOS, Web, and desktop** (macOS, Windows, Linux). Mobile targets use the official Crisp Android and iOS SDKs; Web and desktop use the official Crisp Web Chat SDK, with the same Dart API for opening chat, sessions, and REST helpers.

## Why Crisp Chat?

[Crisp](https://crisp.chat) is a customer messaging platform used by thousands of companies worldwide. It provides live chat, a shared inbox, knowledge base, and CRM — all in one place. This Flutter plugin brings that experience into your app on **mobile, web, and desktop**.

## What This Plugin Provides

| Feature                 | Description                                                                                      |
|-------------------------|--------------------------------------------------------------------------------------------------|
| **Open Chat**           | Launch Crisp chat with one method call (native UI on mobile, web chatbox on web/desktop)         |
| **User Identification** | Set user email, name, phone, avatar, and company details                                         |
| **Push Notifications**  | FCM (Android) and APNs (iOS); not available on Web/desktop                                       |
| **Session Management**  | Set custom session data, segments, and events                                                    |
| **Unread Messages**     | Query unread message count via the Crisp REST API                                                |
| **Session Control**     | Get session identifiers and reset sessions on logout                                             |
| **Video / audio calls** | Optional on **iOS** (build-time `CrispWebRTC` SDK); Web/desktop via web chatbox; Android not yet |
| **Helpdesk / FAQ**      | Open the Crisp Helpdesk search screen or a specific article directly (Android, iOS, Web, desktop) |

## Supported SDK Versions

| Platform | SDK                                      | Version / source                                                                                    |
|----------|------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Android  | Crisp Android SDK                        | `2.0.20`                                                                                            |
| iOS      | Crisp iOS SDK (`Crisp` or `CrispWebRTC`) | `~> 2.13.0` — see [Enable video calls](/getting_started/platform_setup#enable-video-calls-ios-only) |
| Web      | Crisp Web Chat SDK (`$crisp`)            | Loaded from `https://client.crisp.chat/l.js`                                                        |
| Desktop  | Same as Web (embedded WebView)           | `desktop_webview_window` + browser fallback                                                         |

## Requirements

| Platform          | Minimum Version                                                 |
|-------------------|-----------------------------------------------------------------|
| Flutter           | 3.24.0+ (3.0+ for mobile-only usage)                            |
| Dart              | 3.5.0+ (2.15.0+ for mobile-only usage)                          |
| Android           | API 23 (Android 6.0)                                            |
| iOS               | 13.0+                                                           |
| compileSdkVersion | 36                                                              |
| Web / desktop     | See [Supported Platforms](/getting_started/supported_platforms) |

## Quick Links

- [Installation](/getting_started/install) — Add the package to your project
- [Platform Setup](/getting_started/platform_setup) — Android, iOS, Web, and desktop (includes [optional iOS video calls](/getting_started/platform_setup#enable-video-calls-ios-only))
- [Supported Platforms](/getting_started/supported_platforms) — Web and desktop support matrix
- [Quick Start](/getting_started/quick_start) — Open your first chat in 5 minutes
- [Push Notifications](/notifications/firebase_setup) — Set up FCM and APNs
- [API Reference](/reference/api_documentation) — Complete method documentation
- [Full Example](/reference/examples) — Working example app code

## Package Links

- [pub.dev](https://pub.dev/packages/crisp_chat)
- [GitHub Repository](https://github.com/alamin-karno/flutter-crisp-chat)
- [Issue Tracker](https://github.com/alamin-karno/flutter-crisp-chat/issues)
- [Changelog](/reference/changelog)

## Next Steps

- [Installation](/getting_started/install) — Add the package to your project
- [Platform Setup](/getting_started/platform_setup) — Android, iOS, Web, and desktop configuration
