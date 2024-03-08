## 2.0.0

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
* #4: Build fail due to crisp_chat dependency fixed.

## 1.0.0

* Added Markdown support
* updated android crisp version `1.0.16` to `1.0.18`
* Updated dependencies:
  * `com.google.android.material:material` from `1.9.0` to `1.10.0`,
  * `androidx.media3:media3-exoplayer` from `1.1.0` to `1.1.1`.
* Update Android SDK from API `33` to `34`.


## 0.0.4

* added user configuration option in crisp configuration
* updated android crisp version `1.0.14` to `1.0.16`

## 0.0.3

* change readme file

## 0.0.2

* crisp chat add for native platform
* fixed iOS dependency not found
* fixed calling method 


## 0.0.1

* crisp Chat add for native platform


