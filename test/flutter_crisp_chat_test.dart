import 'package:crisp_chat/crisp_chat.dart';
import 'package:crisp_chat/src/flutter_crisp_chat_method_channel.dart';
import 'package:crisp_chat/src/flutter_crisp_chat_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// [MockFlutterCrispChatPlatform] is for testing method channel call.
class MockFlutterCrispChatPlatform
    with MockPlatformInterfaceMixin
    implements FlutterCrispChatPlatform {
  @override
  Future<String?> openCrispChat({required CrispConfig config}) =>
      Future.value();

  @override
  Future<void> resetCrispChatSession() {
    //
    throw UnimplementedError();
  }

  @override
  Future<void> setSessionString({required String key, required String value}) {
    //
    throw UnimplementedError();
  }

  @override
  Future<void> setSessionInt({required String key, required int value}) {
    //
    throw UnimplementedError();
  }

  @override
  Future<String?> getSessionIdentifier() {
    throw UnimplementedError();
  }
}

void main() {
  final FlutterCrispChatPlatform initialPlatform =
      FlutterCrispChatPlatform.instance;

  CrispConfig config = CrispConfig(websiteID: "YOUR_WEBSITE_KEY");

  test('$MethodChannelFlutterCrispChat is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCrispChat>());
  });

  test('openCrispChat', () async {
    MockFlutterCrispChatPlatform fakePlatform = MockFlutterCrispChatPlatform();
    FlutterCrispChatPlatform.instance = fakePlatform;

    await FlutterCrispChat.openCrispChat(config: config);
  });
}
