import 'package:flutter/widgets.dart';

import 'config.dart';
import 'crisp_event.dart';
import 'crisp_js_bridge.dart';
import 'crisp_message_content.dart';
import 'crisp_pending_identity.dart';
import 'crisp_web_sdk.dart';
import 'flutter_crisp_chat_platform_interface.dart';

/// Web implementation using the official Crisp Web Chat SDK (`$crisp`).
class WebFlutterCrispChat extends FlutterCrispChatPlatform {
  /// Token and user details to apply to the next chat opening.
  final _pending = CrispPendingIdentity();

  @override
  Future<void> openCrispChat({required CrispConfig config}) async {
    await CrispWebSdk.applyConfigAndOpen(_pending.applyTo(config));
  }

  /// The website ID comes from [openCrispChat]; nothing to do here.
  @override
  Future<void> configure({required String websiteId}) async {}

  @override
  Future<void> setTokenId({required String? tokenId}) async {
    _pending.setToken(tokenId);
    if (CrispWebSdk.isLoaded) {
      await CrispWebSdk.runScript(CrispJsBridge.setTokenId(tokenId));
    }
  }

  @override
  Future<void> setUserEmail({required String email, String? signature}) async {
    _pending
      ..email = email
      ..signature = signature;
    await _runIfLoaded(
        CrispJsBridge.setUserEmail(email: email, signature: signature));
  }

  @override
  Future<void> setUserNickname({required String nickname}) async {
    _pending.nickname = nickname;
    await _runIfLoaded(CrispJsBridge.setUserNickname(nickname: nickname));
  }

  @override
  Future<void> setUserPhone({required String phone}) async {
    _pending.phone = phone;
    await _runIfLoaded(CrispJsBridge.setUserPhone(phone: phone));
  }

  @override
  Future<void> setUserAvatar({required String avatar}) async {
    _pending.avatar = avatar;
    await _runIfLoaded(CrispJsBridge.setUserAvatar(avatar: avatar));
  }

  Future<void> _runIfLoaded(String javaScript) async {
    if (CrispWebSdk.isLoaded) {
      await CrispWebSdk.runScript(javaScript);
    }
  }

  @override
  Future<void> resetCrispChatSession() async {
    _pending.clearUser();
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
  Future<bool?> isSessionOngoing() => CrispWebSdk.isSessionOngoing();

  @override
  void setSessionSegments({
    required List<String> segments,
    bool overwrite = false,
  }) {
    CrispWebSdk.runScript(
      CrispJsBridge.setSessionSegments(
          segments: segments, overwrite: overwrite),
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
  Stream<CrispChatEvent> get onCrispEvent => const Stream.empty();

  @override
  Future<void> runBotScenario({required String scenarioId}) async {
    await CrispWebSdk.waitForSessionOngoing();
    await CrispWebSdk.runScript(
      CrispJsBridge.runBotScenario(scenarioId: scenarioId),
    );
  }

  @override
  Future<void> showMessage({required CrispMessageContent content}) async {
    await CrispWebSdk.runScript(CrispJsBridge.showMessage(content));
  }

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
