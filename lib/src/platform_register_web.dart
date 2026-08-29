import 'flutter_crisp_chat_platform_interface.dart';
import 'flutter_crisp_chat_web.dart';

void registerCrispChatPlatform() {
  FlutterCrispChatPlatform.instance = WebFlutterCrispChat();
}
