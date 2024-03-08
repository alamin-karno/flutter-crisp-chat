import 'package:crisp_chat/src/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_chat/src/flutter_crisp_chat_method_channel.dart';

void main() {
  MethodChannelFlutterCrispChat platform = MethodChannelFlutterCrispChat();
  const MethodChannel channel = MethodChannel('flutter_crisp_chat');
  CrispConfig config = CrispConfig(websiteID: "YOUR_WEBSITE_KEY");

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMethodCallHandler(null);
  });

  test('openCrispChat', () async {
    await platform.openCrispChat(config: config);
  });
}
