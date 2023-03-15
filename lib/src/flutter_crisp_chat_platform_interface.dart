import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  Future<void> openCrispChat({required String websiteID}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
