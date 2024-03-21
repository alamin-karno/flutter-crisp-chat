import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'config.dart';
import 'flutter_crisp_chat_platform_interface.dart';

/// An implementation of [FlutterCrispChatPlatform] that uses method channels.
class MethodChannelFlutterCrispChat extends FlutterCrispChatPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_crisp_chat');

  /// [openCrispChat] is use to invoke the Method Channel and call native
  /// code with arguments `websiteID`.
  @override
  Future<void> openCrispChat({required CrispConfig config}) async {
    await methodChannel.invokeMethod<CrispConfig>(
        'openCrispChat', config.toJson());
  }
}
