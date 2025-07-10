import 'package:crisp_chat/src/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_chat/src/flutter_crisp_chat_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Moved to the top

  MethodChannelFlutterCrispChat platform = MethodChannelFlutterCrispChat();
  const MethodChannel channel = MethodChannel('flutter_crisp_chat');
  CrispConfig config = CrispConfig(websiteID: "YOUR_WEBSITE_KEY");

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return null; // Changed to return null for a void method
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('openCrispChat', () async {
    await platform.openCrispChat(config: config);
    // Basic check to ensure no MissingPluginException is thrown
  });
}
