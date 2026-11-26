import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'src/config.dart';
import 'src/crisp_event.dart';
import 'src/crisp_message_content.dart';
import 'src/flutter_crisp_chat_platform_interface.dart';
import 'src/helper.dart';
import 'src/platform_register.dart';

export 'src/config.dart';
export 'src/crisp_event.dart';
export 'src/crisp_message_content.dart';

/// [FlutterCrispChat] to call the native platform method.
class FlutterCrispChat {
  // Ensures Web/desktop platform implementations are registered before use.
  // ignore: unused_field
  static final bool _initialized = () {
    registerCrispChatPlatform();
    return true;
  }();

  /// The cached session identifier.
  static String? _sessionIdentifier;

  /// Incremented by [resetCrispChatSession], so a session identifier cached
  /// in the background by [openCrispChat] is dropped if a reset happened
  /// meanwhile.
  static int _sessionGeneration = 0;

  /// Whether [CrispConfig.localMessages] were already shown since app start
  /// or the last [resetCrispChatSession].
  static bool _localMessagesShown = false;

  /// Opens the Crisp chat interface.
  ///
  /// This method initializes and displays the Crisp chat view using the
  /// provided [config].
  ///
  /// {@category General}
  /// @param config The configuration object for Crisp chat.
  /// @return A [Future] that completes when the chat is opened.
  /// @throws Exception if the user email in [config] is invalid.
  /// @throws Exception if the company URL in [config] is invalid.
  /// @throws Exception if a message in [CrispConfig.localMessages] is invalid.
  static Future<void> openCrispChat({required CrispConfig config}) async {
    // Validate email if provided. This ensures that any email passed to the
    // native Crisp SDK is in a recognizable format.
    final email = config.user?.email;
    if (email != null && !email.isEmail) {
      throw ArgumentError.value(
        email,
        'config.user.email',
        'Invalid email format provided.',
      );
    }

    // Validate company URL if provided. This ensures that any URL passed for
    // the company is a well-formed absolute URL.
    final url = config.user?.company?.url;
    if (url != null && !url.isUrl) {
      throw ArgumentError.value(
        url,
        'config.user.company.url',
        'Invalid company URL format provided.',
      );
    }

    final localMessages = config.localMessages ?? const [];
    localMessages.forEach(_validateMessageContent);

    // Start listening before opening, so the session's `sessionLoaded` event
    // can't be missed.
    final sessionLoaded = _nextSessionLoadedId();

    // Call the platform-specific method to open Crisp chat
    try {
      await FlutterCrispChatPlatform.instance.openCrispChat(config: config);
    } catch (_) {
      sessionLoaded.cancel();
      rethrow;
    }

    // Show the configured local messages once, so they don't pile up in the
    // chatbox every time it is reopened.
    if (localMessages.isNotEmpty && !_localMessagesShown) {
      _localMessagesShown = true;
      try {
        for (final message in localMessages) {
          await FlutterCrispChatPlatform.instance.showMessage(content: message);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error showing local messages: $e");
        }
      }
    }

    // Cache the session identifier in the background, so callers don't wait
    // for the session to load.
    unawaited(_cacheSessionIdentifier(sessionLoaded, _sessionGeneration));
  }

  /// How long [openCrispChat] waits for a `sessionLoaded` event before
  /// querying the session identifier instead.
  static const Duration _sessionLoadedTimeout = Duration(seconds: 10);

  /// How long [openCrispChat] waits before querying the session identifier
  /// on platforms that emit no [onCrispEvent] events (Web, desktop).
  static const Duration _noEventsQueryDelay = Duration(seconds: 3);

