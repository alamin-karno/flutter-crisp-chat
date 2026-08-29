import 'config.dart';

/// No-op Crisp web runtime (mobile/native test targets).
class CrispWebSdk {
  static bool get isAvailable => false;

  static Future<void> ensureLoaded({
    required String websiteId,
    String? tokenId,
  }) async {}

  static Future<void> runScript(String javaScript) async {}

  static Future<void> waitForSessionOngoing() async {}

  static Future<void> applyConfigAndOpen(CrispConfig config) async {}

  static Future<String?> getSessionIdentifier() async => null;
}
