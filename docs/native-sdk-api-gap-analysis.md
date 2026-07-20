# Native SDK API Gap Analysis (Android + iOS)

**Date:** 2026-07-21
**Status:** Item #1 implemented (`feat/crisp-chat-events`, 2026-07-21). #2/#3 confirmed feasible, not yet scheduled. Remaining items are still an idea backlog.

## Sources checked

- Android SDK available APIs: https://github.com/crisp-im/crisp-sdk-android/wiki/2.-Available-APIs
- Android SDK guide: https://docs.crisp.chat/guides/chatbox-sdks/android-sdk/
- iOS SDK guide: https://docs.crisp.chat/guides/chatbox-sdks/ios-sdk/
- Current implementation: `android/src/main/java/com/alaminkarno/flutter_crisp_chat/FlutterCrispChatPlugin.java`, `CrispChatNotificationService.java`, `ios/crisp_chat/Sources/crisp_chat/FlutterCrispChatPlugin.swift`, `lib/crisp_chat.dart`, `lib/src/flutter_crisp_chat_platform_interface.dart`, `lib/src/config.dart`

## Already covered in this plugin

Configure/token, user fields (email+signature, phone, nickname, avatar, company+employment+geolocation), `setSessionString`/`setSessionInt`, segments (single + list, with overwrite), single session event push, reset session, get session identifier, helpdesk search + article, push notification registration/handling, `openChatboxFromNotification` (Android), video-call capability flag (iOS WebRTC only — correct, since the Android SDK doesn't expose call APIs).

## Gaps — ranked by value

### 1. SDK event callbacks — ✅ implemented (`feat/crisp-chat-events`)

Android exposes `Crisp.addCallback(EventsCallback)` / `removeCallback(EventsCallback)`. iOS exposes an equivalent `Crisp.Callback` enum + `CrispSDK.addCallback`/`removeCallback(token:)`. Both are now wired up as `FlutterCrispChat.onCrispEvent`, a broadcast `Stream<CrispChatEvent>` — the native callback registers on first `.listen()` and unregisters once the last listener cancels.

The docs pages for both SDKs were incomplete, so the actual shipped API was verified by decompiling the pinned binaries directly:
- Android: downloaded `im.crisp:crisp-sdk:2.0.23` from Maven Central, ran `javap` on `classes.jar`. Exact interface:
  ```java
  public interface im.crisp.client.external.EventsCallback {
    void onSessionLoaded(String sessionId);
    void onChatOpened();
    void onChatClosed();
    void onMessageSent(Message message);
    void onMessageReceived(Message message);
    void onNotificationReceived(Map<String, String> data);
  }
  ```
  `Message.getOrigin().getValue()` can be one of 8 raw strings (`Message.Origin.Type`: `CHAT, EMAIL, URN, DIFF, HISTORY, LOCAL, NETWORK, UPDATE`); `Message.getType()` is one of `TEXT, FILE, ANIMATION, AUDIO, PICKER, FIELD, CAROUSEL`.
- iOS: downloaded `Crisp_2.13.0.zip` from the SDK's GitHub releases, read the `.swiftinterface` inside the XCFramework (the real public API for a closed-source binary framework). Exact enum:
  ```swift
  public enum Callback {
    case chatClosed(VoidHandler)
    case chatOpened(VoidHandler)
    case messageReceived(MessageHandler)   // (Message) -> Void
    case messageSent(MessageHandler)
    case sessionLoaded(SessionIdHandler)   // (String) -> Void
  }
  ```
  `Message.origin` is only 3 cases (`.local`/`.network`/`.update`) — narrower than Android's 8. `Message.content` has 9 cases (adds `textWithAttachment`/`textWithVideoAttachment` on top of Android's 7).

**Asymmetries handled:** Android's 6th event, `onNotificationReceived`, has no iOS equivalent → exposed as `CrispEventType.notificationReceived`, Android-only, iOS simply never emits it. `origin` is passed through as a raw nullable `String` (not a strict enum) rather than lossily mapping 8 Android values onto 3 iOS ones. iOS's two extra text-like content cases both map to `contentType: text`.

