# 2.0.9
* Fixed [#20] reset chat session exception on iOS
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
* added missing markwon proguard rules,
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


