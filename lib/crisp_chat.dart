import 'src/helper.dart';
import 'src/config.dart';
import 'src/flutter_crisp_chat_platform_interface.dart';
export 'src/config.dart';

/// [FlutterCrispChat] to call the native platform method.
class FlutterCrispChat {
  static Future<void> openCrispChat({required CrispConfig config}) {
    if (config.user?.email?.isEmail == false) {
      throw Exception("User email is incorrect!");
    }
    if (config.user?.company?.url?.isUrl == false) {
      throw Exception("Company url is incorrect!");
    }
    return FlutterCrispChatPlatform.instance.openCrispChat(config: config);
  }
}
