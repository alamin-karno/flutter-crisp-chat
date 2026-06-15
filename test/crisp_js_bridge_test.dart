import 'package:crisp_chat/crisp_chat.dart';
import 'package:crisp_chat/src/crisp_js_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bootstrapScript sets website and token', () {
    final script = CrispJsBridge.bootstrapScript(
      websiteId: 'site-id',
      tokenId: 'user-token',
    );
    expect(script, contains('CRISP_WEBSITE_ID'));
    expect(script, contains('site-id'));
    expect(script, contains('CRISP_TOKEN_ID'));
    expect(script, contains('user-token'));
  });

  test('applyConfigAndOpenChat includes user email and chat open', () {
    final config = CrispConfig(
      websiteID: 'site-id',
      user: User(email: 'a@b.com', nickName: 'Ada'),
    );
    final script = CrispJsBridge.applyConfigAndOpenChat(config);
    expect(script, contains('user:email'));
    expect(script, contains('a@b.com'));
    expect(script, contains('chat:show'));
    expect(script, contains('chat:open'));
  });

  test('forDesktopEvaluation wraps script to return empty string', () {
    final wrapped = CrispJsBridge.forDesktopEvaluation(r'$crisp.push(["do","chat:open"]);');
    expect(wrapped, startsWith('(function(){try{'));
    expect(wrapped, endsWith('})();'));
    expect(wrapped, contains('return "";'));
  });

  test('setSessionString encodes key and value as JSON', () {
    final script = CrispJsBridge.setSessionString(
      key: 'plan',
      value: 'pro',
    );
    expect(script, contains('"plan"'));
    expect(script, contains('"pro"'));
  });

  test('pushSessionEvent uses Crisp triple-nested event array', () {
    final script = CrispJsBridge.pushSessionEvent(
      name: 'test_event',
      color: SessionEventColor.green,
    );
    expect(
      script,
      contains(
        r'$crisp.push(["set","session:event",[[["test_event","green"]]]])',
      ),
    );
    expect(script, isNot(contains('{}')));
  });
}
