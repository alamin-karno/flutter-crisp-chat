import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';
import 'crisp_event.dart';
import 'crisp_js_bridge.dart';
import 'crisp_message_content.dart';
import 'crisp_pending_identity.dart';
import 'flutter_crisp_chat_platform_interface.dart';

/// Desktop implementation (macOS, Windows, Linux) via embedded WebView or browser fallback.
class DesktopFlutterCrispChat extends FlutterCrispChatPlatform {
  Webview? _webview;
  String? _cachedSessionId;
  bool _crispReadyInWebview = false;
  Directory? _embedDirectory;

  /// Token and user details to apply to the next chat opening.
  final _pending = CrispPendingIdentity();

  /// Set when the session was reset while no chat window was open. The
  /// WebView keeps Crisp's session cookie, so the next chat page resets it
  /// before applying its config.
  bool _resetPending = false;

  @override
  Future<void> openCrispChat({required CrispConfig config}) async {
    _crispReadyInWebview = false;
    _cachedSessionId = null;
    final html = CrispJsBridge.embedHtml(
      _pending.applyTo(config),
      resetSessionFirst: _resetPending,
    );

    if (await WebviewWindow.isWebviewAvailable()) {
      try {
        await _closeWebview();
        await _disposeEmbedDirectory();

        final webview = await WebviewWindow.create(
          configuration: const CreateConfiguration(
            title: 'Crisp Chat',
            windowWidth: 420,
            windowHeight: 720,
            // A chat window, not a browser: keep the native title bar plain.
            // The host would also show the temporary file:// page below.
            titleBar: TitleBarOptions(
              showNavigation: false,
              showReload: false,
              showHost: false,
            ),
          ),
        );
        _webview = webview;
        // Forget the window once the user closes it, so later calls fall
        // back to their no-WebView behavior instead of failing.
        unawaited(webview.onClose.then((_) {
          if (identical(_webview, webview)) {
            _webview = null;
            _crispReadyInWebview = false;
          }
        }));

        // WKWebView / WebView2 block external scripts on data: URLs — use file://.
        final pageUrl = await _writeEmbedPage(html);
        await webview.launch(pageUrl);
        _resetPending = false;
        unawaited(_waitForCrispReady());
        return;
      } catch (e, stackTrace) {
        debugPrint('Crisp desktop WebView failed: $e\n$stackTrace');
      }
    }

    await _openInBrowser(config);
  }