  /// Listens for the next `sessionLoaded` event and completes with its
  /// session identifier, or with `null` once [_sessionLoadedTimeout] passes.
  ///
  /// On platforms without events (Web, desktop) it completes with `null`
  /// after [_noEventsQueryDelay], so the identifier is queried once the
  /// widget had time to load, as before.
  static _PendingSessionId _nextSessionLoadedId() {
    final pending = _PendingSessionId();
    Stream<CrispChatEvent> events;
    try {
      events = FlutterCrispChatPlatform.instance.onCrispEvent;
    } catch (_) {
      pending.completeAfter(_noEventsQueryDelay);
      return pending;
    }
    pending.subscription = events.listen(
      (event) {
        final sessionId = event.sessionId;
        if (event.type == CrispEventType.sessionLoaded && sessionId != null) {
          pending.complete(sessionId);
        }
      },
      onError: (_) {},
      // A stream that ends without an event (Web, desktop) has no events.
      onDone: () => pending.completeAfter(_noEventsQueryDelay),
    );
    pending.completeAfter(_sessionLoadedTimeout);
    return pending;
  }

  /// Caches the identifier from [sessionLoaded], or queries it from the
  /// platform when no `sessionLoaded` event arrived in time.
  static Future<void> _cacheSessionIdentifier(
    _PendingSessionId sessionLoaded,
    int generation,
  ) async {
    var sessionId = await sessionLoaded.future;
    if (sessionId == null) {
      try {
        sessionId =
            await FlutterCrispChatPlatform.instance.getSessionIdentifier();
      } catch (e) {
        if (kDebugMode) {
          print("Error caching session identifier: $e");
        }
      }
    }
    // Drop it if the session was reset while waiting.
    if (sessionId != null && generation == _sessionGeneration) {
      _sessionIdentifier = sessionId;
    }
  }

