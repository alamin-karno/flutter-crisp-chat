import 'package:crisp_chat/crisp_chat.dart';
import 'package:crisp_chat/src/flutter_crisp_chat_method_channel.dart';
import 'package:crisp_chat/src/flutter_crisp_chat_platform_interface.dart';
import 'package:flutter/services.dart'; // Added for PlatformException
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// [MockFlutterCrispChatPlatform] is for testing method channel call.
class MockFlutterCrispChatPlatform
    with MockPlatformInterfaceMixin
    implements FlutterCrispChatPlatform {
  @override
  Future<String?> openCrispChat({required CrispConfig config}) =>
      Future.value();

  bool resetCrispChatSessionCalled = false;
  @override
  Future<void> resetCrispChatSession() async {
    resetCrispChatSessionCalled = true;
  }

  Map<String, String>? setSessionStringArgs;
  @override
  void setSessionString({required String key, required String value}) {
    setSessionStringArgs = {'key': key, 'value': value};
  }

  Map<String, dynamic>? setSessionIntArgs;
  @override
  void setSessionInt({required String key, required int value}) {
    setSessionIntArgs = {'key': key, 'value': value};
  }

  String? mockSessionId;
  bool getSessionIdentifierShouldThrowError = false;
  @override
  Future<String?> getSessionIdentifier() async {
    if (getSessionIdentifierShouldThrowError) {
      throw PlatformException(code: 'ERROR', message: 'Simulated error');
    }
    return mockSessionId;
  }

  Map<String, dynamic>? setSessionSegmentsArgs;
  @override
  void setSessionSegments({
    required List<String> segments,
    bool overwrite = false,
  }) {
    setSessionSegmentsArgs = {'segments': segments, 'overwrite': overwrite};
  }

  Map<String, dynamic>? setSessionAttributesArgs;
  @override
  Future<void> pushSessionEvent({
    required String name,
    SessionEventColor color = SessionEventColor.blue,
  }) async {
    setSessionAttributesArgs = {'name': name, 'color': color};
  }

  bool openChatboxFromNotificationCalled = false;
  bool mockOpenChatboxResult = false;
  @override
  Future<bool> openChatboxFromNotification() async {
    openChatboxFromNotificationCalled = true;
    return mockOpenChatboxResult;
  }

  @override
  void setOnNotificationTappedCallback(VoidCallback? callback) {
    // No-op for testing
  }

  bool mockVideoCallsSupported = false;
  @override
  Future<bool> isVideoCallsSupported() async => mockVideoCallsSupported;

  bool openHelpdeskCalled = false;
  Map<String, dynamic>? openHelpdeskArgs;
  @override
  Future<void> openHelpdesk({required String websiteId}) async {
    openHelpdeskCalled = true;
    openHelpdeskArgs = {'websiteId': websiteId};
  }

  bool openHelpdeskArticleCalled = false;
  Map<String, dynamic>? openHelpdeskArticleArgs;
  @override
  Future<void> openHelpdeskArticle({
    required String websiteId,
    required String locale,
    required String slug,
    String? title,
    String? category,
  }) async {
    openHelpdeskArticleCalled = true;
    openHelpdeskArticleArgs = {
      'websiteId': websiteId,
      'locale': locale,
      'slug': slug,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
    };
  }
}

