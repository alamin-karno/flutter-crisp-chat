import 'dart:async';

import 'package:crisp_chat/crisp_chat.dart';
import 'package:crisp_chat/src/flutter_crisp_chat_method_channel.dart';
import 'package:crisp_chat/src/flutter_crisp_chat_platform_interface.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart'; // Added for PlatformException
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// [MockFlutterCrispChatPlatform] is for testing method channel call.
class MockFlutterCrispChatPlatform
    with MockPlatformInterfaceMixin
    implements FlutterCrispChatPlatform {
  int openCrispChatCalls = 0;
  bool openCrispChatShouldThrowError = false;
  @override
  Future<String?> openCrispChat({required CrispConfig config}) async {
    openCrispChatCalls++;
    if (openCrispChatShouldThrowError) {
      throw PlatformException(code: 'ERROR', message: 'Simulated error');
    }
    return null;
  }

  int getSessionIdentifierCalls = 0;

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
    getSessionIdentifierCalls++;
    if (getSessionIdentifierShouldThrowError) {
      throw PlatformException(code: 'ERROR', message: 'Simulated error');
    }
    return mockSessionId;
  }

  bool? mockIsSessionOngoing;
  bool isSessionOngoingShouldThrowError = false;
  @override
  Future<bool?> isSessionOngoing() async {
    if (isSessionOngoingShouldThrowError) {
      throw PlatformException(code: 'ERROR', message: 'Simulated error');
    }
    return mockIsSessionOngoing;
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

  final StreamController<CrispChatEvent> eventStreamController =
      StreamController<CrispChatEvent>.broadcast();
  @override
  Stream<CrispChatEvent> get onCrispEvent => eventStreamController.stream;

  bool runBotScenarioCalled = false;
  Map<String, dynamic>? runBotScenarioArgs;
  @override
  Future<void> runBotScenario({required String scenarioId}) async {
    runBotScenarioCalled = true;
    runBotScenarioArgs = {'scenarioId': scenarioId};
  }

  final List<MapEntry<String, Object?>> identityCalls = [];
  @override
  Future<void> configure({required String websiteId}) async {
    identityCalls.add(MapEntry('configure', websiteId));
  }

  @override
  Future<void> setTokenId({required String? tokenId}) async {
    identityCalls.add(MapEntry('setTokenId', tokenId));
  }

  @override
  Future<void> setUserEmail({required String email, String? signature}) async {
    identityCalls.add(MapEntry('setUserEmail', [email, signature]));
  }

  @override
  Future<void> setUserNickname({required String nickname}) async {
    identityCalls.add(MapEntry('setUserNickname', nickname));
  }

  @override
  Future<void> setUserPhone({required String phone}) async {
    identityCalls.add(MapEntry('setUserPhone', phone));
  }

  @override
  Future<void> setUserAvatar({required String avatar}) async {
    identityCalls.add(MapEntry('setUserAvatar', avatar));
  }

  final List<CrispMessageContent> shownMessages = [];
  @override
  Future<void> showMessage({required CrispMessageContent content}) async {
    shownMessages.add(content);
  }
}

/// Like the Web and desktop implementations: emits no [CrispChatEvent]s.
class NoEventsFlutterCrispChatPlatform extends MockFlutterCrispChatPlatform {
  @override
  Stream<CrispChatEvent> get onCrispEvent => const Stream.empty();
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

