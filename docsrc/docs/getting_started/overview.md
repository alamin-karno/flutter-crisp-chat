---
head:
  - - meta
    - name: description
      content: Flutter Crisp Chat — a Flutter plugin for integrating Crisp live chat natively on Android & iOS with push notifications, user management, and session control.

  - - meta
    - name: keywords
      content: "flutter crisp chat overview, crisp chat flutter plugin, flutter live chat, crisp sdk flutter integration"

prev: false

next:
  text: 'Installation'
  link: '/getting_started/install'
---

# Overview

**Flutter Crisp Chat** (`crisp_chat`) is a Flutter plugin that integrates the [Crisp](https://crisp.chat) live chat platform natively into your Android and iOS apps. It wraps the official Crisp Android SDK and Crisp iOS SDK, giving you a fully native chat experience with push notifications, user identification, session management, and more.

## Why Crisp Chat?

[Crisp](https://crisp.chat) is a customer messaging platform used by thousands of companies worldwide. It provides live chat, a shared inbox, knowledge base, and CRM — all in one place. This Flutter plugin lets you bring that experience directly into your mobile app.

## What This Plugin Provides

| Feature | Description |
|---|---|
| **Open Chat** | Launch the native Crisp chat UI with one method call |
| **User Identification** | Set user email, name, phone, avatar, and company details |
| **Push Notifications** | Full FCM (Android) and APNs (iOS) support with two handling modes |
| **Session Management** | Set custom session data, segments, and events |
| **Unread Messages** | Query unread message count via the Crisp REST API |
| **Session Control** | Get session identifiers and reset sessions on logout |

## Supported SDK Versions

| Platform | SDK | Version |
|---|---|---|
| Android | Crisp Android SDK | `2.0.16` |
| iOS | Crisp iOS SDK | `~> 2.13.0` |

## Requirements

| Platform | Minimum Version |
|---|---|
| Flutter | 3.0+ |
| Dart | 2.15.0+ |
| Android | API 23 (Android 6.0) |
| iOS | 13.0+ |
| compileSdkVersion | 36 |

## Quick Links

- [Installation](/getting_started/install) — Add the package to your project
- [Platform Setup](/getting_started/platform_setup) — Configure Android and iOS
- [Quick Start](/getting_started/quick_start) — Open your first chat in 5 minutes
- [Push Notifications](/notifications/firebase_setup) — Set up FCM and APNs
- [API Reference](/reference/api_documentation) — Complete method documentation
- [Full Example](/reference/examples) — Working example app code

## Package Links

- [pub.dev](https://pub.dev/packages/crisp_chat)
- [GitHub Repository](https://github.com/alamin-karno/flutter-crisp-chat)
- [Issue Tracker](https://github.com/alamin-karno/flutter-crisp-chat/issues)
- [Changelog](/reference/changelog)