void main() {
  final initialPlatform = FlutterCrispChatPlatform.instance;

  CrispConfig config = CrispConfig(websiteID: "YOUR_WEBSITE_KEY");

  test('$MethodChannelFlutterCrispChat is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCrispChat>());
  });

  test('openCrispChat', () async {
    MockFlutterCrispChatPlatform fakePlatform = MockFlutterCrispChatPlatform();
    FlutterCrispChatPlatform.instance = fakePlatform;

    await FlutterCrispChat.openCrispChat(config: config);
  });

  test('User.toJson includes identity verification signature', () {
    final user = User(
      email: 'user@example.com',
      signature: '0123456789abcdef',
    );

    expect(
      user.toJson(),
      containsPair('signature', '0123456789abcdef'),
    );
  });

  test('resetCrispChatSession', () async {
    MockFlutterCrispChatPlatform fakePlatform = MockFlutterCrispChatPlatform();
    FlutterCrispChatPlatform.instance = fakePlatform;

    await FlutterCrispChat.resetCrispChatSession();
    expect(fakePlatform.resetCrispChatSessionCalled, isTrue);
  });

  group('setSessionString', () {
    test('calls platform method with correct arguments', () {
      MockFlutterCrispChatPlatform fakePlatform =
          MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;

      FlutterCrispChat.setSessionString(key: 'testKey', value: 'testValue');
      expect(fakePlatform.setSessionStringArgs,
          equals({'key': 'testKey', 'value': 'testValue'}));
    });

    test('throws ArgumentError for empty key', () {
      expect(
        () => FlutterCrispChat.setSessionString(key: '', value: 'testValue'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for empty value', () {
      expect(
        () => FlutterCrispChat.setSessionString(key: 'testKey', value: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('setSessionInt', () {
    test('calls platform method with correct arguments', () {
      MockFlutterCrispChatPlatform fakePlatform =
          MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;

      FlutterCrispChat.setSessionInt(key: 'testKey', value: 123);
      expect(fakePlatform.setSessionIntArgs,
          equals({'key': 'testKey', 'value': 123}));
    });

    test('throws ArgumentError for empty key', () {
      expect(
        () => FlutterCrispChat.setSessionInt(key: '', value: 123),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('getSessionIdentifier', () {
    test(
      'returns session ID from platform',
      () async {
        final fakePlatform = MockFlutterCrispChatPlatform();
        fakePlatform.mockSessionId = 'testSessionId';
        FlutterCrispChatPlatform.instance = fakePlatform;

        final sessionId = await FlutterCrispChat.getSessionIdentifier();
        expect(sessionId, 'testSessionId');
      },
    );

    test(
      'returns null if platform throws error',
      () async {
        final fakePlatform = MockFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;
        await FlutterCrispChat.resetCrispChatSession();

        fakePlatform.getSessionIdentifierShouldThrowError = true;

        final sessionId = await FlutterCrispChat.getSessionIdentifier();
        expect(sessionId, isNull);
      },
    );
  });

  group('setSessionSegments', () {
    test(
      'calls platform method with correct arguments',
      () {
        final fakePlatform = MockFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;

        final segments = ['segment1', 'segment2'];
        FlutterCrispChat.setSessionSegments(
          segments: segments,
          overwrite: true,
        );

        expect(
          fakePlatform.setSessionSegmentsArgs,
          equals({'segments': segments, 'overwrite': true}),
        );
      },
    );

    test(
      'calls platform method with default overwrite value',
      () {
        final fakePlatform = MockFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;

        final segments = ['segment_a', 'segment_b'];
        FlutterCrispChat.setSessionSegments(
          segments: segments,
        ); // overwrite is false by default

        expect(
          fakePlatform.setSessionSegmentsArgs,
          equals({'segments': segments, 'overwrite': false}),
        );
      },
    );
  });

  group('pushSessionEvent', () {
    test(
      'calls platform method with correct arguments',
      () async {
        final fakePlatform = MockFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;

        await FlutterCrispChat.pushSessionEvent(
          name: 'testEvent',
          color: SessionEventColor.red,
        );

        expect(
          fakePlatform.setSessionAttributesArgs,
          equals({'name': 'testEvent', 'color': SessionEventColor.red}),
        );
      },
    );
  });

  group('openHelpdesk', () {
    test('calls platform method with correct websiteId', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
      await FlutterCrispChat.openHelpdesk(websiteId: 'test-website-id');
      expect(fakePlatform.openHelpdeskCalled, isTrue);
      expect(fakePlatform.openHelpdeskArgs, equals({'websiteId': 'test-website-id'}));
    });

    test('throws ArgumentError for empty websiteId', () {
      expect(
        FlutterCrispChat.openHelpdesk(websiteId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for whitespace-only websiteId', () {
      expect(
        FlutterCrispChat.openHelpdesk(websiteId: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('openHelpdeskArticle', () {
    test('calls platform method with all arguments', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
      await FlutterCrispChat.openHelpdeskArticle(
        websiteId: 'test-website-id',
        locale: 'en',
        slug: 'my-article',
        title: 'My Article',
        category: 'General',
      );
      expect(fakePlatform.openHelpdeskArticleCalled, isTrue);
      expect(
        fakePlatform.openHelpdeskArticleArgs,
        equals({
          'websiteId': 'test-website-id',
          'locale': 'en',
          'slug': 'my-article',
          'title': 'My Article',
          'category': 'General',
        }),
      );
    });

    test('calls platform method without optional fields', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
      await FlutterCrispChat.openHelpdeskArticle(
        websiteId: 'test-website-id',
        locale: 'en',
        slug: 'my-article',
      );
      expect(fakePlatform.openHelpdeskArticleCalled, isTrue);
      expect(
        fakePlatform.openHelpdeskArticleArgs,
        equals({'websiteId': 'test-website-id', 'locale': 'en', 'slug': 'my-article'}),
      );
    });

    test('throws ArgumentError for empty websiteId', () {
      expect(
        FlutterCrispChat.openHelpdeskArticle(
          websiteId: '',
          locale: 'en',
          slug: 'slug',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for empty locale', () {
      expect(
        FlutterCrispChat.openHelpdeskArticle(
          websiteId: 'valid-id',
          locale: '',
          slug: 'slug',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for empty slug', () {
      expect(
        FlutterCrispChat.openHelpdeskArticle(
          websiteId: 'valid-id',
          locale: 'en',
          slug: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