  test('CrispConfig.toJson serializes colorMode by name', () {
    for (final mode in CrispColorMode.values) {
      final config = CrispConfig(websiteID: 'site-id', colorMode: mode);
      expect(config.toJson()['colorMode'], mode.name);
    }
    expect(CrispConfig(websiteID: 'site-id').toJson()['colorMode'], isNull);
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

  group('token and user identity', () {
    late MockFlutterCrispChatPlatform fakePlatform;
    List<Object?> calls() =>
        fakePlatform.identityCalls.map((e) => [e.key, e.value]).toList();

    setUp(() {
      fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
    });

    test('configure trims the website ID', () async {
      await FlutterCrispChat.configure(websiteId: '  site-id ');
      expect(calls(), [
        ['configure', 'site-id'],
      ]);
    });

    test('configure rejects an empty website ID', () {
      expect(() => FlutterCrispChat.configure(websiteId: '  '),
          throwsArgumentError);
      expect(fakePlatform.identityCalls, isEmpty);
    });

    test('setTokenId forwards the token, and null or blank clears it',
        () async {
      await FlutterCrispChat.setTokenId('user-42');
      await FlutterCrispChat.setTokenId(null);
      await FlutterCrispChat.setTokenId('  ');
      expect(calls(), [
        ['setTokenId', 'user-42'],
        ['setTokenId', null],
        ['setTokenId', null],
      ]);
    });

    test('user setters forward their values', () async {
      await FlutterCrispChat.setUserEmail('a@example.com', signature: 'abc');
      await FlutterCrispChat.setUserEmail('b@example.com', signature: '');
      await FlutterCrispChat.setUserNickname('Ann');
      await FlutterCrispChat.setUserPhone('+15550100');
      await FlutterCrispChat.setUserAvatar('https://example.com/a.png');
      expect(calls(), [
        [
          'setUserEmail',
          ['a@example.com', 'abc']
        ],
        [
          'setUserEmail',
          ['b@example.com', null]
        ],
        ['setUserNickname', 'Ann'],
        ['setUserPhone', '+15550100'],
        ['setUserAvatar', 'https://example.com/a.png'],
      ]);
    });

    test('user setters reject invalid values', () {
      expect(() => FlutterCrispChat.setUserEmail('not-an-email'),
          throwsArgumentError);
      expect(() => FlutterCrispChat.setUserNickname(' '), throwsArgumentError);
      expect(() => FlutterCrispChat.setUserPhone(''), throwsArgumentError);
      expect(() => FlutterCrispChat.setUserAvatar('not a url'),
          throwsArgumentError);
      expect(fakePlatform.identityCalls, isEmpty);
    });
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

  group('isSessionOngoing', () {
    test('returns the platform value', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;

      for (final value in [true, false, null]) {
        fakePlatform.mockIsSessionOngoing = value;
        expect(await FlutterCrispChat.isSessionOngoing(), value);
      }
    });

    test('returns null if the platform throws', () async {
      final fakePlatform = MockFlutterCrispChatPlatform()
        ..isSessionOngoingShouldThrowError = true;
      FlutterCrispChatPlatform.instance = fakePlatform;

      expect(await FlutterCrispChat.isSessionOngoing(), isNull);
    });
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

  group('runBotScenario', () {
    test('calls platform method with correct scenarioId', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
      await FlutterCrispChat.runBotScenario(scenarioId: 'test-scenario-id');
      expect(fakePlatform.runBotScenarioCalled, isTrue);
      expect(fakePlatform.runBotScenarioArgs,
          equals({'scenarioId': 'test-scenario-id'}));
    });

    test('throws ArgumentError for empty scenarioId', () {
      expect(
        FlutterCrispChat.runBotScenario(scenarioId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for whitespace-only scenarioId', () {
      expect(
        FlutterCrispChat.runBotScenario(scenarioId: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('showMessage', () {
    test('calls platform method with the content', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
      const content = CrispTextContent('Hello world');
      await FlutterCrispChat.showMessage(content);
      expect(fakePlatform.shownMessages, equals([content]));
    });

    test('throws ArgumentError for empty text', () {
      expect(
        FlutterCrispChat.showMessage(const CrispTextContent('  ')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for a picker without choices', () {
      expect(
        FlutterCrispChat.showMessage(
          const CrispPickerContent(id: 'id', text: 'Pick', choices: []),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for a carousel without targets', () {
      expect(
        FlutterCrispChat.showMessage(
          const CrispCarouselContent(text: 'Browse', targets: []),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CrispConfig.localMessages', () {
    test('rejects invalid messages before opening the chat', () {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
      expect(
        FlutterCrispChat.openCrispChat(
          config: CrispConfig(
            websiteID: 'id',
            localMessages: const [CrispTextContent('')],
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(fakePlatform.shownMessages, isEmpty);
    });

    test('are shown once, and again after a session reset', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
      const welcome = CrispTextContent('Welcome!');
      final localConfig = CrispConfig(
        websiteID: 'id',
        localMessages: const [welcome],
      );

      // Start from a clean state regardless of earlier tests.
      await FlutterCrispChat.resetCrispChatSession();

      await FlutterCrispChat.openCrispChat(config: localConfig);
      expect(fakePlatform.shownMessages, equals([welcome]));

      await FlutterCrispChat.openCrispChat(config: localConfig);
      expect(fakePlatform.shownMessages, equals([welcome]));

      await FlutterCrispChat.resetCrispChatSession();
      await FlutterCrispChat.openCrispChat(config: localConfig);
      expect(fakePlatform.shownMessages, equals([welcome, welcome]));
    });
  });

  group('CrispMessageContent.toJson', () {
    test('serializes a picker with its choices', () {
      const picker = CrispPickerContent(
        id: 'plan',
        text: 'Pick a plan',
        required: true,
        choices: [
          CrispPickerChoice(value: 'pro', label: 'Pro', icon: '🚀'),
        ],
      );
      expect(
        picker.toJson(),
        equals({
          'type': 'picker',
          'id': 'plan',
          'text': 'Pick a plan',
          'choices': [
            {'value': 'pro', 'label': 'Pro', 'selected': false, 'icon': '🚀'},
          ],
          'required': true,
        }),
      );
    });

    test('serializes a carousel with targets and actions', () {
      const carousel = CrispCarouselContent(
        text: 'Our products',
        targets: [
          CrispCarouselTarget(
            title: 'Pro',
            description: 'For teams',
            actions: [
              CrispCarouselAction(label: 'Open', url: 'https://example.com'),
            ],
          ),
        ],
      );
      expect(
        carousel.toJson(),
        equals({
          'type': 'carousel',
          'text': 'Our products',
          'targets': [
            {
              'title': 'Pro',
              'description': 'For teams',
              'image': null,
              'actions': [
                {'label': 'Open', 'url': 'https://example.com'},
              ],
            },
          ],
        }),
      );
    });
  });

  group('openHelpdesk', () {
    test('calls platform method with correct websiteId', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;
      await FlutterCrispChat.openHelpdesk(websiteId: 'test-website-id');
      expect(fakePlatform.openHelpdeskCalled, isTrue);
      expect(fakePlatform.openHelpdeskArgs,
          equals({'websiteId': 'test-website-id'}));
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
        equals({
          'websiteId': 'test-website-id',
          'locale': 'en',
          'slug': 'my-article'
        }),
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

  group('openCrispChat session identifier caching', () {
    test('returns without waiting for the session to load', () {
      fakeAsync((async) {
        final fakePlatform = MockFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;

        var returned = false;
        FlutterCrispChat.openCrispChat(config: config)
            .then((_) => returned = true);
        async.flushMicrotasks();

        expect(returned, isTrue);
        async.elapse(const Duration(seconds: 10));
      });
    });

    test('caches the identifier from the sessionLoaded event', () {
      fakeAsync((async) {
        final fakePlatform = MockFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;
        FlutterCrispChat.resetCrispChatSession();

        FlutterCrispChat.openCrispChat(config: config);
        async.flushMicrotasks();
        expect(fakePlatform.eventStreamController.hasListener, isTrue);

        fakePlatform.eventStreamController.add(CrispChatEvent.fromMap(
          {'type': 'sessionLoaded', 'sessionId': 'session_from_event'},
        ));
        async.flushMicrotasks();

        // The listener is cancelled and the platform was never queried.
        expect(fakePlatform.eventStreamController.hasListener, isFalse);
        expect(fakePlatform.getSessionIdentifierCalls, 0);

        String? sessionId;
        FlutterCrispChat.getSessionIdentifier().then((id) => sessionId = id);
        async.flushMicrotasks();
        expect(sessionId, 'session_from_event');
      });
    });

    test('queries the platform when no sessionLoaded event arrives', () {
      fakeAsync((async) {
        final fakePlatform = MockFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;
        FlutterCrispChat.resetCrispChatSession();
        fakePlatform.mockSessionId = 'queried_session';

        FlutterCrispChat.openCrispChat(config: config);
        async.elapse(const Duration(seconds: 9));
        expect(fakePlatform.getSessionIdentifierCalls, 0);

        async.elapse(const Duration(seconds: 1));
        expect(fakePlatform.getSessionIdentifierCalls, 1);
        expect(fakePlatform.eventStreamController.hasListener, isFalse);

        // The cached value is returned when the platform has none.
        fakePlatform.mockSessionId = null;
        String? sessionId;
        FlutterCrispChat.getSessionIdentifier().then((id) => sessionId = id);
        async.flushMicrotasks();
        expect(sessionId, 'queried_session');
      });
    });

    test('queries after 3 seconds on platforms without events', () {
      fakeAsync((async) {
        final fakePlatform = NoEventsFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;
        FlutterCrispChat.resetCrispChatSession();

        FlutterCrispChat.openCrispChat(config: config);
        async.elapse(const Duration(milliseconds: 2900));
        expect(fakePlatform.getSessionIdentifierCalls, 0);

        async.elapse(const Duration(milliseconds: 100));
        expect(fakePlatform.getSessionIdentifierCalls, 1);
      });
    });

    test('drops the identifier if the session was reset meanwhile', () {
      fakeAsync((async) {
        final fakePlatform = MockFlutterCrispChatPlatform();
        FlutterCrispChatPlatform.instance = fakePlatform;
        FlutterCrispChat.resetCrispChatSession();
        fakePlatform.mockSessionId = 'old_session';

        FlutterCrispChat.openCrispChat(config: config);
        async.flushMicrotasks();
        FlutterCrispChat.resetCrispChatSession();
        async.elapse(const Duration(seconds: 10));
        expect(fakePlatform.getSessionIdentifierCalls, 1);

        fakePlatform.mockSessionId = null;
        String? sessionId = 'not set';
        FlutterCrispChat.getSessionIdentifier().then((id) => sessionId = id);
        async.flushMicrotasks();
        expect(sessionId, isNull);
      });
    });

    test('stops listening when opening the chat fails', () {
      fakeAsync((async) {
        final fakePlatform = MockFlutterCrispChatPlatform()
          ..openCrispChatShouldThrowError = true;
        FlutterCrispChatPlatform.instance = fakePlatform;

        Object? error;
        FlutterCrispChat.openCrispChat(config: config)
            .catchError((Object e) => error = e);
        async.flushMicrotasks();

        expect(error, isA<PlatformException>());
        expect(fakePlatform.eventStreamController.hasListener, isFalse);
        async.elapse(const Duration(seconds: 10));
        expect(fakePlatform.getSessionIdentifierCalls, 0);
      });
    });
  });

  group('onCrispEvent', () {
    test('forwards events from the platform implementation', () async {
      final fakePlatform = MockFlutterCrispChatPlatform();
      FlutterCrispChatPlatform.instance = fakePlatform;

      final events = <CrispChatEvent>[];
      final subscription = FlutterCrispChat.onCrispEvent.listen(events.add);

      fakePlatform.eventStreamController.add(
        CrispChatEvent.fromMap({'type': 'chatOpened'}),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.single.type, CrispEventType.chatOpened);

      await subscription.cancel();
    });
  });
}
