# Unread Count Verification Guide

This guide supports the iOS unread count root-cause analysis. Run these steps with your Crisp Marketplace REST credentials.

## Prerequisites

- Crisp Marketplace plugin token (`identifier` + `key`)
- Website ID and an active session ID (`FlutterCrispChat.getSessionIdentifier()`)
- Operator messages in the conversation so `unread.visitor > 0`

## Automated REST verification

```bash
export CRISP_WEBSITE_ID="your-website-id"
export CRISP_IDENTIFIER="your-plugin-identifier"
export CRISP_KEY="your-plugin-key"
export CRISP_SESSION_ID="session_..."

chmod +x scripts/verify_unread_read_receipts.sh

# Current server unread counters
./scripts/verify_unread_read_receipts.sh get

# Control test: PATCH /read then GET again
./scripts/verify_unread_read_receipts.sh full
```

### Expected results

| Step                                            | Expected if iOS SDK bug    | Meaning                                             |
|-------------------------------------------------|----------------------------|-----------------------------------------------------|
| GET before reading chat                         | `unread.visitor > 0`       | Server has unread operator messages                 |
| Read all messages in iOS chat, close, GET again | `unread.visitor` unchanged | iOS SDK did not send read receipts                  |
| `full` script after PATCH /read                 | `unread.visitor = 0`       | REST mark-as-read works; plugin workaround is valid |

Record your results:

```
Platform: iOS / Android
Device:
SDK version:
GET before chat: unread.visitor =
GET after reading in native chat: unread.visitor =
GET after PATCH /read: unread.visitor =
```

## iOS manual test

1. Receive operator messages (push or while app open).
2. `./scripts/verify_unread_read_receipts.sh get` — note `unread.visitor`.
3. Open chat via `FlutterCrispChat.openCrispChat()`, read all messages, close chat.
4. Wait 10 seconds.
5. `./scripts/verify_unread_read_receipts.sh get` — compare with step 2.
6. `./scripts/verify_unread_read_receipts.sh mark-read` — confirm PATCH clears count.

## Android comparison test

Repeat the same steps on Android with the **same session** (same `CRISP_SESSION_ID`):

1. GET unread before opening `ChatActivity`.
2. Open chat, read all messages, close.
3. GET unread after close.

If Android shows `unread.visitor = 0` after step 3 but iOS does not, the bug is **iOS-specific**. File on [crisp-im/crisp-sdk-ios](https://github.com/crisp-im/crisp-sdk-ios).

If both platforms keep `unread.visitor > 0`, mobile SDKs may not sync read receipts in general — use `FlutterCrispChat.markMessagesAsRead()` after chat close.

## File upstream issue

```bash
./scripts/file-crisp-ios-unread-issue.sh
```

Or paste [crisp-sdk-ios-unread-issue.md](./crisp-sdk-ios-unread-issue.md) at:
https://github.com/crisp-im/crisp-sdk-ios/issues/new

## Plugin workaround

See [ios-unread-workaround-decision.md](./ios-unread-workaround-decision.md).
