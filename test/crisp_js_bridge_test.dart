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

  test('bootstrapScript sets CRISP_RUNTIME_CONFIG locale when provided', () {
    final script = CrispJsBridge.bootstrapScript(
      websiteId: 'site-id',
      locale: ' pt-br ',
    );
    expect(script, contains('window.CRISP_RUNTIME_CONFIG={locale:"pt-br"};'));
  });

  test('bootstrapScript omits CRISP_RUNTIME_CONFIG for null or blank locale',
      () {
    for (final locale in [null, '', '   ']) {
      final script = CrispJsBridge.bootstrapScript(
        websiteId: 'site-id',
        locale: locale,
      );
      expect(script, isNot(contains('CRISP_RUNTIME_CONFIG')));
    }
  });

  test('embedHtml sets the locale before loading l.js', () {
    final html = CrispJsBridge.embedHtml(
      CrispConfig(websiteID: 'site-id', locale: 'fr'),
    );
    final localeIndex = html.indexOf('CRISP_RUNTIME_CONFIG={locale:"fr"}');
    expect(localeIndex, isNonNegative);
    expect(localeIndex, lessThan(html.indexOf('client.crisp.chat/l.js')));
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

  test('applyConfigAndOpenChat sets the color mode when provided', () {
    final config = CrispConfig(
      websiteID: 'site-id',
      colorMode: CrispColorMode.dark,
    );
    final script = CrispJsBridge.applyConfigAndOpenChat(config);
    expect(
        script, contains(r'$crisp.push(["config", "color:mode", ["dark"]]);'));
  });

  test('queueBeforeLoad sets the color mode when provided', () {
    final config = CrispConfig(
      websiteID: 'site-id',
      colorMode: CrispColorMode.auto,
    );
    final script = CrispJsBridge.queueBeforeLoad(config);
    expect(
        script, contains(r'$crisp.push(["config", "color:mode", ["auto"]]);'));
  });

  test('applyConfigAndOpenChat omits color mode when null', () {
    final script = CrispJsBridge.applyConfigAndOpenChat(
      CrispConfig(websiteID: 'site-id'),
    );
    expect(script, isNot(contains('color:mode')));
  });

  test('isSessionOngoing checks session:ongoing only once a session exists',
      () {
    final script = CrispJsBridge.isSessionOngoing();
    expect(script, startsWith('(function(){try{'));
    expect(script, contains(r'$crisp.is("session:ongoing")'));
    expect(script, contains(r'$crisp.get("session:identifier")'));
    expect(script, contains('return "";'));
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

  test('runBotScenario produces correct crisp command', () {
    final script = CrispJsBridge.runBotScenario(scenarioId: 'scenario_id');
    expect(
      script,
      equals(r'$crisp.push(["do","bot:scenario:run",["scenario_id"]]);'),
    );
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

  group('showMessage', () {
    test('text', () {
      expect(
        CrispJsBridge.showMessage(const CrispTextContent('Can I help?')),
        equals(r'$crisp.push(["do","message:show",["text","Can I help?"]]);'),
      );
    });

    test('file maps mimeType to type', () {
      expect(
        CrispJsBridge.showMessage(const CrispFileContent(
          name: 'Guide.pdf',
          url: 'https://example.com/guide.pdf',
          mimeType: 'application/pdf',
        )),
        equals(
          r'$crisp.push(["do","message:show",["file",{"name":"Guide.pdf","url":"https://example.com/guide.pdf","type":"application/pdf"}]]);',
        ),
      );
    });

    test('animation defaults to image/gif', () {
      expect(
        CrispJsBridge.showMessage(
          const CrispAnimationContent(url: 'https://example.com/a.gif'),
        ),
        equals(
          r'$crisp.push(["do","message:show",["animation",{"url":"https://example.com/a.gif","type":"image/gif"}]]);',
        ),
      );
    });

    test('field omits unset optional keys', () {
      expect(
        CrispJsBridge.showMessage(const CrispFieldContent(
          id: 'email',
          text: 'Your email?',
          explain: 'name@example.com',
        )),
        equals(
          r'$crisp.push(["do","message:show",["field",{"id":"email","text":"Your email?","explain":"name@example.com"}]]);',
        ),
      );
    });

    test('picker includes choices and required flag', () {
      expect(
        CrispJsBridge.showMessage(const CrispPickerContent(
          id: 'plan',
          text: 'Pick a plan',
          required: true,
          choices: [
            CrispPickerChoice(value: 'pro', label: 'Pro', selected: true)
          ],
        )),
        equals(
          r'$crisp.push(["do","message:show",["picker",{"id":"plan","text":"Pick a plan","choices":[{"value":"pro","label":"Pro","selected":true}],"required":true}]]);',
        ),
      );
    });

    test('carousel includes targets and actions', () {
      expect(
        CrispJsBridge.showMessage(const CrispCarouselContent(
          text: 'Our products',
          targets: [
            CrispCarouselTarget(
              title: 'Pro',
              description: 'For teams',
              image: 'https://example.com/pro.png',
              actions: [
                CrispCarouselAction(label: 'Open', url: 'https://example.com'),
              ],
            ),
          ],
        )),
        equals(
          r'$crisp.push(["do","message:show",["carousel",{"text":"Our products","targets":[{"title":"Pro","description":"For teams","image":"https://example.com/pro.png","actions":[{"label":"Open","url":"https://example.com"}]}]}]]);',
        ),
      );
    });
  });

  group('token and user scripts', () {
    test('setTokenId sets or clears CRISP_TOKEN_ID', () {
      expect(CrispJsBridge.setTokenId('user-42'),
          'window.CRISP_TOKEN_ID="user-42";');
      expect(CrispJsBridge.setTokenId(null), 'window.CRISP_TOKEN_ID=null;');
      expect(CrispJsBridge.setTokenId(''), 'window.CRISP_TOKEN_ID=null;');
    });

    test('setUserEmail adds only a valid signature', () {
      final signature = 'a' * 64;
      expect(
        CrispJsBridge.setUserEmail(
            email: 'a@example.com', signature: signature),
        '\$crisp.push(["set", "user:email", ["a@example.com", "$signature"]]);',
      );
      expect(
        CrispJsBridge.setUserEmail(email: 'a@example.com', signature: 'bad'),
        r'$crisp.push(["set", "user:email", ["a@example.com"]]);',
      );
    });

    test('nickname, phone and avatar scripts escape their values', () {
      expect(CrispJsBridge.setUserNickname(nickname: 'A "B"'),
          r'$crisp.push(["set", "user:nickname", ["A \"B\""]]);');
      expect(CrispJsBridge.setUserPhone(phone: '+15550100'),
          r'$crisp.push(["set", "user:phone", ["+15550100"]]);');
      expect(CrispJsBridge.setUserAvatar(avatar: 'https://example.com/a.png'),
          r'$crisp.push(["set", "user:avatar", ["https://example.com/a.png"]]);');
    });
  });
}
