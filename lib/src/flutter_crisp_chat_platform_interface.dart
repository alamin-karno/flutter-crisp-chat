import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'config.dart';
import 'flutter_crisp_chat_method_channel.dart';

abstract class FlutterCrispChatPlatform extends PlatformInterface {
  /// Constructs a FlutterCrispChatPlatform.
  FlutterCrispChatPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterCrispChatPlatform _instance = MethodChannelFlutterCrispChat();

  /// The default instance of [FlutterCrispChatPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterCrispChat].
  static FlutterCrispChatPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterCrispChatPlatform] when
  /// they register themselves.
  static set instance(FlutterCrispChatPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// [openCrispChat] is to call native platform and if no implementation
  /// found through error.
  Future<void> openCrispChat({required CrispConfig config}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// [resetCrispChatSession] is to call native platform and if no implementation
  /// found through error.
  Future<void> resetCrispChatSession() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// [setSessionString] is to call native platform and if no implementation
  /// found through error.
  void setSessionString({required String key, required String value}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// [setSessionInt] is to call native platform and if no implementation
  /// found through error.
  void setSessionInt({required String key, required int value}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// [getSessionIdentifier] retrieves the current session identifier from the native platform.
  Future<String?> getSessionIdentifier() {
    throw UnimplementedError(
        'getSessionIdentifier() has not been implemented.');
  }

  /// [setSessionSegments] Sets a collection of session segments
  /// and optionally overwrite existing ones (default is false)
  void setSessionSegments({
    required List<String> segments,
    bool overwrite = false,
  }) {
    throw UnimplementedError('setSessionSegments() has not been implemented.');
  }

  /// [pushSessionEvent] pushes a session event to the native platform.
  /// /// [name] is the name of the event, and [color] is the color associated with
  /// the event, defaulting to blue.
  Future<void> pushSessionEvent({
    required String name,
    SessionEventColor color = SessionEventColor.blue,
  }) {
    throw UnimplementedError('pushSessionEvent() has not been implemented.');
  }

  /// [openChatboxFromNotification] attempts to open the Crisp chatbox from
  /// a notification intent. Returns `true` if the chatbox was opened
  /// successfully (i.e., the app was launched from a Crisp notification),
  /// `false` otherwise.
  Future<bool> openChatboxFromNotification() {
    throw UnimplementedError(
        'openChatboxFromNotification() has not been implemented.');
  }

  /// [setOnNotificationTappedCallback] sets a callback that will be invoked
  /// when a Crisp notification is tapped while the app is running
  /// (background → foreground via onNewIntent).
  void setOnNotificationTappedCallback(VoidCallback? callback) {
    throw UnimplementedError(
        'setOnNotificationTappedCallback() has not been implemented.');
  }
}
