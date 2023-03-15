import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_crisp_chat/crisp_chat.dart';
import 'package:flutter_crisp_chat/src/flutter_crisp_chat_platform_interface.dart';
import 'package:flutter_crisp_chat/src/flutter_crisp_chat_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterCrispChatPlatform
    with MockPlatformInterfaceMixin
    implements FlutterCrispChatPlatform {
  @override
  Future<String?> openCrispChat({required String websiteID}) => Future.value();
}

void main() {
  final FlutterCrispChatPlatform initialPlatform =
      FlutterCrispChatPlatform.instance;

  test('$MethodChannelFlutterCrispChat is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCrispChat>());
  });

  test('openCrispChat', () async {
    FlutterCrispChat flutterCrispChatPlugin = FlutterCrispChat();
    MockFlutterCrispChatPlatform fakePlatform = MockFlutterCrispChatPlatform();
    FlutterCrispChatPlatform.instance = fakePlatform;

    await flutterCrispChatPlugin.openCrispChat(websiteID: '');
  });
}
