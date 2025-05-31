import 'package:flutter/foundation.dart';

import 'src/config.dart';
import 'src/flutter_crisp_chat_platform_interface.dart';
import 'src/helper.dart';

export 'src/config.dart';

/// [FlutterCrispChat] to call the native platform method.
class FlutterCrispChat {
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
  static Future<void> openCrispChat({required CrispConfig config}) {
    // Validate email if provided. This ensures that any email passed to the
    // native Crisp SDK is in a recognizable format.
    final email = config.user?.email;
    if (email != null && !email.isEmail) {
      throw ArgumentError.value(
          email, 'config.user.email', 'Invalid email format provided.');
    }

    // Validate company URL if provided. This ensures that any URL passed for
    // the company is a well-formed absolute URL.
    final url = config.user?.company?.url;
    if (url != null && !url.isUrl) {
      throw ArgumentError.value(url, 'config.user.company.url',
          'Invalid company URL format provided.');
    }

    // Call the platform-specific method to open Crisp chat
    return FlutterCrispChatPlatform.instance.openCrispChat(config: config);
  }

  /// Resets the current Crisp chat session.
  ///
  /// This method clears any ongoing chat session data, effectively starting fresh.
  /// It's useful for logging out a user or clearing user-specific data.
  ///
  /// {@category General}
  /// @return A [Future] that completes when the session has been reset.
  static Future<void> resetCrispChatSession() {
    return FlutterCrispChatPlatform.instance.resetCrispChatSession();
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
      return sessionId;
    } catch (e) {
      // This catch block handles any other unexpected errors during the platform call.
      if (kDebugMode) {
        print("Error retrieving session identifier: $e");
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
}
