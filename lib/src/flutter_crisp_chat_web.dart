import 'package:flutter/widgets.dart';

import 'config.dart';
import 'crisp_js_bridge.dart';
import 'crisp_web_sdk.dart';
import 'flutter_crisp_chat_platform_interface.dart';

/// Web implementation using the official Crisp Web Chat SDK (`$crisp`).
class WebFlutterCrispChat extends FlutterCrispChatPlatform {
  @override
  Future<void> openCrispChat({required CrispConfig config}) async {
    await CrispWebSdk.applyConfigAndOpen(config);
  }

  @override
  Future<void> resetCrispChatSession() async {
    await CrispWebSdk.runScript(CrispJsBridge.resetSession());
  }

  @override
  void setSessionString({required String key, required String value}) {
    CrispWebSdk.runScript(
      CrispJsBridge.setSessionString(key: key, value: value),
    );
  }

  @override
  void setSessionInt({required String key, required int value}) {
    CrispWebSdk.runScript(
      CrispJsBridge.setSessionInt(key: key, value: value),
    );
  }

  @override
  Future<String?> getSessionIdentifier() => CrispWebSdk.getSessionIdentifier();

  @override
  void setSessionSegments({
    required List<String> segments,
    bool overwrite = false,
  }) {
    CrispWebSdk.runScript(
      CrispJsBridge.setSessionSegments(segments: segments, overwrite: overwrite),
    );
  }

  @override
  Future<void> pushSessionEvent({
    required String name,
    SessionEventColor color = SessionEventColor.blue,
  }) async {
    await CrispWebSdk.waitForSessionOngoing();
    await CrispWebSdk.runScript(
      CrispJsBridge.pushSessionEvent(name: name, color: color),
    );
  }

  @override
  Future<bool> openChatboxFromNotification() async => false;

  @override
  void setOnNotificationTappedCallback(VoidCallback? callback) {}

  @override
  Future<bool> isVideoCallsSupported() async => true;

  @override
  Future<void> openHelpdesk({required String websiteId}) async {
    await CrispWebSdk.ensureLoaded(websiteId: websiteId);
    await CrispWebSdk.runScript(CrispJsBridge.openHelpdeskSearch());
  }

  @override
  Future<void> openHelpdeskArticle({
    required String websiteId,
    required String locale,
    required String slug,
    String? title,
    String? category,
  }) async {
    await CrispWebSdk.ensureLoaded(websiteId: websiteId);
    await CrispWebSdk.runScript(CrispJsBridge.openHelpdeskArticle(
      locale: locale,
      slug: slug,
      title: title,
      category: category,
    ));
  }
}
