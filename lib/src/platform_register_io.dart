import 'package:flutter/foundation.dart';

import 'flutter_crisp_chat_desktop.dart';
import 'flutter_crisp_chat_platform_interface.dart';

void registerCrispChatPlatform() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      FlutterCrispChatPlatform.instance = DesktopFlutterCrispChat();
    default:
      break;
  }
}
