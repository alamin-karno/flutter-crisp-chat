import 'dart:async';

import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter/widgets.dart';

import 'platform_support.dart';
import 'sample_data.dart';

/// What kind of row an [ActivityEntry] is, used to pick its icon and color.
enum ActivityKind { success, error, event, info }

/// One row of the Activity tab: an action the example ran, its result, or a
/// native event from [FlutterCrispChat.onCrispEvent].
class ActivityEntry {
  ActivityEntry(this.kind, this.title, [this.detail]) : time = DateTime.now();

  final ActivityKind kind;
  final String title;
  final String? detail;
  final DateTime time;
}

/// Holds the example's state and wraps every `crisp_chat` call it makes.
///
/// Each public method maps to one feature of the plugin, so this file doubles
/// as a cookbook: search it for the `FlutterCrispChat` method you need.
class DemoController extends ChangeNotifier {
  DemoController({
    required String websiteId,
    String identifier = '',
    String apiKey = '',
  })  : websiteId = websiteId.trim(),
        identifier = identifier.trim(),
        apiKey = apiKey.trim();

  /// From `--dart-define=websiteId=...`.
  final String websiteId;

  /// REST API credentials from a Crisp Marketplace plugin token, used only by
  /// the unread-count and mark-as-read actions.
  final String identifier;
  final String apiKey;

  bool get hasWebsiteId => websiteId.isNotEmpty;
  bool get hasRestCredentials => identifier.isNotEmpty && apiKey.isNotEmpty;

  // ---------------------------------------------------------------------------
  // State shown in the UI
  // ---------------------------------------------------------------------------

  /// The signed-in demo user, or `null` while browsing as a guest.
  DemoUser? get currentUser => _currentUser;
  DemoUser? _currentUser;

  /// Chat options applied by [buildConfig] on the next open.
  CrispColorMode? colorMode;
  String? locale;
  ModalPresentationStyle modalStyle = ModalPresentationStyle.fullScreen;
  bool welcomeMessages = true;

  int? unreadCount;
  String? sessionId;
  bool? sessionOngoing;
  bool? videoCallsSupported;

  /// Newest first.
  List<ActivityEntry> get activity => List.unmodifiable(_activity);
  final List<ActivityEntry> _activity = [];

  StreamSubscription<CrispChatEvent>? _events;

  // ---------------------------------------------------------------------------
  // Start-up
  // ---------------------------------------------------------------------------

  /// Wires up the parts of the plugin that should run once, at start-up.
  /// Called from `main()` rather than from a widget so tests can skip it.
  Future<void> start() async {
    // Native SDK events (Android and iOS only): session loaded, chat
    // opened/closed, messages sent/received, Android notification received.
    _events = FlutterCrispChat.onCrispEvent.listen(_onCrispEvent);

    // Background → foreground: a Crisp notification was tapped while the
    // app was still running.
    FlutterCrispChat.setOnNotificationTappedCallback(() {
      _log(ActivityKind.event, 'Notification tapped');
      FlutterCrispChat.openChatboxFromNotification();
    });

    // Terminated → launched: open the chat if a Crisp notification
    // launched the app.
    try {
      final opened = await FlutterCrispChat.openChatboxFromNotification();
      if (opened) _log(ActivityKind.event, 'Opened from a notification');
    } catch (e) {
      _log(ActivityKind.error, 'openChatboxFromNotification failed', '$e');
    }

    try {
      videoCallsSupported = await FlutterCrispChat.isVideoCallsSupported();
    } catch (_) {
      videoCallsSupported = null;
    }

    _log(ActivityKind.info, 'Example started');
  }

  void _onCrispEvent(CrispChatEvent event) {
    final detail = switch (event.type) {
      CrispEventType.sessionLoaded => event.sessionId,
      CrispEventType.messageSent ||
      CrispEventType.messageReceived =>
        event.message?.text ?? event.message?.contentType.name,
      CrispEventType.notificationReceived => event.notificationData?.toString(),
      _ => null,
    };
    if (event.type == CrispEventType.sessionLoaded) {
      sessionId = event.sessionId ?? sessionId;
    }
    if (event.type == CrispEventType.messageReceived) {
      unreadCount = (unreadCount ?? 0) + 1;
    }
    _log(ActivityKind.event, event.type.name, detail);
  }

