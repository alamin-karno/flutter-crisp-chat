import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_crisp_chat/src/flutter_crisp_chat_method_channel.dart';

void main() {
  MethodChannelFlutterCrispChat platform = MethodChannelFlutterCrispChat();
  const MethodChannel channel = MethodChannel('flutter_crisp_chat');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('openCrispChat', () async {
    await platform.openCrispChat(websiteID: '');
  });
}
