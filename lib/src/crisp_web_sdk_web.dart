import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'config.dart';
import 'crisp_js_bridge.dart';

@JS('eval')
external JSAny? _globalEval(JSString source);

/// Crisp Web Chat SDK (`$crisp`) bindings for Flutter Web.
class CrispWebSdk {
  CrispWebSdk._();

  static bool _scriptInjected = false;
  static String? _loadedWebsiteId;
  static Completer<void>? _loaderCompleter;

  static bool get isAvailable => true;

  static JSObject get _window => web.window as JSObject;

  /// True only after `l.js` has initialized the SDK (`$crisp.is` exists).
  static bool get _isCrispSdkLoaded {
    final result = _globalEval(
      r'(function(){return typeof window.$crisp!=="undefined"&&typeof window.$crisp.is==="function";})();'
          .toJS,
    );
    return result?.dartify() == true;
  }

  static void _setBootstrap({required String websiteId, String? tokenId}) {
    _window.setProperty(r'$crisp'.toJS, <JSAny?>[].toJS);
    _window.setProperty('CRISP_WEBSITE_ID'.toJS, websiteId.toJS);
    if (tokenId != null && tokenId.isNotEmpty) {
      _window.setProperty('CRISP_TOKEN_ID'.toJS, tokenId.toJS);
    } else {
      _window.delete('CRISP_TOKEN_ID'.toJS);
    }
  }

  static Future<void> _injectLoaderScript() {
    if (_loaderCompleter != null) {
      return _loaderCompleter!.future;
    }
    final completer = Completer<void>();
    _loaderCompleter = completer;

    final script = web.document.createElement('script') as web.HTMLScriptElement;
    script.src = 'https://client.crisp.chat/l.js';
    script.async = true;
    script.onload = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }).toJS;
    script.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Failed to load Crisp client script (client.crisp.chat).'),
        );
      }
    }).toJS;
    web.document.head!.appendChild(script);

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw StateError('Timed out loading Crisp client script.'),
    );
  }

  static Future<void> _waitForCrispSdk() async {
    for (var i = 0; i < 150; i++) {
      if (_isCrispSdkLoaded) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('Crisp Web SDK did not finish loading.');
  }

  /// Waits until Crisp reports an active visitor session (chat content can load).
  static Future<void> _waitForSessionOngoing() async {
    for (var i = 0; i < 150; i++) {
      final result = _globalEval(
        r'(function(){try{return ($crisp.is&&$crisp.is("session:ongoing"))?"1":"0";}catch(e){return "0";}})();'
            .toJS,
      );
      if (result?.dartify()?.toString() == '1') {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  static Future<void> ensureLoaded({
    required String websiteId,
    String? tokenId,
  }) async {
    final websiteChanged =
        _loadedWebsiteId != null && _loadedWebsiteId != websiteId;

    if (websiteChanged) {
      _scriptInjected = false;
      _loaderCompleter = null;
    }

    _setBootstrap(websiteId: websiteId, tokenId: tokenId);

    if (!_scriptInjected) {
      await _injectLoaderScript();
      _scriptInjected = true;
    }

    _loadedWebsiteId = websiteId;
    await _waitForCrispSdk();
  }

  static Future<void> runScript(String javaScript) async {
    await _waitForCrispSdk();
    _globalEval(javaScript.toJS);
  }

  /// Waits until the visitor has an active session (safe before [session:event]).
  static Future<void> waitForSessionOngoing() => _waitForSessionOngoing();

  static Future<void> applyConfigAndOpen(CrispConfig config) async {
    final websiteId = config.websiteID.trim();
    final needsQueue = !_scriptInjected || _loadedWebsiteId != websiteId;

    _setBootstrap(websiteId: websiteId, tokenId: config.tokenId);

    if (needsQueue) {
      // Queue pushes before l.js so Crisp processes them when the SDK boots.
      _globalEval(CrispJsBridge.queueBeforeLoad(config).toJS);
      if (!_scriptInjected) {
        await _injectLoaderScript();
        _scriptInjected = true;
      }
      _loadedWebsiteId = websiteId;
      await _waitForCrispSdk();
      await _waitForSessionOngoing();
      return;
    }

    await _waitForCrispSdk();
    await runScript(CrispJsBridge.applyConfigAndOpenChat(config));
    await _waitForSessionOngoing();
  }

  static Future<String?> getSessionIdentifier() async {
    if (!_isCrispSdkLoaded) {
      return null;
    }
    final result = _globalEval(CrispJsBridge.getSessionIdentifier().toJS);
    final id = result?.dartify()?.toString();
    if (id == null || id.isEmpty) {
      return null;
    }
    return id;
  }
}
