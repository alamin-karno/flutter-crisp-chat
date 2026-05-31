import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/platform_register_web.dart';

/// Web plugin registration for `crisp_chat`.
class CrispChatWeb {
  /// Registers the Web implementation of [FlutterCrispChatPlatform].
  static void registerWith(Registrar registrar) {
    registerCrispChatPlatform();
  }
}
