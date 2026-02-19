
# [Unreleased]

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


