import 'package:flutter/material.dart';
import 'package:flutter_crisp_chat_example/src/app.dart';
import 'package:flutter_crisp_chat_example/src/demo_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<DemoController> pumpApp(
    WidgetTester tester, {
    String websiteId = '',
    Size size = const Size(400, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = DemoController(websiteId: websiteId);
    addTearDown(controller.dispose);
    await tester.pumpWidget(CrispExampleApp(controller: controller));
    return controller;
  }

  testWidgets('shows the home page with the open chat button', (tester) async {
    await pumpApp(tester, websiteId: 'test-website');

    expect(find.text('Crisp Chat'), findsOneWidget);
    expect(find.text('How can we help?'), findsOneWidget);
    expect(find.text('Open chat'), findsOneWidget);
    expect(find.text('Add your website ID'), findsNothing);
  });

  testWidgets('asks for a website ID when none is set', (tester) async {
    await pumpApp(tester);

    expect(find.text('Add your website ID'), findsOneWidget);
  });

  testWidgets('opening the chat without a website ID logs an error',
      (tester) async {
    final controller = await pumpApp(tester);

    await tester.tap(find.text('Open chat'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No website ID'), findsOneWidget);
    expect(controller.activity.first.kind, ActivityKind.error);
    expect(controller.activity.first.title, 'Open chat');
  });

  testWidgets('switches between tabs with the navigation bar', (tester) async {
    await pumpApp(tester, websiteId: 'test-website');

    for (final (tab, content) in [
      ('Identity', 'Jane Cooper'),
      ('Session', 'Current session'),
      ('Messages', 'Welcome messages'),
      ('Activity', 'Nothing yet'),
    ]) {
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(tab),
      ));
      await tester.pumpAndSettle();
      expect(find.text(content), findsOneWidget, reason: tab);
    }
  });

  testWidgets('uses a navigation rail on wide screens', (tester) async {
    await pumpApp(tester, size: const Size(1200, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('builds the CrispConfig from the chosen options', (tester) async {
    final controller = await pumpApp(tester, websiteId: ' test-website ');

    var config = controller.buildConfig();
    expect(config.websiteID, 'test-website');
    expect(config.tokenId, isNull);
    expect(config.user, isNull);
    expect(config.localMessages, isNotEmpty);

    controller.updateOptions(() => controller.welcomeMessages = false);
    config = controller.buildConfig(segment: 'orders');
    expect(config.localMessages, isNull);
    expect(config.sessionSegment, 'orders');
  });
}
