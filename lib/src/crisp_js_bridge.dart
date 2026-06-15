import 'dart:convert';

import 'config.dart';

/// Builds JavaScript snippets for the Crisp Web Chat SDK (`$crisp`).
///
/// Used by [WebFlutterCrispChat] and [DesktopFlutterCrispChat].
class CrispJsBridge {
  CrispJsBridge._();

  static String _escapeJs(String value) => jsonEncode(value);

  /// Crisp identity verification expects a real HMAC-SHA256 hex digest.
  static bool _isValidIdentitySignature(String? signature) {
    if (signature == null || signature.isEmpty) {
      return false;
    }
    return RegExp(r'^[a-fA-F0-9]{32,}$').hasMatch(signature);
  }

  /// Script injected before `l.js` to configure the website (and optional token).
  static String bootstrapScript({
    required String websiteId,
    String? tokenId,
  }) {
    final buffer = StringBuffer()
      ..writeln('window.\$crisp=[];')
      ..writeln('window.CRISP_WEBSITE_ID=${_escapeJs(websiteId)};');
    if (tokenId != null && tokenId.isNotEmpty) {
      buffer.writeln('window.CRISP_TOKEN_ID=${_escapeJs(tokenId)};');
    }
    return buffer.toString();
  }

  /// Applies [config] and opens the chatbox (call after Crisp script is loaded).
  static String applyConfigAndOpenChat(CrispConfig config) {
    final commands = <String>[
      ..._userAndSessionCommands(config),
      r'$crisp.push(["do", "chat:show"]);',
      r'$crisp.push(["do", "chat:open"]);',
    ];
    return commands.join('\n');
  }

  /// Queues session setup and chat open before `l.js` loads (Crisp async-safe API).
  ///
  /// See https://docs.crisp.chat/guides/chatbox-sdks/web-sdk/dollar-crisp/#use-crisp-before-it-is-ready
  static String queueBeforeLoad(CrispConfig config) {
    final lines = <String>[
      r'$crisp.push(["safe", true]);',
      r'$crisp.push(["config", "container:index", [999999]]);',
      r'$crisp.push(["on", "session:loaded", function(session_id) { window.__crispSessionId = session_id; }]);',
      ..._userAndSessionCommands(config),
      r'$crisp.push(["do", "chat:show"]);',
      r'$crisp.push(["do", "chat:open"]);',
    ];
    return lines.join('\n');
  }

  static List<String> _userAndSessionCommands(CrispConfig config) {
    final commands = <String>[];
    final user = config.user;
    if (user != null) {
      if (user.email != null && user.email!.isNotEmpty) {
        final signature = user.signature;
        if (_isValidIdentitySignature(signature)) {
          commands.add(
            '\$crisp.push(["set", "user:email", [${_escapeJs(user.email!)}, ${_escapeJs(signature!)}]]);',
          );
        } else {
          commands.add(
            '\$crisp.push(["set", "user:email", [${_escapeJs(user.email!)}]]);',
          );
        }
      }
      if (user.nickName != null && user.nickName!.isNotEmpty) {
        commands.add(
          '\$crisp.push(["set", "user:nickname", [${_escapeJs(user.nickName!)}]]);',
        );
      }
      if (user.phone != null && user.phone!.isNotEmpty) {
        commands.add(
          '\$crisp.push(["set", "user:phone", [${_escapeJs(user.phone!)}]]);',
        );
      }
      if (user.avatar != null && user.avatar!.isNotEmpty) {
        commands.add(
          '\$crisp.push(["set", "user:avatar", [${_escapeJs(user.avatar!)}]]);',
        );
      }
      final company = user.company;
      if (company != null && company.name != null && company.name!.isNotEmpty) {
        commands.add(_companyCommand(company));
      }
    }

    if (config.sessionSegment != null && config.sessionSegment!.isNotEmpty) {
      commands.add(
        '\$crisp.push(["set", "session:segments", [[${_escapeJs(config.sessionSegment!)}]]]);',
      );
    }

    return commands;
  }

