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

  test('isVideoCallsSupported', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'isVideoCallsSupported') {
          return true;
        }
        return null;
      },
    );
    expect(await platform.isVideoCallsSupported(), isTrue);
  });

  test('openHelpdesk sends correct method name and websiteId', () async {
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        captured = methodCall;
        return null;
      },
    );
    await platform.openHelpdesk(websiteId: 'test-website-id');
    expect(captured, isNotNull);
    expect(captured!.method, equals('openHelpdesk'));
    expect(captured!.arguments, containsPair('websiteId', 'test-website-id'));
  });

  test('openHelpdeskArticle sends correct method name and all arguments', () async {
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        captured = methodCall;
        return null;
      },
    );
    await platform.openHelpdeskArticle(
      websiteId: 'test-website-id',
      locale: 'en',
      slug: 'getting-started',
      title: 'Getting Started',
      category: 'General',
    );
    expect(captured, isNotNull);
    expect(captured!.method, equals('openHelpdeskArticle'));
    expect(captured!.arguments, containsPair('websiteId', 'test-website-id'));
    expect(captured!.arguments, containsPair('locale', 'en'));
    expect(captured!.arguments, containsPair('slug', 'getting-started'));
    expect(captured!.arguments, containsPair('title', 'Getting Started'));
    expect(captured!.arguments, containsPair('category', 'General'));
  });

  test('openHelpdeskArticle without optional args sends only required fields', () async {
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        captured = methodCall;
        return null;
      },
    );
    await platform.openHelpdeskArticle(
      websiteId: 'test-website-id',
      locale: 'fr',
      slug: 'faq',
    );
    expect(captured!.method, equals('openHelpdeskArticle'));
    expect(captured!.arguments, containsPair('websiteId', 'test-website-id'));
    expect(captured!.arguments, containsPair('locale', 'fr'));
    expect(captured!.arguments, containsPair('slug', 'faq'));
    expect((captured!.arguments as Map).containsKey('title'), isFalse);
    expect((captured!.arguments as Map).containsKey('category'), isFalse);
  });
}
