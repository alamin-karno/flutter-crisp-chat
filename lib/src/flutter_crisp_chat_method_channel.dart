import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  /// [resetCrispChatSession] is use to invoke the Method Channel and call native
  /// code with no arguments and this will reset the crisp chat session.
  @override
  Future<void> resetCrispChatSession() async {
    await methodChannel.invokeMethod('resetCrispChatSession');
  }

  /// [setSessionString] is used to invoke the Method Channel and call native
  /// code with arguments `key` and `value`.
  @override
  void setSessionString({required String key, required String value}) {
    methodChannel.invokeMethod('setSessionString', <String, String>{
      'key': key,
      'value': value,
    });
  }

  /// [setSessionInt] is used to invoke the Method Channel and call native
  /// code with arguments `key` and `value`.
  @override
  void setSessionInt({required String key, required int value}) {
    methodChannel.invokeMethod('setSessionInt', <String, dynamic>{
      'key': key,
      'value': value,
    });
  }

  /// [getSessionIdentifier] retrieves the current session identifier from the native platform.
  @override
  Future<String?> getSessionIdentifier() async {
    try {
      final sessionId =
          await methodChannel.invokeMethod<String>('getSessionIdentifier');
      return sessionId;
    } on PlatformException catch (e) {
      debugPrint("Failed to get session identifier: '${e.message}'.");
      return null;
    }
  }

  /// [setSessionSegments] Sets a collection of session segments
  /// and optionally overwrite existing ones (default is false)
  @override
  void setSessionSegments(
      {required List<String> segments, bool overwrite = false}) {
    methodChannel.invokeMethod('setSessionSegments', <String, dynamic>{
      'segments': segments,
      'overwrite': overwrite,
    });
  }
}