  /// Closes the current chat window, if any.
  Future<void> _closeWebview() async {
    final webview = _webview;
    _webview = null;
    if (webview == null) {
      return;
    }
    try {
      await webview.close();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Crisp WebView close: $e');
      }
    }
  }

  /// Writes embed HTML to a temp file and returns a `file://` URI string.
  Future<String> _writeEmbedPage(String html) async {
    _embedDirectory =
        await Directory.systemTemp.createTemp('crisp_chat_webview_');
    final file = File('${_embedDirectory!.path}/index.html');
    await file.writeAsString(html, encoding: utf8);
    return file.uri.toString();
  }

  Future<void> _disposeEmbedDirectory() async {
    final dir = _embedDirectory;
    _embedDirectory = null;
    if (dir == null) {
      return;
    }
    try {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Crisp embed temp cleanup: $e');
      }
    }
  }

  Future<void> _openInBrowser(CrispConfig config) async {
    final uri = Uri.parse(
      'https://app.crisp.chat/website/${config.websiteID.trim()}/',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw StateError(
        'Could not open Crisp chat. Install WebView2 (Windows) or WebKitGTK (Linux), '
        'or allow opening https://app.crisp.chat in your browser.',
      );
    }
  }

  Future<void> _waitForCrispReady() async {
    // The native webview context needs a moment to initialize after
    // WebviewWindow.create() + launch(). Polling evaluateJavaScript
    // before the native side is ready produces "can not find webview for id: 0"
    // errors. A short initial delay avoids the bulk of these.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    for (var i = 0; i < 100; i++) {
      final ready = await _evaluateInWebview(CrispJsBridge.isCrispReadyCheck());
      if (ready == 'true') {
        _crispReadyInWebview = true;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _ensureCrispReady() async {
    if (_crispReadyInWebview) {
      return;
    }
    await _waitForCrispReady();
  }

  /// Runs [javaScript] in the WebView; scripts are wrapped to always return a
  /// string, which `evaluateJavaScript` hands back already decoded.
  Future<String?> _evaluateInWebview(String javaScript) async {
    final webview = _webview;
    if (webview == null) {
      return null;
    }
    final wrapped = javaScript.trim().startsWith('(function')
        ? javaScript
        : CrispJsBridge.forDesktopEvaluation(javaScript);
    try {
      final result = await webview.evaluateJavaScript(wrapped);
      return result?.toString();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        final msg = e.message ?? '';
        // "can not find webview for id: X" fires transiently while the native
        // context is still initializing — suppress it to avoid misleading noise.
        if (!msg.startsWith('can not find webview')) {
          debugPrint('Crisp WebView evaluateJavaScript: $msg');
        }
      }
      return null;
    } catch (e) {
      // 0.4 reports a closed window or an unsupported operation as other
      // errors (e.g. StateError, UnsupportedError).
      if (kDebugMode) {
        debugPrint('Crisp WebView evaluateJavaScript: $e');
      }
      return null;
    }
  }

  Future<void> _runInWebview(String javaScript) async {
    await _ensureCrispReady();
    await _evaluateInWebview(javaScript);
  }

  /// The website ID comes from [openCrispChat]; nothing to do here.
  @override
  Future<void> configure({required String websiteId}) async {}

  @override
  Future<void> setTokenId({required String? tokenId}) async {
    _pending.setToken(tokenId);
    await _runIfWebviewOpen(CrispJsBridge.setTokenId(tokenId));
  }

  @override
  Future<void> setUserEmail({required String email, String? signature}) async {
    _pending
      ..email = email
      ..signature = signature;
    await _runIfWebviewOpen(
        CrispJsBridge.setUserEmail(email: email, signature: signature));
  }

  @override
  Future<void> setUserNickname({required String nickname}) async {
    _pending.nickname = nickname;
    await _runIfWebviewOpen(CrispJsBridge.setUserNickname(nickname: nickname));
  }

  @override
  Future<void> setUserPhone({required String phone}) async {
    _pending.phone = phone;
    await _runIfWebviewOpen(CrispJsBridge.setUserPhone(phone: phone));
  }

  @override
  Future<void> setUserAvatar({required String avatar}) async {
    _pending.avatar = avatar;
    await _runIfWebviewOpen(CrispJsBridge.setUserAvatar(avatar: avatar));
  }

  /// Runs [javaScript] in the chat window if it is open; otherwise the
  /// pending identity applies it when the chat next opens.
  Future<void> _runIfWebviewOpen(String javaScript) async {
    if (_webview != null) {
      await _runInWebview(javaScript);
    }
  }

  @override
  Future<void> resetCrispChatSession() async {
    _pending.clearUser();
    _cachedSessionId = null;
    if (_webview == null) {
      // No chat window to run it in: don't wait for one, reset when the
      // chat next opens.
      _resetPending = true;
      return;
    }
    await _runInWebview(CrispJsBridge.resetSession());
  }

  @override
  void setSessionString({required String key, required String value}) {
    unawaited(
      _runInWebview(
        CrispJsBridge.setSessionString(key: key, value: value),
      ).catchError((Object e) {
        if (kDebugMode) {
          debugPrint('Crisp setSessionString failed: $e');
        }
      }),
    );
  }

  @override
  void setSessionInt({required String key, required int value}) {
    unawaited(
      _runInWebview(
        CrispJsBridge.setSessionInt(key: key, value: value),
      ).catchError((Object e) {
        if (kDebugMode) {
          debugPrint('Crisp setSessionInt failed: $e');
        }
      }),
    );
  }

  @override
  Future<String?> getSessionIdentifier() async {
    if (_cachedSessionId != null) {
      return _cachedSessionId;
    }
    if (_webview == null) {
      return null;
    }
    await _ensureCrispReady();
    final result =
        await _evaluateInWebview(CrispJsBridge.getSessionIdentifier());
    if (result != null && result.isNotEmpty) {
      _cachedSessionId = result;
      return _cachedSessionId;
    }
    return null;
  }

  @override
  Future<bool?> isSessionOngoing() async {
    if (_webview == null) {
      return null;
    }
    await _ensureCrispReady();
    return switch (await _evaluateInWebview(CrispJsBridge.isSessionOngoing())) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }

  @override
  void setSessionSegments({
    required List<String> segments,
    bool overwrite = false,
  }) {
    unawaited(
      _runInWebview(
        CrispJsBridge.setSessionSegments(
          segments: segments,
          overwrite: overwrite,
        ),
      ).catchError((Object e) {
        if (kDebugMode) {
          debugPrint('Crisp setSessionSegments failed: $e');
        }
      }),
    );
  }

  @override
  Future<void> pushSessionEvent({
    required String name,
    SessionEventColor color = SessionEventColor.blue,
  }) async {
    await _runInWebview(
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
    await _runInWebview(CrispJsBridge.runBotScenario(scenarioId: scenarioId));
  }

  @override
  Future<void> showMessage({required CrispMessageContent content}) async {
    await _runInWebview(CrispJsBridge.showMessage(content));
  }

  @override
  Future<void> openHelpdesk({required String websiteId}) async {
    if (_webview == null) {
      await openCrispChat(config: CrispConfig(websiteID: websiteId));
    }
    await _runInWebview(CrispJsBridge.openHelpdeskSearch());
  }

  @override
  Future<void> openHelpdeskArticle({
    required String websiteId,
    required String locale,
    required String slug,
    String? title,
    String? category,
  }) async {
    if (_webview == null) {
      await openCrispChat(config: CrispConfig(websiteID: websiteId));
    }
    await _runInWebview(CrispJsBridge.openHelpdeskArticle(
      locale: locale,
      slug: slug,
      title: title,
      category: category,
    ));
  }
}
