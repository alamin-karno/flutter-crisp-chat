import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'src/config.dart';
import 'src/flutter_crisp_chat_platform_interface.dart';
import 'src/helper.dart';
import 'src/platform_register.dart';

export 'src/config.dart';

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

    // Call the platform-specific method to open Crisp chat
    await FlutterCrispChatPlatform.instance.openCrispChat(config: config);

    // After opening, get and cache the session identifier.
    await Future.delayed(const Duration(seconds: 3));
    try {
      final newSessionId =
          await FlutterCrispChatPlatform.instance.getSessionIdentifier();
      if (newSessionId != null && newSessionId != _sessionIdentifier) {
        _sessionIdentifier = newSessionId;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error caching session identifier: $e");
      }
    }
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
    _sessionIdentifier = null;
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

  /// Marks all operator messages as read for the current visitor session.
  ///
  /// Calls the Crisp REST API [Mark Messages As Read In Conversation](https://docs.crisp.chat/references/rest-api/v1/#mark-messages-as-read-in-conversation)
  /// endpoint. Use this as a workaround on iOS when the native SDK does not
  /// reset [unread.visitor](https://docs.crisp.chat/references/rest-api/v1/#get-a-conversation)
  /// after the visitor reads messages in chat.
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
  /// - **iOS:** `true` only when the app was built with video support enabled:
  ///   **CocoaPods:** `$CrispChatWebRTC = true` in `ios/Podfile`;
  ///   **SPM:** `CRISP_CHAT_WEBRTC=true` before `flutter build ios`.
  ///   Default builds return `false`.
  /// - **Android:** always `false` until Crisp ships native video support.
  /// - **Web / desktop:** `true` (calls are handled by the web chatbox when enabled
  ///   in your Crisp dashboard).
  ///
  /// This is a build-time capability check, not a runtime toggle. See
  /// [Platform setup — Enable video calls (iOS)](https://alamin-karno.github.io/flutter-crisp-chat/getting_started/platform_setup.html#enable-video-calls-ios-only).
  ///
  /// {@category General}
  static Future<bool> isVideoCallsSupported() {
    return FlutterCrispChatPlatform.instance.isVideoCallsSupported();
  }
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
