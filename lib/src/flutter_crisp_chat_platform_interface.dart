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
}
