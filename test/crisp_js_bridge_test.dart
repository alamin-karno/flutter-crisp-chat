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
    final wrapped =
        CrispJsBridge.forDesktopEvaluation(r'$crisp.push(["do","chat:open"]);');
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

  test(r'openHelpdeskSearch produces correct crisp command', () {
    final script = CrispJsBridge.openHelpdeskSearch();
    expect(script, equals(r'$crisp.push(["do", "helpdesk:search"]);'));
  });

  test('openHelpdeskArticle with only required args', () {
    final script = CrispJsBridge.openHelpdeskArticle(
      locale: 'en',
      slug: 'getting-started',
    );
    expect(script, contains('"helpdesk:article:open"'));
    expect(script, contains('"en"'));
    expect(script, contains('"getting-started"'));
    // No title or category — array should have exactly 2 elements
    expect(script, contains('["en","getting-started"]'));
  });

  test('openHelpdeskArticle with title but no category', () {
    final script = CrispJsBridge.openHelpdeskArticle(
      locale: 'fr',
      slug: 'faq',
      title: 'Questions fréquentes',
    );
    expect(script, contains('"fr"'));
    expect(script, contains('"faq"'));
    expect(script, contains('"Questions fréquentes"'));
    // title present, category absent — array has 3 elements with string title
    expect(script, contains('["fr","faq","Questions fréquentes"]'));
  });

  test(
      'openHelpdeskArticle with category but no title inserts null placeholder',
      () {
    final script = CrispJsBridge.openHelpdeskArticle(
      locale: 'de',
      slug: 'setup',
      category: 'General',
    );
    expect(script, contains('"de"'));
    expect(script, contains('"setup"'));
    // Crisp positional API requires null title when category is set
    expect(script, contains('["de","setup",null,"General"]'));
  });

  test('openHelpdeskArticle with title and category', () {
    final script = CrispJsBridge.openHelpdeskArticle(
      locale: 'en',
      slug: 'billing',
      title: 'Billing FAQ',
      category: 'Billing',
    );
    expect(script, contains('["en","billing","Billing FAQ","Billing"]'));
  });
}