**v1 scope:** `CrispMessage` is a minimal summary (`isMe`, `from`, `origin`, `timestamp`, `fingerprint`, `contentType`, `text`-if-text) — rich content (carousel targets, picker choices, file/audio metadata) was deliberately deferred; see #3 below, which is now easier to scope given the same decompiled `Content`/`Message.Content` shapes are already documented here.

See [Chat Events](https://alamin-karno.github.io/flutter-crisp-chat/core_feature/chat_events) and `lib/src/crisp_event.dart`.

### 2. `runBotScenario(String)` (Android) / iOS equivalent — confirmed feasible

Confirmed via the same decompiles: **both platforms have this.** Android: `Crisp.runBotScenario(String)` (top-level, per the decompiled `Crisp.class`). iOS: `Session.runBotScenario(id:)` (i.e. `CrispSDK.session.runBotScenario(id:)`, per the `.swiftinterface`). Not yet implemented in this plugin, but no cross-platform-shape risk remains — both take a single scenario/id string.

### 3. `showMessage(Content)` (Android `Crisp.showMessage`) — confirmed feasible

Confirmed via the same decompiles: **both platforms have this.** Android: `Crisp.showMessage(Content)`. iOS: `CrispSDK.showMessage(with: Message.Content)` — same 7 shared content cases as event messages (`text, file, animation, audio, picker, field, carousel`), plus iOS's 2 extra text-attachment cases. Injects a local operator message into the chatbox without a round trip to an operator. Not implemented on either platform. Content model is the most complex of these gaps (multiple content types) — would need its own Dart sealed-class-style API, and the field-level Content shapes decompiled for #1 (`Message.Content` cases and their associated types) are the starting reference for that model.

### 4. Batch session events — `pushSessionEvents(List<SessionEvent>)`

Only `pushSessionEvent` (singular) is exposed today. Logging N events currently means N method-channel round trips instead of one. Small win: reduces channel chatter for apps that log several analytics-style events together.

### 5. `setSessionBool(key, bool)`

Android exposes bool session values alongside string/int (`Crisp.setSessionBool`); we only expose `setSessionString`/`setSessionInt`. Straightforward parity gap — confirm iOS SDK has a bool setter too before adding.

### 6. `Crisp.getSDKVersion()`

Expose the native SDK version through the channel for diagnostics/support tickets ("what native SDK version is this build running").

### 7. Custom logger / `setLogLevel` (Android: `Crisp.addLogger`, `Crisp.setLogLevel`)

Could pipe Crisp's internal SDK logs into Dart's log output during development. Low priority, dev-experience only.

### 8. `CrispNotificationClient.isCrispIntent()` / `isSessionExist()` (Android)

Not used. Could harden `openChatboxFromNotification` by checking these before acting, instead of assuming every launch intent is Crisp-relevant.

## Platform-parity note (not a gap, just worth documenting)

Android's `openChatboxFromNotification` (driven by `onNewIntent`) has no real iOS equivalent — iOS's `CrispSDK.handlePushNotification(_:)` likely already opens the chat itself when a notification is tapped, so the current "always return `false`" on iOS is probably correct behavior, not an oversight. Worth a code comment pointing here so a future contributor doesn't "fix" it unnecessarily.

## Suggested starting point

**#1 is done.** Next highest leverage: **#3 (`showMessage`)**, now that its `Content` shape is already documented above from the #1 decompile work, followed by **#2 (`runBotScenario`)**, which is a trivial single-string-argument addition on both platforms. Smaller wins (#4–#8) can be picked up independently and don't depend on any of the above.

Revisit `docs/ios-unread-workaround-decision.md` now that #1 is implemented — a host app can listen for `messageReceived`/`messageSent` on `onCrispEvent` to track read state locally, which may reduce (but does not eliminate, since `origin`/read-receipt semantics on the REST side are unaffected) reliance on `markMessagesAsRead()`.
