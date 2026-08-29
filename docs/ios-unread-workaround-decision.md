# Workaround Decision: iOS Unread Count

**Date:** 2026-05-31  
**Status:** Adopted pending Crisp iOS SDK fix

## Problem

`getUnreadMessageCount()` reads server-side `unread.visitor` from the Crisp REST API. On iOS, the native Crisp SDK does not appear to send read receipts when a visitor reads operator messages, so the count stays non-zero after closing chat.

## Decision

Until Crisp fixes the iOS SDK, this plugin adopts:

1. **Document the limitation** — troubleshooting and unread messages docs explain the iOS behavior and link to upstream issue template.
2. **Provide `markMessagesAsRead()`** — apps call this after the visitor closes chat to reset `unread.visitor` via REST `PATCH /read`.
3. **Verification script** — `scripts/verify_unread_read_receipts.sh` for REST control tests (GET → PATCH → GET).
4. **Upstream issue** — report to [crisp-im/crisp-sdk-ios](https://github.com/crisp-im/crisp-sdk-ios) using [crisp-sdk-ios-unread-issue.md](./crisp-sdk-ios-unread-issue.md).

## Not chosen (for now)

| Option                          | Reason deferred                                                                                                                   |
|---------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| Auto mark-as-read on chat close | Requires native `onChatClosed` callback on iOS; assumes all opened chats mean "read all"; can be added later behind a config flag |
| Local badge tracking only       | iOS SDK exposes no message/chat events in this plugin; Android has `EventsCallback` but cross-platform inconsistency              |
| Docs only                       | `markMessagesAsRead()` is low-risk and gives apps an immediate fix                                                                |

## Recommended app integration

```dart
Future<void> openChatAndClearUnread({
  required CrispConfig config,
  required String websiteId,
  required String identifier,
  required String key,
}) async {
  await FlutterCrispChat.openCrispChat(config: config);

  // After user closes chat (poll session or use your own UX hook):
  await FlutterCrispChat.markMessagesAsRead(
    websiteId: websiteId,
    identifier: identifier,
    key: key,
  );
}
```

On Android, verify whether REST `unread.visitor` clears without `markMessagesAsRead`. If it does, call `markMessagesAsRead` only on iOS (`defaultTargetPlatform == TargetPlatform.iOS`).

## Revisit when

- Crisp confirms and ships iOS SDK read-receipt fix → remove workaround docs emphasis, keep `markMessagesAsRead` as optional API.
- Crisp confirms mobile SDKs never sync REST unread → document permanently; consider local tracking via Android `EventsCallback` + iOS when SDK adds events.
