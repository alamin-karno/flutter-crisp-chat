import 'src/flutter_crisp_chat_platform_interface.dart';

class FlutterCrispChat {
  static Future<void> openCrispChat({required String websiteID}) {
    return FlutterCrispChatPlatform.instance.openCrispChat(
      websiteID: websiteID,
    );
  }
}
