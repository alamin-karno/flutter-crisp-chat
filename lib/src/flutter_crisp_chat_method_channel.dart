import 'dart:ui';

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

  /// Callback invoked when a Crisp notification is tapped while the app
  /// is running (background → foreground via onNewIntent).
  VoidCallback? _onNotificationTappedCallback;

  /// Whether the native method call handler has been set up.
  bool _isHandlerRegistered = false;

  /// Lazily registers the native → Dart method call handler.
  /// This avoids calling [setMethodCallHandler] before the binding is ready.
  void _ensureNativeHandlerRegistered() {
    if (!_isHandlerRegistered) {
      _isHandlerRegistered = true;
      methodChannel.setMethodCallHandler(_handleNativeMethodCall);
    }
  }

  /// Handles method calls from native platform to Dart.
  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCrispNotificationTapped':
        _onNotificationTappedCallback?.call();
        break;
    }
  }

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
      final sessionId = await methodChannel.invokeMethod<String>(
        'getSessionIdentifier',
      );
      return sessionId;
    } on PlatformException catch (e) {
      debugPrint("Failed to get session identifier: '${e.message}'.");
      return null;
    }
  }

  /// [setSessionSegments] Sets a collection of session segments
  /// and optionally overwrite existing ones (default is false)
  @override
  void setSessionSegments({
    required List<String> segments,
    bool overwrite = false,
  }) {
    methodChannel.invokeMethod('setSessionSegments', <String, dynamic>{
      'segments': segments,
      'overwrite': overwrite,
    });
  }

  /// [pushSessionEvent] is used to invoke the Method Channel and call native
  /// code with arguments `name` and `color`.
  @override
  Future<void> pushSessionEvent({
    required String name,
    SessionEventColor color = SessionEventColor.blue,
  }) async {
    await methodChannel.invokeMethod('pushSessionEvent', <String, dynamic>{
      'name': name,
      'color': color.name.toString(),
    });
  }

  /// [openChatboxFromNotification] attempts to open the Crisp chatbox from
  /// a notification intent. Returns `true` if the chatbox was opened
  /// successfully, `false` otherwise.
  @override
  Future<bool> openChatboxFromNotification() async {
    _ensureNativeHandlerRegistered();
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'openChatboxFromNotification',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to open chatbox from notification: '${e.message}'.");
      return false;
    }
  }

  /// [setOnNotificationTappedCallback] sets a callback that fires when a
  /// Crisp notification is tapped while the app is running.
  @override
  void setOnNotificationTappedCallback(VoidCallback? callback) {
    _ensureNativeHandlerRegistered();
    _onNotificationTappedCallback = callback;
  }
}