  @override
  void dispose() {
    _events?.cancel();
    FlutterCrispChat.setOnNotificationTappedCallback(null);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  /// Builds the [CrispConfig] passed to [FlutterCrispChat.openCrispChat] from
  /// the options picked in the UI.
  CrispConfig buildConfig({String? segment}) {
    final user = _currentUser;
    return CrispConfig(
      websiteID: websiteId,
      tokenId: user?.id,
      sessionSegment: segment ?? user?.plan,
      user: user?.toCrispUser(),
      colorMode: colorMode,
      locale: locale,
      modalPresentationStyle: modalStyle,
      // Shown as operator messages the first time the chat opens (and again
      // after a reset). They are never sent to your Crisp inbox.
      localMessages: welcomeMessages ? welcomeMessagesFor(user) : null,
    );
  }

  void updateOptions(VoidCallback change) {
    change();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------------

  Future<String> openChat({String? segment}) async {
    _requireWebsiteId();
    await FlutterCrispChat.openCrispChat(config: buildConfig(segment: segment));
    unreadCount = 0;
    return 'Chat opened';
  }

  Future<String> openHelpdesk() async {
    _requireWebsiteId();
    await FlutterCrispChat.openHelpdesk(websiteId: websiteId);
    return 'Helpdesk opened';
  }

  Future<String> openHelpdeskArticle({
    required String locale,
    required String slug,
  }) async {
    _requireWebsiteId();
    await FlutterCrispChat.openHelpdeskArticle(
      websiteId: websiteId,
      locale: locale,
      slug: slug,
    );
    return 'Opened article "$slug"';
  }

  /// Opens the chat, then shows [content] as a local operator message.
  Future<String> showLocalMessage(CrispMessageContent content) async {
    await openChat();
    await FlutterCrispChat.showMessage(content);
    return 'Showed a ${content.type} message';
  }

  // ---------------------------------------------------------------------------
  // Identity: the login / logout sequence Crisp recommends
  // ---------------------------------------------------------------------------

  Future<String> logIn(DemoUser user) async {
    _requireWebsiteId();
    await FlutterCrispChat.configure(websiteId: websiteId);
    // The token ties the conversation to your user, so it comes back on
    // other devices and after a logout.
    await FlutterCrispChat.setTokenId(user.id);
    // A new token only takes effect after a reset.
    await FlutterCrispChat.resetCrispChatSession();
    // Apply the profile now, without opening the chat.
    await FlutterCrispChat.setUserEmail(user.email);
    await FlutterCrispChat.setUserNickname(user.nickname);
    await FlutterCrispChat.setUserPhone(user.phone);
    await FlutterCrispChat.setUserAvatar(user.avatar);
    _currentUser = user;
    _clearSessionState();
    return 'Signed in as ${user.nickname}';
  }

  Future<String> logOut() async {
    // Clear the token first, then reset, so the next visitor starts a new
    // conversation instead of seeing the previous user's.
    await FlutterCrispChat.setTokenId(null);
    await FlutterCrispChat.resetCrispChatSession();
    final name = _currentUser?.nickname ?? 'guest';
    _currentUser = null;
    _clearSessionState();
    return 'Signed out $name';
  }

  Future<String> setEmail(String email) async {
    await FlutterCrispChat.setUserEmail(email.trim());
    return 'Email set to ${email.trim()}';
  }

  Future<String> setNickname(String nickname) async {
    await FlutterCrispChat.setUserNickname(nickname.trim());
    return 'Nickname set to ${nickname.trim()}';
  }

  Future<String> setPhone(String phone) async {
    await FlutterCrispChat.setUserPhone(phone.trim());
    return 'Phone set to ${phone.trim()}';
  }

  Future<String> setAvatar(String url) async {
    await FlutterCrispChat.setUserAvatar(url.trim());
    return 'Avatar updated';
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  Future<String> refreshSessionId() async {
    sessionId = await FlutterCrispChat.getSessionIdentifier();
    return sessionId == null
        ? 'No session yet. Open the chat first.'
        : 'Session $sessionId';
  }

  Future<String> checkSessionOngoing() async {
    sessionOngoing = await FlutterCrispChat.isSessionOngoing();
    return switch (sessionOngoing) {
      true => 'The session has messages',
      false => 'No messages in this session yet',
      null => "Can't tell on this platform, or the session hasn't loaded",
    };
  }

  Future<String> setSessionString(String key, String value) async {
    FlutterCrispChat.setSessionString(key: key.trim(), value: value);
    return 'Saved $key = "$value"';
  }

  Future<String> setSessionInt(String key, int value) async {
    FlutterCrispChat.setSessionInt(key: key.trim(), value: value);
    return 'Saved $key = $value';
  }

  Future<String> setSegments(List<String> segments, {bool overwrite = false}) {
    FlutterCrispChat.setSessionSegments(
      segments: segments,
      overwrite: overwrite,
    );
    return Future.value(
      '${overwrite ? 'Replaced' : 'Added'} segments: ${segments.join(', ')}',
    );
  }

  Future<String> pushEvent(String name, SessionEventColor color) async {
    await FlutterCrispChat.pushSessionEvent(name: name.trim(), color: color);
    return 'Pushed event "${name.trim()}"';
  }

  Future<String> runBotScenario(String scenarioId) async {
    await FlutterCrispChat.runBotScenario(scenarioId: scenarioId.trim());
    return 'Started scenario "${scenarioId.trim()}"';
  }

  Future<String> resetSession() async {
    await FlutterCrispChat.resetCrispChatSession();
    _clearSessionState();
    return 'Session reset';
  }

  // ---------------------------------------------------------------------------
  // Unread messages (REST API)
  // ---------------------------------------------------------------------------

  Future<String> fetchUnreadCount() async {
    _requireRestCredentials();
    final count = await FlutterCrispChat.getUnreadMessageCount(
      websiteId: websiteId,
      identifier: identifier,
      key: apiKey,
    );
    if (count == null) {
      return 'No session found. Open the chat and send a message first.';
    }
    unreadCount = count;
    return count == 0 ? 'No unread messages' : '$count unread';
  }

  Future<String> markAsRead() async {
    _requireRestCredentials();
    final ok = await FlutterCrispChat.markMessagesAsRead(
      websiteId: websiteId,
      identifier: identifier,
      key: apiKey,
    );
    if (ok == true) unreadCount = 0;
    return switch (ok) {
      true => 'Marked all messages as read',
      false => 'The Crisp API rejected the request',
      null => 'No session found. Open the chat first.',
    };
  }

  // ---------------------------------------------------------------------------
  // Scenarios: several calls combined the way a real app would
  // ---------------------------------------------------------------------------

  /// A customer needs help with an order: attach the order to the session
  /// so the operator sees it, then ask for details.
  Future<String> orderSupportScenario() async {
    _requireWebsiteId();
    FlutterCrispChat.setSessionString(key: 'order_id', value: '10234');
    FlutterCrispChat.setSessionInt(key: 'order_total_cents', value: 4999);
    FlutterCrispChat.setSessionSegments(segments: ['orders']);
    await FlutterCrispChat.pushSessionEvent(
      name: 'Opened help for order #10234',
      color: SessionEventColor.blue,
    );
    await openChat(segment: 'orders');
    await FlutterCrispChat.showMessage(
      const CrispTextContent(
        "I can see order **#10234**. What's wrong with it?",
      ),
    );
    return 'Order support chat opened';
  }

  /// A user reports a bug: record app details and ask how serious it is.
  Future<String> bugReportScenario() async {
    _requireWebsiteId();
    FlutterCrispChat.setSessionString(key: 'app_version', value: '1.0.0+1');
    FlutterCrispChat.setSessionString(key: 'platform', value: _platformName);
    FlutterCrispChat.setSessionSegments(segments: ['bug-report']);
    await FlutterCrispChat.pushSessionEvent(
      name: 'Bug report started',
      color: SessionEventColor.red,
    );
    await openChat(segment: 'bug-report');
    await FlutterCrispChat.showMessage(
      const CrispPickerContent(
        id: 'severity',
        text: 'Sorry about that! How bad is it?',
        choices: [
          CrispPickerChoice(value: 'blocker', label: "I'm blocked", icon: '🛑'),
          CrispPickerChoice(value: 'annoying', label: 'Annoying', icon: '😤'),
          CrispPickerChoice(value: 'minor', label: 'Minor', icon: '🐞'),
        ],
      ),
    );
    return 'Bug report chat opened';
  }

  /// A user taps "Upgrade": tag them for the sales team and collect an email.
  Future<String> salesScenario() async {
    _requireWebsiteId();
    FlutterCrispChat.setSessionSegments(segments: ['sales', 'upgrade-intent']);
    await FlutterCrispChat.pushSessionEvent(
      name: 'Viewed Pro pricing',
      color: SessionEventColor.purple,
    );
    await openChat(segment: 'sales');
    await FlutterCrispChat.showMessage(
      CrispFieldContent(
        id: 'work_email',
        text: 'Happy to help you pick a plan! Where should we send a quote?',
        explain: 'name@company.com',
        value: _currentUser?.email,
        required: true,
      ),
    );
    return 'Sales chat opened';
  }

  /// Start over as a new visitor: the welcome messages show again.
  Future<String> freshStartScenario() async {
    _requireWebsiteId();
    await FlutterCrispChat.resetCrispChatSession();
    _clearSessionState();
    await openChat();
    return 'New session started';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String get _platformName => PlatformSupport.name;

  /// Runs [action], logs it to the Activity tab, and returns the message to
  /// show the user. Errors are caught and returned as messages.
  Future<({bool ok, String message})> run(
    String label,
    Future<String> Function() action,
  ) async {
    try {
      final message = await action();
      _log(ActivityKind.success, label, message);
      return (ok: true, message: message);
    } catch (e) {
      final message = _describeError(e);
      _log(ActivityKind.error, label, message);
      return (ok: false, message: message);
    }
  }

  void clearActivity() {
    _activity.clear();
    notifyListeners();
  }

  void _clearSessionState() {
    sessionId = null;
    sessionOngoing = null;
    unreadCount = null;
  }

  void _log(ActivityKind kind, String title, [String? detail]) {
    _activity.insert(0, ActivityEntry(kind, title, detail));
    if (_activity.length > 200) _activity.removeLast();
    notifyListeners();
  }

  void _requireWebsiteId() {
    if (!hasWebsiteId) {
      throw StateError(
        'No website ID. Run with --dart-define=websiteId=YOUR_WEBSITE_ID',
      );
    }
  }

  void _requireRestCredentials() {
    _requireWebsiteId();
    if (!hasRestCredentials) {
      throw StateError(
        'Needs identifier and crispApiKey. '
        'Run with --dart-define-from-file=config.json',
      );
    }
  }

  static String _describeError(Object e) => switch (e) {
        ArgumentError(:final message) => '$message',
        StateError(:final message) => message,
        _ => '$e',
      };
}

/// Makes the [DemoController] available to every page.
class DemoScope extends InheritedNotifier<DemoController> {
  const DemoScope({
    super.key,
    required DemoController controller,
    required super.child,
  }) : super(notifier: controller);

  static DemoController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DemoScope>()!.notifier!;

  /// Reads the controller without rebuilding when it changes. Use it in
  /// callbacks.
  static DemoController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DemoScope>()!.notifier!;
}
