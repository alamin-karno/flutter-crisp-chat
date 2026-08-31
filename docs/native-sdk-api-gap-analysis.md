# Native SDK API Gap Analysis (Android + iOS)

**Date:** 2026-07-21 (updated 2026-08-31)
**Status:** Item #1 implemented (`feat/crisp-chat-events`, 2026-07-21). Item #2 implemented (`feat/run-bot-scenario`, 2026-08-31) — turned out to have full cross-platform parity (Web SDK included, see below), so it shipped on all platforms rather than mobile-only. #3 confirmed feasible, not yet scheduled. Remaining items are still an idea backlog.

## Sources checked

- Android SDK available APIs: https://github.com/crisp-im/crisp-sdk-android/wiki/2.-Available-APIs
- Android SDK guide: https://docs.crisp.chat/guides/chatbox-sdks/android-sdk/
- iOS SDK guide: https://docs.crisp.chat/guides/chatbox-sdks/ios-sdk/
- Android SDK releases: https://github.com/crisp-im/crisp-sdk-android/releases
- iOS SDK releases: https://github.com/crisp-im/crisp-sdk-ios/releases
- Crisp Web SDK `$crisp` reference: https://docs.crisp.chat/guides/chatbox-sdks/web-sdk/dollar-crisp/
- Current implementation: `android/src/main/java/com/alaminkarno/flutter_crisp_chat/FlutterCrispChatPlugin.java`, `CrispChatNotificationService.java`, `ios/crisp_chat/Sources/crisp_chat/FlutterCrispChatPlugin.swift`, `lib/crisp_chat.dart`, `lib/src/flutter_crisp_chat_platform_interface.dart`, `lib/src/config.dart`

## SDK release check (2026-08-31)

Checked both native SDKs' GitHub releases against the versions this plugin pins (`android/build.gradle`: `im.crisp:crisp-sdk:2.0.23`; `ios/crisp_chat.podspec` + `Package.swift`: `~> 2.13.0`).

- **Android `2.0.24`** (released 2026-08-31, same day as this check) — bug-fix release, no new public API. Fixes a race condition between the `session:joined` event and `resetChatSession`, an NPE on `prelude`, and — notably — **#242: both Helpdesk and Chat shown when calling `searchHelpdesk` before starting chatbox**, which directly affects this plugin's `openHelpdesk()`/`Crisp.searchHelpdesk()` call path. Also bumps `androidx.core:core` `1.17.0` → `1.18.0` (fixes an insets-related crash). **Recommended: bump to `2.0.24`** — see companion bump below/`fix/bump-android-sdk-2.0.24` branch.
- **iOS `3.0.0-beta.1`–`3.0.0-beta.8`** (2026-08-03 → 2026-08-24, still beta, 8 betas deep) — major version bump: "Switch to new SDK architecture." No new public API disclosed in any beta's release notes; beta.7 fixes a static-linking issue, beta.8 adds an `Info.plist` usage-description validation that can block chat from starting unless explicitly disabled. **Not adopting** — this is a pre-GA major version with an architecture rewrite and a source-compat–relevant new failure mode (missing Info.plist keys now hard-blocks the chat by default); pinning to it now risks unannounced breaking changes before GA. Stay on `~> 2.13.0` (still receiving releases as of `2.13.0`, 2026-02-06) and revisit once `3.0.0` reaches a stable tag.

## Codebase re-check for gap candidates (2026-08-31)

Re-grepped `lib/`, `android/src`, `ios/crisp_chat/Sources` for every method named in the gap list below (`runBotScenario`, `showMessage`, `setSessionBool`, `getSDKVersion`, `pushSessionEvents`, `addLogger`/`setLogLevel`, `isCrispIntent`/`isSessionExist`) — none were present prior to this update, confirming the list was still accurate. Pinned SDK versions are unchanged from the #1 decompile (Android `2.0.23`, iOS `2.13.0`), so the decompiled signatures below remain valid.

**New finding while implementing #2:** the Crisp Web SDK also exposes bot scenario execution — `$crisp.push(["do", "bot:scenario:run", [identifier, variables?]])` (per `docs.crisp.chat/guides/chatbox-sdks/web-sdk/dollar-crisp/`) — and local message injection — `$crisp.push(["do", "message:show", [type, content]])`, the web equivalent of #3's `showMessage`. Neither was checked in the original #2/#3 write-up below (which only covered Android/iOS). This means both #2 and #3 have **full four-platform parity** (Android, iOS, Web, desktop-via-WebView), not just mobile — worth keeping in mind when scoping #3 next: it should ship cross-platform too, using the same `Message.Content`/`message:show` shapes on both sides.

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

### 2. `runBotScenario(String)` — ✅ implemented (`feat/run-bot-scenario`)

Confirmed via the same decompiles: **both mobile platforms have this.** Android: `Crisp.runBotScenario(String)` (top-level, per the decompiled `Crisp.class`). iOS: `Session.runBotScenario(id:)` (i.e. `CrispSDK.session.runBotScenario(id:)`, per the `.swiftinterface`). The Web SDK also has an equivalent (`$crisp.push(["do", "bot:scenario:run", [identifier]])`, found while implementing this), so it shipped with full Android/iOS/Web/desktop parity as `FlutterCrispChat.runBotScenario({required String scenarioId})`, matching the `pushSessionEvent`/`openHelpdesk` platform-interface + method-channel + JS-bridge pattern. Throws `ArgumentError` for an empty/whitespace `scenarioId`. Variables (the Web SDK's optional second `bot:scenario:run` argument) were deliberately left out of v1 scope since neither native SDK's single-string signature exposes them.

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

**#1 and #2 are done.** Next highest leverage: **#3 (`showMessage`)** — its `Content` shape is already documented above from the #1 decompile work, and #2's implementation confirmed the Web SDK has a parity `message:show` command, so #3 should also target all four platforms rather than mobile-only. Smaller wins (#4–#8) can be picked up independently and don't depend on any of the above.

Revisit `docs/ios-unread-workaround-decision.md` now that #1 is implemented — a host app can listen for `messageReceived`/`messageSent` on `onCrispEvent` to track read state locally, which may reduce (but does not eliminate, since `origin`/read-receipt semantics on the REST side are unaffected) reliance on `markMessagesAsRead()`.