  /// Configures the Crisp SDK with your [websiteId] without opening the chat.
  ///
  /// Call it before [setTokenId] and the user setters when the user logs in,
  /// so they work before the chat is first opened:
  ///
  /// ```dart
  /// // Login
  /// await FlutterCrispChat.configure(websiteId: websiteId);
  /// await FlutterCrispChat.setTokenId(user.id);
  /// await FlutterCrispChat.resetCrispChatSession();
  ///
  /// // Logout
  /// await FlutterCrispChat.setTokenId(null);
  /// await FlutterCrispChat.resetCrispChatSession();
  /// ```
  ///
  /// Wraps `Crisp.configure` (Android) and `CrispSDK.configure` (iOS). Does
  /// nothing on Web and desktop, which take the website ID from
  /// [openCrispChat].
  ///
  /// {@category General}
  /// @throws ArgumentError if [websiteId] is empty.
  static Future<void> configure({required String websiteId}) async {
    final id = websiteId.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
          websiteId, 'websiteId', 'Website ID must not be empty.');
    }
    await FlutterCrispChatPlatform.instance.configure(websiteId: id);
  }

  /// Sets the session continuity token, which ties the chat session to your
  /// user so their conversation comes back on other devices and after a
  /// logout. Pass `null` (or an empty string) to clear it when the user
  /// logs out.
  ///
  /// A new or cleared token only takes effect after
  /// [resetCrispChatSession], so call that right after this method. See
  /// [configure] for the login and logout sequence Crisp recommends.
  ///
  /// The token set here is kept until it is changed; a
  /// [CrispConfig.tokenId] passed to [openCrispChat] still takes precedence.
  ///
  /// Call it while the chat is closed: the Android SDK ignores a new token
  /// while the chat is connected.
  ///
  /// Wraps `Crisp.setTokenID` (Android), `CrispSDK.setTokenID` (iOS) and
  /// `CRISP_TOKEN_ID` (Web/desktop).
  ///
  /// {@category General}
  static Future<void> setTokenId(String? tokenId) async {
    final token = (tokenId == null || tokenId.trim().isEmpty) ? null : tokenId;
    await FlutterCrispChatPlatform.instance.setTokenId(tokenId: token);
  }

  /// Sets the user's [email] without opening the chat, with an optional
  /// identity verification [signature] (HMAC-SHA256 of the email).
  ///
  /// Call it after [resetCrispChatSession], which clears the user on iOS.
  /// On Web and desktop the value is applied now if the chat is loaded,
  /// otherwise the next time [openCrispChat] runs; a [CrispConfig.user]
  /// email passed to it takes precedence.
  ///
  /// {@category General}
  /// @throws ArgumentError if [email] is not a valid email address.
  static Future<void> setUserEmail(String email, {String? signature}) async {
    if (!email.isEmail) {
      throw ArgumentError.value(
          email, 'email', 'Invalid email format provided.');
    }
    await FlutterCrispChatPlatform.instance.setUserEmail(
      email: email,
      signature: (signature == null || signature.isEmpty) ? null : signature,
    );
  }

  /// Sets the user's [nickname] without opening the chat.
  ///
  /// See [setUserEmail] for when the value is applied.
  ///
  /// {@category General}
  /// @throws ArgumentError if [nickname] is empty.
  static Future<void> setUserNickname(String nickname) async {
    if (nickname.trim().isEmpty) {
      throw ArgumentError.value(
          nickname, 'nickname', 'Nickname must not be empty.');
    }
    await FlutterCrispChatPlatform.instance.setUserNickname(nickname: nickname);
  }

  /// Sets the user's [phone] number without opening the chat.
  ///
  /// See [setUserEmail] for when the value is applied.
  ///
  /// {@category General}
  /// @throws ArgumentError if [phone] is empty.
  static Future<void> setUserPhone(String phone) async {
    if (phone.trim().isEmpty) {
      throw ArgumentError.value(phone, 'phone', 'Phone must not be empty.');
    }
    await FlutterCrispChatPlatform.instance.setUserPhone(phone: phone);
  }

  /// Sets the URL of the user's [avatar] image without opening the chat.
  ///
  /// See [setUserEmail] for when the value is applied.
  ///
  /// {@category General}
  /// @throws ArgumentError if [avatar] is not a valid URL.
  static Future<void> setUserAvatar(String avatar) async {
    if (!avatar.isUrl) {
      throw ArgumentError.value(
          avatar, 'avatar', 'Invalid avatar URL format provided.');
    }
    await FlutterCrispChatPlatform.instance.setUserAvatar(avatar: avatar);
  }

  /// Resets the current Crisp chat session.
  ///
  /// This method clears any ongoing chat session data, effectively starting fresh.
  /// It's useful for logging out a user or clearing user-specific data.
  ///
  /// {@category General}
  /// @return A [Future] that completes when the session has been reset.
  static Future<void> resetCrispChatSession() async {
    await FlutterCrispChatPlatform.instance.resetCrispChatSession();
    _sessionGeneration++;
    _sessionIdentifier = null;
    _localMessagesShown = false;
  }

  /// Sets a string value in the current session data.
  ///
  /// This data is associated with the current or next user session in Crisp.
  /// It can be used to store custom attributes or information about the user.
  ///
  /// {@category General}
  /// @param key The key for the data point. Must not be empty.
  /// @param value The string value to store. Must not be empty.
  /// @throws Exception if [key] or [value] is empty.
  static void setSessionString({required String key, required String value}) {
    // Ensure non-empty key and value
    if (key.isEmpty || value.isEmpty) {
      throw ArgumentError('Key and value for session data must not be empty.');
    }
    FlutterCrispChatPlatform.instance.setSessionString(key: key, value: value);
  }

  /// Sets an integer value in the current session data.
  ///
  /// This data is associated with the current or next user session in Crisp.
  /// It can be used to store custom attributes or information about the user.
  ///
  /// {@category General}
  /// @param key The key for the data point. Must not be empty.
  /// @param value The integer value to store.
  /// @throws Exception if [key] is empty.
  static void setSessionInt({required String key, required int value}) {
    // Ensure non-empty key
    if (key.isEmpty) {
      throw ArgumentError('Key for session data must not be empty.');
    }
    FlutterCrispChatPlatform.instance.setSessionInt(key: key, value: value);
  }

  /// Retrieves the current Crisp session identifier.
  ///
  /// An active session typically means a chat has been initiated or user data
  /// has been set. The session identifier can be used for tracking or
  /// debugging purposes.
  ///
  /// {@category General}
  /// @return A [Future] that completes with a [String] containing the session
  /// identifier, or `null` if no active session is found or if an error occurs.
  static Future<String?> getSessionIdentifier() async {
    try {
      // The platform interface is expected to return null if the session ID
      // is not available or if an error like "NO_SESSION" occurs.
      // MethodChannelFlutterCrispChat catches PlatformException and returns null.
      final sessionId =
          await FlutterCrispChatPlatform.instance.getSessionIdentifier();
      if (sessionId != null) {
        if (sessionId != _sessionIdentifier) {
          _sessionIdentifier = sessionId;
        }
        return sessionId;
      }
    } catch (e) {
      // This catch block handles any other unexpected errors during the platform call.
      if (kDebugMode) {
        print("Error retrieving session identifier: $e");
      }
    }
    return _sessionIdentifier;
  }

  /// Returns whether the current session is ongoing, meaning messages have
  /// been sent or received in it.
  ///
  /// Useful to tell a visitor who already talked to you from a new one, e.g.
  /// to label a "Continue conversation" button. Returns `null` when it can't
  /// be told:
  /// - on Android, whose Crisp SDK 2.x has no such check;
  /// - before the session has loaded (open the chat first, or wait for
  ///   [CrispEventType.sessionLoaded] on [onCrispEvent]);
  /// - on desktop when the system browser fallback is used.
  ///
  /// Wraps `CrispSDK.session.isOngoing` (iOS, Crisp iOS SDK 3.1.1+) and
  /// `$crisp.is("session:ongoing")` (Web/desktop).
  ///
  /// {@category General}
  static Future<bool?> isSessionOngoing() async {
    try {
      return await FlutterCrispChatPlatform.instance.isSessionOngoing();
    } catch (e) {
      if (kDebugMode) {
        print("Error checking whether the session is ongoing: $e");
      }
      return null;
    }
  }

  /// Sets user segments in the current session.
  ///
  /// Segments are used to categorize users (e.g., "premium", "trial").
  /// This helps in targeting and analyzing user behavior within Crisp.
  ///
  /// {@category General}
  /// @param segments A list of [String] representing the segments to set.
  /// @param overwrite If `true`, existing segments will be replaced.
  ///                  Otherwise, new segments are appended. Defaults to `false`.
  static void setSessionSegments({
    required List<String> segments,
    bool overwrite = false,
  }) {
    FlutterCrispChatPlatform.instance.setSessionSegments(
      segments: segments,
      overwrite: overwrite,
    );
  }

  /// [pushSessionEvent] sends a custom event to the Crisp session.
  /// This can be used to log specific actions or milestones
  /// within the chat session, such as user interactions or significant
  /// events that occur during the chat.
  ///
  /// {@category Session Events}
  /// @param name The name of the event to log.
  /// @param color The color associated with the event, used for visual
  ///              differentiation in the Crisp dashboard. Defaults to `SessionEventColor.blue`.
  static Future<void> pushSessionEvent({
    required String name,
    SessionEventColor color = SessionEventColor.blue,
  }) {
    return FlutterCrispChatPlatform.instance.pushSessionEvent(
      name: name,
      color: color,
    );
  }

  /// [runBotScenario] runs a Crisp Bot scenario identified by [scenarioId],
  /// as configured in the Bot plugin on your Crisp website.
  ///
  /// {@category Session Events}
  /// @param scenarioId The identifier of the Bot scenario to run.
  /// @return A [Future] that completes when the scenario has been triggered.
  static Future<void> runBotScenario({required String scenarioId}) async {
    if (scenarioId.trim().isEmpty) {
      throw ArgumentError.value(
        scenarioId,
        'scenarioId',
        'Scenario ID must not be empty.',
      );
    }
    await FlutterCrispChatPlatform.instance.runBotScenario(
      scenarioId: scenarioId,
    );
  }

  /// [showMessage] shows [content] as an operator message in the local
  /// chatbox. The message is never sent to your Crisp inbox, so operators
  /// don't see it.
  ///
  /// Call it after [openCrispChat]. To show messages automatically when the
  /// chat first opens, use [CrispConfig.localMessages] instead.
  ///
  /// {@category Local Messages}
  /// @param content The message to show (e.g. [CrispTextContent]).
  /// @return A [Future] that completes when the message has been shown.
  /// @throws Exception if [content] is invalid (e.g. empty text).
  static Future<void> showMessage(CrispMessageContent content) async {
    _validateMessageContent(content);
    await FlutterCrispChatPlatform.instance.showMessage(content: content);
  }

  static void _validateMessageContent(CrispMessageContent content) {
    switch (content) {
      case CrispTextContent(:final text) when text.trim().isEmpty:
        throw ArgumentError.value(
          text,
          'content.text',
          'Message text must not be empty.',
        );
      case CrispPickerContent(:final choices) when choices.isEmpty:
        throw ArgumentError.value(
          choices,
          'content.choices',
          'Picker choices must not be empty.',
        );
      case CrispCarouselContent(:final targets) when targets.isEmpty:
        throw ArgumentError.value(
          targets,
          'content.targets',
          'Carousel targets must not be empty.',
        );
      default:
        break;
    }
  }

  static Map<String, String> _crispApiHeaders({
    required String identifier,
    required String key,
    bool jsonBody = false,
  }) {
    return {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$identifier:$key'))}',
      'X-Crisp-Tier': 'plugin',
      if (jsonBody) 'Content-Type': 'application/json',
    };
  }

  /// Fetches the unread message count for the current visitor session.
  ///
  /// This method makes a REST API call to Crisp to get conversation details,
  /// including the number of unread messages for the visitor.
  ///
  /// On iOS, the native Crisp SDK may not send read receipts to the server
  /// when the visitor reads messages. In that case, [unread.visitor](https://docs.crisp.chat/references/rest-api/v1/#get-a-conversation)
  /// stays non-zero until you call [markMessagesAsRead].
  ///
  /// {@category General}
  /// @param websiteId Your Crisp Website ID.
  /// @param identifier Your Crisp REST API Identifier.
  /// @param key Your Crisp REST API Key.
  /// @return A [Future] that completes with an [int] representing the unread
  ///         message count, or `null` if the session is not found or an
  ///         error occurs.
  static Future<int?> getUnreadMessageCount({
    required String websiteId,
    required String identifier,
    required String key,
  }) async {
    final sessionId = await getSessionIdentifier();
    if (sessionId == null) {
      log(
        'No active session, so no unread messages.',
        name: 'FlutterCrispChat',
      );
      return null;
    }

    final uri = Uri.parse(
      'https://api.crisp.chat/v1/website/$websiteId/conversation/$sessionId',
    );

    try {
      final response = await http.get(
        uri,
        headers: _crispApiHeaders(identifier: identifier, key: key),
      );

      if (kDebugMode) {
        log('URL: $uri - STATUS: ${response.statusCode}', name: 'API');
        log('BODY: ${response.body}', name: 'API');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final unreadCount = data['data']?['unread']?['visitor'] as int?;
        return unreadCount ?? 0;
      } else {
        log(
          'Failed to get unread count. Status: ${response.statusCode}, Body: ${response.body}',
          name: 'FlutterCrispChat',
        );

        return null;
      }
    } catch (e, stackTrace) {
      log(
        'An error occurred while fetching unread message count: $e',
        stackTrace: stackTrace,
        name: 'FlutterCrispChat',
      );

      return null;
    }
  }

  /// Opens the Crisp helpdesk search interface.
  ///
  /// {@category Helpdesk}
  /// @param websiteId The Crisp website ID.
  /// @return A [Future] that completes when the helpdesk is opened.
  static Future<void> openHelpdesk({required String websiteId}) async {
    if (websiteId.trim().isEmpty) {
      throw ArgumentError.value(
        websiteId,
        'websiteId',
        'Website ID must not be empty.',
      );
    }
    await FlutterCrispChatPlatform.instance.openHelpdesk(
      websiteId: websiteId,
    );
  }

  /// Opens a specific helpdesk article.
  ///
  /// {@category Helpdesk}
  /// @param websiteId The Crisp website ID.
  /// @param locale The locale of the article (e.g. `'en'`, `'fr'`).
  /// @param slug The slug (ID) of the article.
  /// @param title (Optional) The title of the article.
  /// @param category (Optional) The category of the article.
  /// @return A [Future] that completes when the article is opened.
  static Future<void> openHelpdeskArticle({
    required String websiteId,
    required String locale,
    required String slug,
    String? title,
    String? category,
  }) async {
    if (websiteId.trim().isEmpty) {
      throw ArgumentError.value(
        websiteId,
        'websiteId',
        'Website ID must not be empty.',
      );
    }
    if (locale.trim().isEmpty) {
      throw ArgumentError.value(
        locale,
        'locale',
        'Locale must not be empty.',
      );
    }
    if (slug.trim().isEmpty) {
      throw ArgumentError.value(slug, 'slug', 'Slug must not be empty.');
    }
    await FlutterCrispChatPlatform.instance.openHelpdeskArticle(
      websiteId: websiteId,
      locale: locale,
      slug: slug,
      title: title,
      category: category,
    );
  }

  /// Marks all operator messages as read for the current visitor session.
  ///
  /// {@category General}
  /// @param websiteId Your Crisp Website ID.
  /// @param identifier Your Crisp REST API Identifier.
  /// @param key Your Crisp REST API Key.
  /// @return `true` if the request was accepted (HTTP 202), `false` on API
  ///         error, or `null` if no active session exists.
  static Future<bool?> markMessagesAsRead({
    required String websiteId,
    required String identifier,
    required String key,
  }) async {
    final sessionId = await getSessionIdentifier();
    if (sessionId == null) {
      log(
        'No active session, cannot mark messages as read.',
        name: 'FlutterCrispChat',
      );
      return null;
    }

    final uri = Uri.parse(
      'https://api.crisp.chat/v1/website/$websiteId/conversation/$sessionId/read',
    );

    try {
      final response = await http.patch(
        uri,
        headers: _crispApiHeaders(
          identifier: identifier,
          key: key,
          jsonBody: true,
        ),
        body: jsonEncode({
          'from': 'operator',
          'origin': 'chat',
        }),
      );

      if (kDebugMode) {
        log('URL: $uri - STATUS: ${response.statusCode}', name: 'API');
        log('BODY: ${response.body}', name: 'API');
      }

      if (response.statusCode == 202) {
        return true;
      }

      log(
        'Failed to mark messages as read. Status: ${response.statusCode}, Body: ${response.body}',
        name: 'FlutterCrispChat',
      );
      return false;
    } catch (e, stackTrace) {
      log(
        'An error occurred while marking messages as read: $e',
        stackTrace: stackTrace,
        name: 'FlutterCrispChat',
      );
      return false;
    }
  }

  /// Attempts to open the Crisp chatbox from a notification intent.
  ///
  /// When using `CrispChatNotificationService` (which handles notifications
  /// without auto-opening the chatbox), call this method to open the chatbox
  /// after the app has launched or resumed.
  ///
  /// Returns `true` if the chatbox was opened successfully (i.e., the app
  /// was launched from a Crisp notification), `false` otherwise.
  ///
  /// {@category General}
  /// @return A [Future] that completes with a [bool] indicating success.
  static Future<bool> openChatboxFromNotification() async {
    return await FlutterCrispChatPlatform.instance
        .openChatboxFromNotification();
  }

  /// Sets a callback that will be invoked when a Crisp notification is tapped
  /// while the app is already running (background → foreground).
  ///
  /// This is useful for detecting notification taps when the app is in the
  /// background (not terminated). After receiving this callback, you can
  /// call [openChatboxFromNotification] to open the chatbox.
  ///
  /// {@category General}
  /// @param callback The callback to invoke, or `null` to remove it.
  static void setOnNotificationTappedCallback(VoidCallback? callback) {
    FlutterCrispChatPlatform.instance.setOnNotificationTappedCallback(callback);
  }

  /// Returns whether Crisp video/audio calls are supported on this build.
  ///
  /// - **iOS:** always `true` — Crisp iOS SDK 3.x includes calls in every build.
  ///   Requires `NSCameraUsageDescription` and `NSMicrophoneUsageDescription`
  ///   in `Info.plist`.
  /// - **Android:** always `false` until Crisp ships native video support.
  /// - **Web / desktop:** `true` (calls are handled by the web chatbox when enabled
  ///   in your Crisp dashboard).
  ///
  /// This is a capability check, not a runtime toggle. See
  /// [Platform setup — Enable video calls (iOS)](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/platform_setup.html#enable-video-calls-ios-only).
  ///
  /// {@category General}
  static Future<bool> isVideoCallsSupported() {
    return FlutterCrispChatPlatform.instance.isVideoCallsSupported();
  }

  /// A broadcast stream of native Crisp SDK events: session loaded, chat
  /// opened/closed, and message sent/received.
  ///
  /// The native event callback is registered on the first `.listen()` call
  /// and unregistered once the last listener cancels, so it's safe to listen
  /// and cancel freely without leaking a native-side registration.
  ///
  /// Not supported on Web/desktop — the stream never emits there.
  ///
  /// [CrispEventType.notificationReceived] is Android-only; the iOS Crisp SDK
  /// has no matching callback, so iOS never emits it.
  ///
  /// {@category Events}
  static Stream<CrispChatEvent> get onCrispEvent =>
      FlutterCrispChatPlatform.instance.onCrispEvent;
}

