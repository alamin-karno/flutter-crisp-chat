import 'src/config.dart';
import 'src/flutter_crisp_chat_platform_interface.dart';
import 'src/helper.dart';

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

  /// [setSessionString]  is to set session data string.
  /// [This data only send while [openCrispChat] is called.]
  static void setSessionString({required String key, required String value}) {
    FlutterCrispChatPlatform.instance.setSessionString(key: key, value: value);
  }

  /// [setSessionInt]  is to set session data int.
  /// [This data only send while [openCrispChat] is called.]
  static void setSessionInt({required String key, required int value}) {
    FlutterCrispChatPlatform.instance.setSessionInt(key: key, value: value);
  }
}
