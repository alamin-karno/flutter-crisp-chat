# [Unreleased]

# 2.8.0

Added
---
* `FlutterCrispChat.runBotScenario({required String scenarioId})` — runs a Crisp Bot scenario (as configured in the Bot plugin on your Crisp website) on Android, iOS, Web, and desktop. Wraps `Crisp.runBotScenario(String)` (Android), `CrispSDK.session.runBotScenario(id:)` (iOS), and `$crisp.push(["do", "bot:scenario:run", [scenarioId]])` (Web/desktop). Throws `ArgumentError` for an empty/whitespace-only `scenarioId`.

Changed
---
* Bumped the example app's Android build tooling — Gradle `8.11.1` → `8.14.5`, Android Gradle Plugin `8.9.1` → `8.11.1`, Kotlin `2.1.0` → `2.2.20` — to clear Flutter's deprecated-version-support warnings, and raised the example's Gradle daemon heap (`org.gradle.jvmargs`) from `1536M` to `3072M` to avoid an out-of-memory failure under the newer AGP.
* Upgraded Crisp Android SDK from `2.0.23` to `2.0.24` — fixes a race condition between the `session:joined` event and `resetChatSession`, an NPE on `prelude`, and both Helpdesk and Chat showing when calling `searchHelpdesk` before starting the chatbox (the latter directly affects this plugin's `openHelpdesk()`). Also bumps the transitive `androidx.core:core` dependency from `1.17.0` to `1.18.0`, fixing a crash on insets. See the [`2.0.24` release notes](https://github.com/crisp-im/crisp-sdk-android/releases/tag/v2.0.24).

Fixed
---
* Fixed iOS Crisp blocking non-Crisp foreground notifications ([#78](https://github.com/alamin-karno/flutter-crisp-chat/issues/78), [#179](https://github.com/alamin-karno/flutter-crisp-chat/pull/179)) — `FlutterCrispChatPlugin` no longer unconditionally takes over `UNUserNotificationCenter.current().delegate`. If the existing delegate already conforms to `FlutterAppLifeCycleProvider` (i.e. `FlutterAppDelegate` itself, which already broadcasts `willPresent`/`didReceive` to every plugin registered via `addApplicationDelegate`, Crisp included), the plugin leaves it in place instead of replacing it — avoiding a fight over the delegate slot with other plugins. Also fixed a fallback path that silently swallowed non-Crisp foreground notifications (`completionHandler([])`) when no previous delegate existed; it now presents them with `.banner`/`.alert` + `.sound` like the system default.
* Fixed an iOS stack-overflow crash on non-Crisp notifications (for example from `firebase_messaging`) when the app is in the foreground or a delivered notification is tapped ([#180](https://github.com/alamin-karno/flutter-crisp-chat/issues/180)) — when Crisp is reached through Flutter's plugin lifecycle fan-out rather than being the direct `UNUserNotificationCenter` delegate, forwarding a non-Crisp notification to `previousNotificationDelegate` could loop back into that same fan-out and call Crisp again, recursing until the stack guard page was hit. `userNotificationCenter(_:willPresent:withCompletionHandler:)` and `userNotificationCenter(_:didReceive:withCompletionHandler:)` now guard the forward call with a one-shot re-entrancy flag so a cycle falls back to presenting/completing the notification instead of recursing.

# 2.7.0

Added
---
* `FlutterCrispChat.onCrispEvent` — a broadcast `Stream<CrispChatEvent>` of native Crisp SDK events: `sessionLoaded`, `chatOpened`, `chatClosed`, `messageSent`, `messageReceived`, and (Android-only) `notificationReceived`. Wraps the native SDK's `EventsCallback` on Android and the `Crisp.Callback` enum on iOS; the native callback is registered on first `.listen()` and unregistered once the last listener cancels. Not supported on Web/desktop.

Changed
---
* Added the `FlutterFramework` SPM dependency to `ios/crisp_chat/Package.swift`, as required by Flutter 3.44+'s Swift Package Manager plugin support for plugins that `import Flutter` directly — silences the "missing a dependency on FlutterFramework" build warning.
* Upgraded Crisp Android SDK from `2.0.20` to `2.0.23` — includes fixes for an occasional crash on chatbox closing, a crash on messages with a `preview` field but no embedded preview, and rejecting `file://` scheme URL opening instead of crashing, plus an additive `onNotificationReceived` method on the native SDK's `EventsCallback`, now exposed as `CrispEventType.notificationReceived` through `FlutterCrispChat.onCrispEvent`.

Fixed
---
* Fixed iOS notification tap never opening the chatbox on cold start or background resume ([#169](https://github.com/alamin-karno/flutter-crisp-chat/issues/169)) — the tap is delivered while the scene is still `foregroundInactive`, which failed `openChat()`'s foreground-active scene guard and silently dropped the tap. `userNotificationCenter(_:didReceive:)` now routes through a new `openChatWhenActive()` helper that defers opening until a one-shot `UIApplication.didBecomeActiveNotification` fires if no active scene exists yet ([#174](https://github.com/alamin-karno/flutter-crisp-chat/pull/174)).

Security
---
* Added a `vite@^6.4.3` npm override in `docsrc/` to fix four Dependabot alerts left open by the previous `vitepress@1.6.4` downgrade — its direct `vite@^5.4.14` dependency resolved to `5.4.21`, which bundles an unpatched `esbuild@0.21.5` and predates fixes only ever backported to the vite `6.4.x` line: [GHSA-fx2h-pf6j-xcff](https://github.com/advisories/GHSA-fx2h-pf6j-xcff) (`server.fs.deny` bypass on Windows, high), [GHSA-v6wh-96g9-6wx3](https://github.com/advisories/GHSA-v6wh-96g9-6wx3) (launch-editor NTLMv2 hash disclosure), [GHSA-4w7w-66w2-5vf9](https://github.com/advisories/GHSA-4w7w-66w2-5vf9) (path traversal in optimized deps `.map` handling), and [GHSA-67mh-4wv8-2f99](https://github.com/advisories/GHSA-67mh-4wv8-2f99) (esbuild dev server request/response read). The override resolves to `vite@6.4.3` + `esbuild@0.25.12`, both within `@vitejs/plugin-vue`'s supported peer range for `vitepress@1.6.4`.
* Downgraded docsrc build toolchain from `vitepress@2.0.0-alpha.17` (vite 7.x) to `vitepress@1.6.4` (vite 5.x) to resolve two high-severity vite 7.x CVEs ([GHSA-859j-r86m-m3mj](https://github.com/advisories/GHSA-859j-r86m-m3mj), [GHSA-pc3c-v4xw-v6vq](https://github.com/advisories/GHSA-pc3c-v4xw-v6vq)) and one low-severity esbuild CVE ([GHSA-67mh-4wv8-2f99](https://github.com/advisories/GHSA-67mh-4wv8-2f99)) — patched versions (vite 7.3.5, esbuild 0.28.1) are not yet published so a toolchain downgrade to unaffected version ranges was applied. Removed the stale `esbuild@^0.28.1` npm override that referenced a non-existent version.

Documentation
---
* **docsrc PageSpeed / SEO / AEO improvements** (Lighthouse mobile performance 69 → 72+ locally, LCP/FCP/CLS all improved, CLS now a perfect 0):
  * Re-encoded `graphics/logo.png` — it was actually a 2048×2048 JPEG mislabeled with a `.png` extension at 89.7 KB, displayed at 24–32px everywhere (favicon, nav logo, OG image). Re-saved as a true 256×256 PNG at 12 KB (~87% smaller).
  * Resized `graphics/firebase-logo.png` (640×640 → 128×128) and `graphics/crisp-logo.png` (200×200 → 96×96) to match their ~32px display size.
  * Resized `graphics/crisp-hero.jpg` (1280×720 → 640×360) to match the home hero's max 320px CSS box at 2x retina.
  * Self-hosted the "Crisp" sponsor logo (`docsrc/docs/.vitepress/theme/data/sponsor.json`) instead of hotlinking `uploads-ssl.webflow.com` — the last remaining third-party image hotlink, previously missed when the other logos were localized.
  * Added explicit `width`/`height` to the nav logo (`themeConfig.logo`), the home hero image (`index.md` frontmatter), the sponsor card image, and the GitHub avatar — closes the Lighthouse `unsized-images` audit and drops CLS to 0.
  * Added `loading="lazy"` to all below-the-fold images (sponsor logos, "Powered By" logos, author avatar), and `fetchpriority="high"` plus a homepage-scoped `<link rel="preload" as="image">` on the hero image (the LCP candidate).
  * Requested a downsized GitHub avatar via `?s=96` instead of the full-resolution image for a 48px display.
  * Converted the Google Fonts `<link rel="stylesheet">` to a preload + `media="print"` swap pattern (with a `<noscript>` fallback) so it no longer render-blocks first paint (~920ms savings) — same fonts, no visual change.
  * Added `FAQPage` JSON-LD structured data to `reference/faq.md` for FAQ rich results and answer-engine extraction.
  * Added `docs/public/llms.txt` (per the emerging `llms.txt` convention) summarizing the project and linking key docs pages for AI answer engines/crawlers.
  * Known, unaddressed Lighthouse findings: `uses-long-cache-ttl` (GitHub Pages doesn't support custom `Cache-Control` headers) and `unused-javascript` on `gtag.js` (inherent to Google Analytics; already the lighter alternative to a full GTM container).

# 2.6.0

Added
---
* `FlutterCrispChat.openHelpdesk()` — opens the Crisp Helpdesk/FAQ search screen directly on **all platforms** (closes [#158](https://github.com/alamin-karno/flutter-crisp-chat/issues/158)). On Android, calls `Crisp.searchHelpdesk()` then starts `ChatActivity`. On iOS, calls `CrispSDK.searchHelpdesk()` then presents `ChatViewController`. On Web and desktop, pushes `$crisp.push(["do", "helpdesk:search"])` via the Crisp Web Chat SDK.
* `FlutterCrispChat.openHelpdeskArticle()` — opens a specific helpdesk article by `locale` and `slug`, with optional `title` and `category`, on **all platforms**. Native SDK on Android/iOS; `$crisp.push(["do", "helpdesk:article:open", [...]])` on Web and desktop.

Fixed
---
* Fixed iOS **Swift Package Manager** build error — added explicit `UIKit` linker setting to `Package.swift` ([#161](https://github.com/alamin-karno/flutter-crisp-chat/pull/161)).
* Fixed spurious `"can not find webview for id: 0"` log noise on desktop — added 500 ms startup delay before polling and suppressed the transient initialisation error.

Security
---
* Fixed high-severity esbuild RCE vulnerability ([GHSA-gv7w-rqvm-qjhr](https://github.com/advisories/GHSA-gv7w-rqvm-qjhr)) in `docsrc/` dev tooling — bumped esbuild override from `^0.25.0` to `^0.28.0` ([#159](https://github.com/alamin-karno/flutter-crisp-chat/pull/159)).
* Fixed low-severity esbuild path traversal vulnerability ([GHSA-g7r4-m6w7-qqqr](https://github.com/advisories/GHSA-g7r4-m6w7-qqqr)) in `docsrc/` dev tooling — bumped esbuild override to `^0.28.1` ([#160](https://github.com/alamin-karno/flutter-crisp-chat/pull/160)).

Documentation
---
* Added blog post covering the multi-platform (`crisp_chat`) Flutter plugin expansion to Web and desktop.
* **docsrc PageSpeed / SEO improvements:**
  * Replaced render-blocking CSS `@import` for Google Fonts with `<link rel="stylesheet">` + `<link rel="preconnect">` in the VitePress `head` config.
  * Added missing `twitter:card`, `twitter:site`, `twitter:title`, `twitter:description`, and `twitter:image` meta tags to all pages.
  * Added `og:image:width`, `og:image:height`, and `og:image:alt` to all pages.
  * Added `<link rel="canonical">` to all pages.
  * Added JSON-LD `SoftwareApplication` structured data to all pages.
  * Replaced Bing-hotlinked Flutter and Firebase logos with locally-hosted copies (`/graphics/flutter-logo.png`, `/graphics/firebase-logo.png`, `/graphics/crisp-logo.png`) to eliminate third-party image dependencies and CLS.
  * Downloaded hero image from external CDN (`digitiz.fr`) to `/graphics/crisp-hero.jpg` — served from same origin.
  * Added explicit `width`/`height` attributes to all "Powered By" images to eliminate Cumulative Layout Shift (CLS).
  * Removed invalid `alt` attribute from `<link rel="icon">` tag.
  * Added `preconnect` hints for Google Fonts, gstatic, and Google Tag Manager.
  * Added [Helpdesk / FAQ](/core_feature/helpdesk) documentation page.

# 2.5.0

Added
---
* **Web** support via the official Crisp Web Chat SDK (`$crisp` / `client.crisp.chat`).
* **Desktop** support for **macOS**, **Windows**, and **Linux** using `desktop_webview_window`, with browser fallback when WebView is unavailable.
* `FlutterCrispChat.markMessagesAsRead()` — REST `PATCH` to clear `unread.visitor` (workaround when the iOS native SDK does not sync read receipts; also usable on Android, Web, and desktop with REST credentials).
* `FlutterCrispChat.isVideoCallsSupported()` — returns whether the **current build** supports Crisp calls (iOS WebRTC variant, or Web/desktop).
* Optional **iOS video/audio calls** (build-time opt-in, not a runtime `CrispConfig` flag):
  * **CocoaPods:** `$CrispChatWebRTC = true` in `ios/Podfile` → links `Crisp/CrispWebRTC` instead of `Crisp/Crisp` (~10 MB larger).
  * **SPM:** `CRISP_CHAT_WEBRTC=true` before `flutter build ios` (or Xcode scheme env var); `Package.swift` selects `CrispWebRTC` automatically.
  * Android native video is not supported yet ([upstream #181](https://github.com/crisp-im/crisp-sdk-android/issues/181)); Web/desktop use the web chatbox when enabled in the Crisp dashboard.
* Documentation: [Supported platforms](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/supported_platforms) guide and platform API matrix; Crisp dashboard **domain lock** guidance ([#148](https://github.com/alamin-karno/flutter-crisp-chat/issues/148)); iOS unread-count limitation and verification ([`docs/unread-count-verification.md`](docs/unread-count-verification.md)).

Changed
---
* Minimum **Dart SDK 3.5.0** and **Flutter 3.24.0** (required by desktop WebView dependency).
* `openChatboxFromNotification` and `setOnNotificationTappedCallback` are no-ops on Web/desktop.
* Example app extended with **linux**, **macos**, and **windows** runners for multi-platform testing.
* GitHub Actions **CI** workflow (analyze + test on Ubuntu).

Breaking
---
* Apps on **Flutter < 3.24** or **Dart < 3.5** must stay on **2.4.8** for mobile-only usage.
* New dependencies: `desktop_webview_window`, `http`, `url_launcher`, `web`.

# 2.4.8

Fixed
---
* Fixed iOS **Swift Package Manager** integration introduced in `2.4.2` that failed during Xcode package resolution with `target 'crisp_chat' in package 'crisp_chat' is outside the package root`.
* Fixed SPM product name to `crisp-chat` (required by Flutter's generated `FlutterGeneratedPluginSwiftPackage`).
* Fixed SPM target to be Swift-only; CocoaPods continues to use a thin Objective-C registration shim in `ios/Classes/`.

Changed
---
* Consolidated iOS Swift sources under `ios/crisp_chat/Sources/crisp_chat/` for both SPM and CocoaPods.
* Restored `ModalPresentationStyle.popover` on iOS (`UIModalPresentationStyle.popover`) with `popoverPresentationController` configuration for iPad.
* Fixed CocoaPods duplicate `FlutterCrispChatPlugin` interface (removed redundant ObjC shim; Swift-only registration).

# 2.4.7

Added
---
* Added `signature` parameter to `User` for Crisp Identity Verification on Android and iOS.

Changed
---
* Upgraded Crisp Android SDK from `2.0.18` to `2.0.20`.
    - Added mobile SDK specific strings localization.
    - [#232](https://github.com/crisp-im/crisp-sdk-android/issues/232) Added missing mobile SDK specific strings localization.

Fixed
---
* Fixed issue: [#132](https://github.com/alamin-karno/flutter-crisp-chat/issues/132) - [iOS] Black screen after closing chat (fullScreen) / tap-through when open (overFullScreen)

# 2.4.6

Added
---
* Added `modalPresentationStyle` parameter to `CrispConfig` for iOS modal presentation style configuration.
* Added `ModalPresentationStyle` enum with options: `fullScreen`, `pageSheet`, `formSheet`, `overFullScreen`, `overCurrentContext`, and `popover`.
* Default modal presentation style is set to `fullScreen` to prevent touch events from passing through to the underlying Flutter UI.

Changed
---
* Upgraded Crisp Android SDK from `2.0.17` to `2.0.18`.
  - Fixed crash on message deserialization when origin is null.

Fixed
---
* Fixed issue where `enableNotifications: false` in `CrispConfig` was being ignored on iOS, causing the Crisp SDK to still prompt for push notification permissions after sending the first message.

# 2.4.5

Changed
---
* Upgraded Crisp Android SDK from `2.0.16` to `2.0.17`.
  - Scroll to last message after visitor sent it
  - Updated smileys sorting according to Web dashboard

# 2.4.4

Added
---
* Added `CrispChatNotificationService` — a custom `FirebaseMessagingService` that handles Crisp push notifications without auto-opening `ChatActivity`. This allows the app to open first, then programmatically open the chatbox.
* Added `openChatboxFromNotification()` method to open the Crisp chatbox from a notification intent after the app has launched.
* Added `setOnNotificationTappedCallback()` method to listen for Crisp notification taps while the app is in the background.
* Added `firebase-messaging` as a `compileOnly` dependency in the SDK's `build.gradle`.

Changed
---
* Upgraded Crisp iOS SDK from `2.12.0` to `2.13.0`.
* Updated `FlutterCrispChatPlugin.java` to implement `NewIntentListener` for detecting notification taps via `onNewIntent`.
* Updated `README.md` with two notification handling approaches: **Option A** (auto-open ChatActivity) and **Option B** (open app first, then chatbox).

Fixed
---
* Fixed issue: [#79](https://github.com/alamin-karno/flutter-crisp-chat/issues/79) — Crisp notification tap directly opens ChatActivity instead of the app's main screen on terminated state.

# 2.4.3

Fixed
---
* Fixed issue: [#98](https://github.com/alamin-karno/flutter-crisp-chat/issues/98) Bug: `getSessionIdentifier()` returns null after closing chat, preventing unread message checks

# 2.4.2

Added
---
* Added `getUnreadMessageCount` to get unread message count,
* Added **Swift Package Manager** support for iOS,
* Add validation for websiteID on iOS & Android SDK Level.

Changed
---
* Upgraded Crisp Android SDK from `2.0.13` to `2.0.16`.
* Increased `minSdkVersion` from `21` to `23`.
* Updated `compileSdkVersion` from `35` to `36`.
* Upgraded Android Gradle Plugin (AGP) from `8.6.1` to `8.9.1`.
* Upgraded Gradle from `8.7` to `8.11.1`,
* Upgraded Crisp iOS SDK from `2.8.2` to `2.12.0`,
* Increased the minimum iOS deployment target from `9.0` to `13.0`,

# 2.4.1

Added
---
* Package now supported Google Play's 16KB page size requirement.

Changed
---
* Update Crisp Android SDK `2.0.12` to `2.0.13`.
* Update AGP from `8.6` to `8.7`.
* Update Project Level Gradle from `8.4.1` to `8.6.1`.
* Update `example` project Kotlin from `1.7.10` to `2.1.0`.


# 2.4.0

Added
---
* Added new function `pushSessionEvent` to sends a custom event to the Crisp session with `name` and `color`.

Changed
---
* Increased the minimum Dart SDK constraint from `>=2.12.0` to `>=2.15.0`.


# 2.3.0

Added
---
* New section in `README.md` detailing supported native Crisp SDK versions (Android & iOS).
* More comprehensive usage examples in `README.md`, including detailed `CrispConfig` setup with `User` and `Company` objects.
* `{@category}` tags to Dart classes and methods for improved generated documentation.
* Guidance on using `resetCrispChatSession` and clearer calling sequences in `README.md`.
* Notes on testing push notifications for both iOS and Android in `README.md`.

Changed
---
* Update Crisp Android SDK `2.0.11` to `2.0.12`.
* Upgraded `compileSdk` and `targetSdk` to `35`
* Upgraded `AGP` from `8.1.1` to `8.3.0`
* Upgraded `Gradle` from `8.2` to `8.4`
* Enhanced error handling for `getSessionIdentifier` method.
* Improved documentation for public APIs for better clarity.
* Switched from generic `Exception` to `ArgumentError` for input validation with more descriptive messages.

Fixed
---
* Fixed issue: [#46](https://github.com/alamin-karno/flutter-crisp-chat/issues/57) Android mailto: links in chat fail to launch email app on some devices (e.g., Xiaomi/Redmi, Android 12+)

# 2.2.5
* Update Crisp Android SDK `2.0.10` to `2.0.11`.
* Fixed Issue: [#45](https://github.com/alamin-karno/flutter-crisp-chat/issues/45): Push view up when the keyboard is open
* Added remote notification registration in application launch for iOS

# 2.2.4
* Update Crisp Android SDK `2.0.9` to `2.0.10`.
* Update Crisp iOS SDK `2.8.1` to `2.8.2`.
* Added `enableNotifications` flag in `CrispConfig` to enable/disable notifications for your site.
* Improved JSON parsing and type safety for `enableNotifications` flag.
* Added `setSessionSegments` method to support clients using multiple segments with Crisp.

# 2.2.3
* Update Crisp Android SDK `2.0.8` to `2.0.9`.

# 2.2.2
* Added Specific Crisp iOS SDK `2.8.1`
* Fixed issue: [33](https://github.com/alamin-karno/flutter-crisp-chat/issues/33)
* Fixed issue: [36](https://github.com/alamin-karno/flutter-crisp-chat/issues/36)

# 2.2.1
* Added proper documentation for notification sending via crisp
* Fixed issue: [27](https://github.com/alamin-karno/flutter-crisp-chat/issues/27)
* Fixed issue: [28](https://github.com/alamin-karno/flutter-crisp-chat/issues/28)
* Fixed issue: [29](https://github.com/alamin-karno/flutter-crisp-chat/issues/29)

# 2.2.0
* Update Crisp Android SDK `2.0.5` to `2.0.8`.
* Added notification support for sending missing messages
* Fixed [#10](https://github.com/alamin-karno/flutter-crisp-chat/issues/10): Message Callback
* Fixed [#17](https://github.com/alamin-karno/flutter-crisp-chat/issues/17): Event: onMessageReceived
* Fixed [#24](https://github.com/alamin-karno/flutter-crisp-chat/issues/24): Add Notifications Support

# 2.1.0
* Fixed [#21](https://github.com/alamin-karno/flutter-crisp-chat/issues/21) unable to open chat for specific domain email
* `isEmail` and `isUrl` helper validation fixed

# 2.0.9
* Fixed [#20](https://github.com/alamin-karno/flutter-crisp-chat/issues/20) reset chat session exception on iOS
* Added `getSessionIdentifier` feature for iOS

# 2.0.8
* Update Crisp Android SDK `2.0.4` to `2.0.5`. This fixed camera app crash on take photo feature on some devices
* Update Crisp Android (Example App) Kotlin Version `1.6.10` to `1.7.10`

# 2.0.7
* Added `getSessionIdentifier` to get current session for Android only
* Update Crisp Android SDK `2.0.3beta4` to `2.0.4`
* Public APIs which were previously under `im.crisp.client` package are now under `im.crisp.client.external` one!

# 2.0.6
* Update Crisp Android SDK `2.0.1beta2` to `2.0.3beta4`

# 2.0.5
* Updated iOS deprecated code
* Change iOS code style
* Updated AGP from `7.4.0` to `8.6.0`

# 2.0.4
* Added setSessionString method to set string session data.
* Added setSessionInt method to set integer session data.

Testing
---
* `FlutterCrispChat.setSessionString(key: "a_string", value: "string_value");`
* `FlutterCrispChat.setSessionInt(key: "a_number", value: 12345);`

# 2.0.3

Features
---
* added video game suggestion,
* added new messages alerts,
* sync compose, text area, operator, scroll and wait for reply and new messages alerts.
---
Fixes
---
* added missing markdown proguard rules,
* fixed [#173](https://github.com/crisp-im/crisp-sdk-android/issues/173) crash by asking permission on photo taking when embedding app declares using `CAMERA` permission. If user denied it, next taps on this feature will show a dialog redirecting him to the app permission setting,
* fixed attachment & loading dialogs color in Dark mode,
* fixed `SecurityException` crashes on link touch due to `file://` schemes or 3rd-party installed app set to open any link but not exporting their Activity... So added a `Unable to open link. Check if an app, except you browser, is configured to open any link.` toast when touched link cannot be opened,
* fixed a markdown parsing crash when it is too complex (huge regex or obfuscated code) by simply not applying markdown on this case,
* fixed smileys horizontal alignment and ripple color on touch,
* fixed picker choice icon alpha when disabled,
* fixed a random audio player crash when released.
---
Dependencies
---
* updated AGP from `8.2.2` to `8.3.2`.
---
Installation update
---
If your app declares a `FileProvider` in its `AndroidManifest.xml`, please add Crisp authority and path to it as follows as it is required for the file upload feature.

`AndroidManifest.xml`

```html
<provider android:name="androidx.core.content.FileProvider"
android:authorities="${applicationId}.fileprovider;${applicationId}.im.crisp.client.uploadfileprovider"
android:exported="false"
android:grantUriPermissions="true"
tools:replace="android:authorities">
<meta-data android:name="android.support.FILE_PROVIDER_PATHS"
android:resource="@xml/file_paths"
tools:replace="android:resource" />
</provider>
```

`res/xml/file_paths.xml`

```html
<files-path name="crisp_sdk_attachments" path="im.crisp.client/attachments/" />
```


# 2.0.2
* Added option to reset chat session

# 2.0.1
* Added session segment support

# 2.0.0

* updated UI to match Web & iOS chat boxes
* added Take photo support
* added Customization plugin support
* added HelpDesk public APIs:
  * `searchHelpDesk`: opens help desk search, right away if the ChatActivity is running, on its next start otherwise,
  * `openHelpDeskArticle`: views helpDesk article, right away if the ChatActivity is running, on its next start otherwise.
* added carousel message type support,
* added chat box behaviors:
  * Operator privacy mode,
  * MagicType,
  * HelpDesk link & HelpDesk-only mode.
* added Request feedback,
* added `action` support for `picker` message type,
* added required support for `field` & `picker` message types,
* added De-branding plugin support,
* added hardware keyboard support (`SHIFT+ENTER` inserts a line break, `ENTER` only sends the message),
* updated localization.
* using `flexbox` now for `picker` message type, should fix choices list cutted,
* using `glide` now for media loading, should fix NPE on GIF parsing,
* synced `user` messages sent outside of the Android chat box,
* fixed possibility to send empty messages/field value & trim sent ones,
* fixed `read` status message duplicates,
* fixed various not yet reported bugs & crashes.
* [#4](https://github.com/alamin-karno/flutter-crisp-chat/issues/4): Build fail due to crisp_chat dependency fixed.

# 1.0.0

* Added Markdown support
* updated android crisp version `1.0.16` to `1.0.18`
* Updated dependencies:
  * `com.google.android.material:material` from `1.9.0` to `1.10.0`,
  * `androidx.media3:media3-exoplayer` from `1.1.0` to `1.1.1`.
* Update Android SDK from API `33` to `34`.


# 0.0.4

* added user configuration option in crisp configuration
* updated android crisp version `1.0.14` to `1.0.16`

# 0.0.3

* change readme file

# 0.0.2

* crisp chat add for native platform
* fixed iOS dependency not found
* fixed calling method 


# 0.0.1

* crisp Chat add for native platform


