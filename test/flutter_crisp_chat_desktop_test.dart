import 'package:crisp_chat/src/flutter_crisp_chat_desktop.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resetCrispChatSession returns at once when no chat window is open', () {
    fakeAsync((async) {
      var done = false;
      DesktopFlutterCrispChat()
          .resetCrispChatSession()
          .then((_) => done = true);
      // Before the fix it waited about 10 seconds for a window.
      async.flushMicrotasks();
      expect(done, isTrue);
      expect(async.pendingTimers, isEmpty);
    });
  });
}
