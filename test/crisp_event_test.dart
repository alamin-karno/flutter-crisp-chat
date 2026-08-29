import 'package:crisp_chat/src/crisp_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrispChatEvent.fromMap', () {
    test('parses sessionLoaded', () {
      final event = CrispChatEvent.fromMap({
        'type': 'sessionLoaded',
        'sessionId': 'session-123',
      });

      expect(event.type, CrispEventType.sessionLoaded);
      expect(event.sessionId, 'session-123');
      expect(event.message, isNull);
      expect(event.notificationData, isNull);
    });

    test('parses chatOpened', () {
      final event = CrispChatEvent.fromMap({'type': 'chatOpened'});
      expect(event.type, CrispEventType.chatOpened);
    });

    test('parses chatClosed', () {
      final event = CrispChatEvent.fromMap({'type': 'chatClosed'});
      expect(event.type, CrispEventType.chatClosed);
    });

    test('parses notificationReceived (Android-only)', () {
      final event = CrispChatEvent.fromMap({
        'type': 'notificationReceived',
        'notificationData': {'title': 'Hello', 'body': 'World'},
      });

      expect(event.type, CrispEventType.notificationReceived);
      expect(event.notificationData, equals({'title': 'Hello', 'body': 'World'}));
    });

    test('parses messageReceived with a text message', () {
      final event = CrispChatEvent.fromMap({
        'type': 'messageReceived',
        'message': {
          'isMe': false,
          'from': 'operator',
          'origin': 'chat',
          'timestamp': 1700000000000,
          'fingerprint': 42,
          'contentType': 'text',
          'text': 'Hello there',
        },
      });

      expect(event.type, CrispEventType.messageReceived);
      final message = event.message;
      expect(message, isNotNull);
      expect(message!.isMe, isFalse);
      expect(message.from, CrispMessageSender.operatorUser);
      expect(message.origin, 'chat');
      expect(message.timestamp, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(message.fingerprint, 42);
      expect(message.contentType, CrispMessageContentType.text);
      expect(message.text, 'Hello there');
    });

    test('parses messageSent from the visitor', () {
      final event = CrispChatEvent.fromMap({
        'type': 'messageSent',
        'message': {
          'isMe': true,
          'from': 'user',
          'origin': 'local',
          'timestamp': 1700000000000,
          'fingerprint': 7,
          'contentType': 'text',
          'text': 'Hi!',
        },
      });

      expect(event.type, CrispEventType.messageSent);
      expect(event.message!.isMe, isTrue);
      expect(event.message!.from, CrispMessageSender.user);
    });

    test('non-text content types have a null text field', () {
      final event = CrispChatEvent.fromMap({
        'type': 'messageReceived',
        'message': {
          'isMe': false,
          'from': 'operator',
          'origin': 'chat',
          'timestamp': 1700000000000,
          'fingerprint': 1,
          'contentType': 'carousel',
          'text': null,
        },
      });

      expect(event.message!.contentType, CrispMessageContentType.carousel);
      expect(event.message!.text, isNull);
    });

    test('unrecognized contentType maps to unknown', () {
      final event = CrispChatEvent.fromMap({
        'type': 'messageReceived',
        'message': {
          'isMe': false,
          'from': 'operator',
          'origin': 'chat',
          'timestamp': 1700000000000,
          'fingerprint': 1,
          'contentType': 'textWithAttachment',
          'text': 'ignored on this platform mapping',
        },
      });

      // Only Android/iOS native code is responsible for normalizing
      // platform-specific content types before they reach Dart; an
      // unrecognized string here should degrade to `unknown`, not throw.
      expect(event.message!.contentType, CrispMessageContentType.unknown);
    });

    test('throws ArgumentError for an unrecognized event type', () {
      expect(
        () => CrispChatEvent.fromMap({'type': 'somethingElse'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('missing optional fields default sensibly', () {
      final event = CrispChatEvent.fromMap({'type': 'sessionLoaded'});
      expect(event.sessionId, isNull);
    });
  });
}
