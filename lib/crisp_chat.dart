import 'src/helper.dart';
import 'src/config.dart';
import 'src/flutter_crisp_chat_platform_interface.dart';
export 'src/config.dart';

/// [FlutterCrispChat] to call the native platform method.
class FlutterCrispChat {
  /// [openCrispChat] to open crisp chat. This method need
  /// a required argument `CrispConfig` object which will be used to configure
  /// crisp chat.
  static Future<void> openCrispChat({required CrispConfig config}) {
    if (config.user?.email?.isEmail == false) {
      throw Exception("User email is incorrect!");
    }
    if (config.user?.company?.url?.isUrl == false) {
      throw Exception("Company url is incorrect!");
    }
    return FlutterCrispChatPlatform.instance.openCrispChat(config: config);
  }

  /// [resetCrispChatSession] is called when to reset the session.
  static Future<void> resetCrispChatSession() {
    return FlutterCrispChatPlatform.instance.resetCrispChatSession();
  }
}