/// Entry point for the macOS, Windows, and Linux Flutter plugin registrant.
///
/// The generated `dart_plugin_registrant` imports `package:crisp_chat/crisp_chat.dart`
/// and calls [registerWith] on desktop targets.
class CrispChatDesktopPlugin {
  CrispChatDesktopPlugin._();

  /// Registers the desktop [FlutterCrispChatPlatform] implementation.
  static void registerWith() {
    registerCrispChatPlatform();
  }
}

/// A session identifier [FlutterCrispChat.openCrispChat] is waiting for.
///
/// Completes once, with the identifier or `null`, and then cancels its event
/// subscription and timer, so the native event listener doesn't stay
/// registered.
class _PendingSessionId {
  final Completer<String?> _completer = Completer<String?>();
  StreamSubscription<CrispChatEvent>? subscription;
  Timer? _timer;

  Future<String?> get future => _completer.future;

  void complete(String? sessionId) {
    if (_completer.isCompleted) return;
    _timer?.cancel();
    subscription?.cancel();
    _completer.complete(sessionId);
  }

  /// Completes with `null` after [delay], replacing any earlier deadline.
  void completeAfter(Duration delay) {
    if (_completer.isCompleted) return;
    _timer?.cancel();
    _timer = Timer(delay, () => complete(null));
  }

  /// Gives up without querying, e.g. when opening the chat failed.
  void cancel() => complete(null);
}
