/// Represents the kind of native Crisp SDK event delivered through
/// [FlutterCrispChat.onCrispEvent].
///
/// [notificationReceived] is Android-only — the iOS Crisp SDK does not expose
/// a matching callback, so iOS never emits this event type.
///
/// {@category Events}
enum CrispEventType {
  /// A session has finished loading and a session identifier is available.
  sessionLoaded,

  /// The chatbox was opened.
  chatOpened,

  /// The chatbox was closed.
  chatClosed,

  /// A message was sent by the visitor.
  messageSent,

  /// A message was received from an operator (or the visitor, on another device).
  messageReceived,

  /// A push notification was received. Android-only.
  notificationReceived,
}

/// Who sent a [CrispMessage].
///
/// {@category Events}
enum CrispMessageSender {
  /// The visitor (this device's user).
  user,

  /// A support operator.
  operatorUser,
}

/// The kind of content carried by a [CrispMessage].
///
/// [text] is also used for iOS's `textWithAttachment` and
/// `textWithVideoAttachment` cases, since both carry a plain text body.
///
/// {@category Events}
enum CrispMessageContentType {
  text,
  file,
  animation,
  audio,
  picker,
  field,
  carousel,
  unknown,
}

CrispMessageContentType _contentTypeFromString(String? value) {
  switch (value) {
    case 'text':
      return CrispMessageContentType.text;
    case 'file':
      return CrispMessageContentType.file;
    case 'animation':
      return CrispMessageContentType.animation;
    case 'audio':
      return CrispMessageContentType.audio;
    case 'picker':
      return CrispMessageContentType.picker;
    case 'field':
      return CrispMessageContentType.field;
    case 'carousel':
      return CrispMessageContentType.carousel;
    default:
      return CrispMessageContentType.unknown;
  }
}

/// A chat message delivered alongside [CrispEventType.messageSent] or
/// [CrispEventType.messageReceived] events.
///
/// This is a minimal summary, not a full mapping of every native content
/// type (carousel targets, picker choices, file/audio metadata are not
/// included). [text] is only populated when [contentType] is
/// [CrispMessageContentType.text].
///
/// @param origin Raw origin string reported by the native SDK (e.g. `"chat"`,
/// `"local"`, `"network"`, `"update"`). Android reports up to 8 distinct
/// values; iOS reports only 3 — kept as a raw string rather than a strict
/// enum to avoid lossy mapping between platforms.
///
/// {@category Events}
class CrispMessage {
  /// Whether this message was sent by this device's visitor.
  final bool isMe;

  /// Who sent the message.
  final CrispMessageSender from;

  /// Raw origin string reported by the native SDK. See class docs.
  final String? origin;

  /// When the message was sent.
  final DateTime timestamp;

  /// A unique identifier for this message within the session.
  final int fingerprint;

  /// The kind of content carried by this message.
  final CrispMessageContentType contentType;

  /// The message text, only populated when [contentType] is
  /// [CrispMessageContentType.text].
  final String? text;

  CrispMessage({
    required this.isMe,
    required this.from,
    required this.origin,
    required this.timestamp,
    required this.fingerprint,
    required this.contentType,
    required this.text,
  });

  /// Parses a [CrispMessage] from the raw map sent over the method channel.
  ///
  /// @param map The raw message map from native code.
  /// @return A [CrispMessage] built from [map].
  factory CrispMessage.fromMap(Map<dynamic, dynamic> map) {
    return CrispMessage(
      isMe: map['isMe'] as bool? ?? false,
      from: (map['from'] as String?) == 'user'
          ? CrispMessageSender.user
          : CrispMessageSender.operatorUser,
      origin: map['origin'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ?? 0,
      ),
      fingerprint: (map['fingerprint'] as num?)?.toInt() ?? 0,
      contentType: _contentTypeFromString(map['contentType'] as String?),
      text: map['text'] as String?,
    );
  }
}

/// A single native Crisp SDK event delivered through
/// [FlutterCrispChat.onCrispEvent].
///
/// Only the fields relevant to [type] are populated — see each field's docs.
///
/// {@category Events}
class CrispChatEvent {
  /// The kind of event.
  final CrispEventType type;

  /// The session identifier. Only set when [type] is
  /// [CrispEventType.sessionLoaded].
  final String? sessionId;

  /// The message that was sent or received. Only set when [type] is
  /// [CrispEventType.messageSent] or [CrispEventType.messageReceived].
  final CrispMessage? message;

  /// The raw notification payload. Only set when [type] is
  /// [CrispEventType.notificationReceived] (Android-only).
  final Map<String, String>? notificationData;

  CrispChatEvent._({
    required this.type,
    this.sessionId,
    this.message,
    this.notificationData,
  });

  /// Parses a [CrispChatEvent] from the raw map sent over the method channel.
  ///
  /// @param map The raw event map from native code, keyed by `"type"`.
  /// @return A [CrispChatEvent] built from [map].
  /// @throws ArgumentError if `map["type"]` is not a recognized event type.
  factory CrispChatEvent.fromMap(Map<dynamic, dynamic> map) {
    final typeString = map['type'] as String?;
    final type = CrispEventType.values.firstWhere(
      (value) => value.name == typeString,
      orElse: () => throw ArgumentError.value(
        typeString,
        'type',
        'Unrecognized CrispChatEvent type.',
      ),
    );

    final rawMessage = map['message'] as Map<dynamic, dynamic>?;
    final rawNotificationData = map['notificationData'] as Map<dynamic, dynamic>?;

    return CrispChatEvent._(
      type: type,
      sessionId: map['sessionId'] as String?,
      message: rawMessage != null ? CrispMessage.fromMap(rawMessage) : null,
      notificationData: rawNotificationData?.map(
        (key, value) => MapEntry(key as String, value as String),
      ),
    );
  }
}
