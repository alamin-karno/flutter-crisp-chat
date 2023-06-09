import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_crisp_chat_platform_interface.dart';

/// An implementation of [FlutterCrispChatPlatform] that uses method channels.
class MethodChannelFlutterCrispChat extends FlutterCrispChatPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_crisp_chat');

  /// [openCrispChat] is use to invoke the Method Channel and call native
  /// code with argruments `websiteID`.
  @override
  Future<void> openCrispChat({required String websiteID}) async {
    await methodChannel.invokeMethod<String>('openCrispChat', {
      "websiteID": websiteID,
    });
  }
}