  static String _companyCommand(Company company) {
    final details = <String, dynamic>{};
    if (company.url != null && company.url!.isNotEmpty) {
      details['url'] = company.url;
    }
    if (company.companyDescription != null &&
        company.companyDescription!.isNotEmpty) {
      details['description'] = company.companyDescription;
    }
    final employment = company.employment;
    if (employment != null &&
        (employment.title != null || employment.role != null)) {
      details['employment'] = [
        employment.title ?? '',
        employment.role ?? '',
      ];
    }
    final geo = company.geoLocation;
    if (geo != null && (geo.country != null || geo.city != null)) {
      details['geolocation'] = [geo.country ?? '', geo.city ?? ''];
    }
    final payload = <dynamic>[company.name];
    if (details.isNotEmpty) {
      payload.add(details);
    }
    return '\$crisp.push(${jsonEncode(["set", "user:company", payload])});';
  }

  static String resetSession() => r'$crisp.push(["do", "session:reset"]);';

  static String setSessionString({required String key, required String value}) {
    return '\$crisp.push(${jsonEncode([
      "set",
      "session:data",
      [
        [
          [key, value]
        ]
      ],
    ])});';
  }

  static String setSessionInt({required String key, required int value}) {
    return '\$crisp.push(${jsonEncode([
      "set",
      "session:data",
      [
        [
          [key, value]
        ]
      ],
    ])});';
  }

  static String setSessionSegments({
    required List<String> segments,
    bool overwrite = false,
  }) {
    final args = <dynamic>[segments];
    if (overwrite) {
      args.add(true);
    }
    return '\$crisp.push(${jsonEncode(["set", "session:segments", args])});';
  }

  static String pushSessionEvent({
    required String name,
    SessionEventColor color = SessionEventColor.blue,
  }) {
    // Crisp expects [[[text, optionalData, optionalColor]]] — omit data when unused.
    return '\$crisp.push(${jsonEncode([
      "set",
      "session:event",
      [
        [
          [name, color.name]
        ]
      ],
    ])});';
  }

  /// Reads session id; always returns a string for desktop WebView bridges.
  static String getSessionIdentifier() => forDesktopEvaluation(r'''
    if (window.__crispSessionId) return String(window.__crispSessionId);
    if (typeof $crisp === "undefined" || !$crisp.get) return "";
    var id = $crisp.get("session:identifier");
    return id != null && id !== "" ? String(id) : "";
  ''');

  /// WKWebView / WebView2 cannot return `null` from evaluateJavaScript.
  static String forDesktopEvaluation(String javaScript) {
    final body = javaScript.trim();
    if (body.isEmpty) {
      return '(function(){return "";})();';
    }
    return '(function(){try{$body;return "";}catch(e){return "";}})();';
  }

  /// Returns `"true"` or `"false"` as a string.
  static String isCrispReadyCheck() => forDesktopEvaluation(
        r'return (typeof window.$crisp !== "undefined" && typeof window.$crisp.is === "function") ? "true" : "false";',
      );

  static const String _sessionLoadedHook = r'''
    $crisp.push(["on", "session:loaded", function(session_id) {
      window.__crispSessionId = session_id;
    }]);
  ''';

  /// Full HTML page for desktop WebView embedding.
  static String embedHtml(CrispConfig config) {
    final bootstrap = bootstrapScript(
      websiteId: config.websiteID,
      tokenId: config.tokenId,
    );
    final afterLoad = applyConfigAndOpenChat(config);
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Crisp Chat</title>
  <style>
    html, body { margin: 0; height: 100%; background: #fff; }
    #crisp-status {
      padding: 24px;
      font-family: system-ui, -apple-system, sans-serif;
      color: #333;
    }
  </style>
</head>
<body>
  <div id="crisp-status">Loading Crisp chat…</div>
  <script>$bootstrap</script>
  <script src="https://client.crisp.chat/l.js" async></script>
  <script>
    function hideStatus() {
      var el = document.getElementById("crisp-status");
      if (el) el.style.display = "none";
    }
    function showStatus(msg) {
      var el = document.getElementById("crisp-status");
      if (el) el.textContent = msg;
    }
    window.onerror = function(msg) { showStatus("Failed to load chat: " + msg); };
    (function waitForCrisp() {
      if (typeof window.\$crisp === "undefined" || typeof window.\$crisp.is !== "function") {
        setTimeout(waitForCrisp, 100);
        return;
      }
      $_sessionLoadedHook
      $afterLoad
      hideStatus();
    })();
    setTimeout(function() {
      if (typeof window.\$crisp === "undefined" || typeof window.\$crisp.is !== "function") {
        showStatus("Could not load Crisp. Check network access (macOS sandbox: enable Outgoing Connections).");
      }
    }, 15000);
  </script>
</body>
</html>
''';
  }
}
