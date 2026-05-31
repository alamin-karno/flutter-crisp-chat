# Crisp iOS SDK Issue — Unread Count Not Clearing

Use this document to file an issue on the official Crisp iOS SDK repository:

**Create issue:** https://github.com/crisp-im/crisp-sdk-ios/issues/new

---

## Title

iOS SDK does not reset `unread.visitor` after visitor reads operator messages in ChatViewController

## Description

### Environment

- **SDK:** Crisp iOS `>= 2.13.0` (via [flutter-crisp-chat](https://github.com/alamin-karno/flutter-crisp-chat) plugin)
- **Devices:** iPhone 16e, iPhone 15 Pro Max
- **OS:** iOS 26.2
- **Flutter:** 3.41.9

### Steps to reproduce

1. Start a Crisp session and receive operator messages so `unread.visitor > 0`.
2. Confirm via REST API:
   ```
   GET /v1/website/{website_id}/conversation/{session_id}
   ```
   Response includes `"unread": { "operator": 0, "visitor": N }` where `N > 0`.
3. Open chat with `ChatViewController` (presented from Flutter via `CrispSDK`).
4. Scroll through and read all operator messages.
5. Dismiss/close the chat UI.
6. Wait 5–10 seconds.
7. Repeat the same GET request.

### Actual behavior

`unread.visitor` remains unchanged (e.g. still `6`) after the visitor has read all operator messages in the native iOS chat UI.

The same stale value is returned by `GET /v1/website/{website_id}/conversation/{session_id}` — this is server-side state, not a client parsing issue.

### Expected behavior

After the visitor reads all operator messages in the chat UI, `unread.visitor` should be `0` — matching Web Chatbox SDK behavior where read receipts are sent automatically.

### Control test (REST mark-as-read works)

Manually calling the REST API clears the count:

```bash
PATCH /v1/website/{website_id}/conversation/{session_id}/read
Content-Type: application/json

{"from": "operator", "origin": "chat"}
```

After this PATCH (HTTP 202), a subsequent GET shows `unread.visitor: 0`.

This proves:
- The REST unread counter is correct and updatable.
- The iOS SDK is not sending read receipts to the backend when the visitor views messages.

### Question for Crisp team

Should the iOS SDK automatically send read receipts (like the Web SDK) when a visitor views operator messages? If yes, this appears to be an iOS SDK bug. If no, please document that `unread.visitor` is not reliable for mobile badge counts and recommend local tracking or explicit REST mark-as-read.

### References

- [Get a Conversation](https://docs.crisp.chat/references/rest-api/v1/#get-a-conversation) — `unread.visitor` field
- [Mark Messages As Read In Conversation](https://docs.crisp.chat/references/rest-api/v1/#mark-messages-as-read-in-conversation)
- [iOS SDK guide](https://docs.crisp.chat/guides/chatbox-sdks/ios-sdk/) — no unread/read APIs documented

### Verification script

See `scripts/verify_unread_read_receipts.sh` in the flutter-crisp-chat repository for automated REST verification.
