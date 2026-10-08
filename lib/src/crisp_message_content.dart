/// Content of a local message shown with [FlutterCrispChat.showMessage] or
/// [CrispConfig.localMessages].
///
/// A local message is displayed **as an operator** in the visitor's chatbox
/// only. It is never sent to your Crisp inbox, so operators don't see it.
///
/// Wraps `Crisp.showMessage(Content)` (Android),
/// `CrispSDK.showMessage(with:)` (iOS), and
/// `$crisp.push(["do", "message:show", [type, content]])` (Web/desktop).
///
/// {@category Local Messages}
sealed class CrispMessageContent {
  const CrispMessageContent();

  /// The Crisp message type (`text`, `file`, `animation`, `audio`, `picker`,
  /// `field` or `carousel`).
  String get type;

  /// Serializes this content for the native method channel.
  Map<String, dynamic> toJson();
}

/// A plain text message.
///
/// {@category Local Messages}
class CrispTextContent extends CrispMessageContent {
  /// The message text. Must not be empty.
  final String text;

  /// Creates a text message.
  const CrispTextContent(this.text);

  @override
  String get type => 'text';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};
}

/// A file attachment (e.g. a PDF).
///
/// {@category Local Messages}
class CrispFileContent extends CrispMessageContent {
  /// The file name shown in the chatbox.
  final String name;

  /// The public URL of the file.
  final String url;

  /// The MIME type of the file (e.g. `application/pdf`).
  final String mimeType;

  /// Creates a file message.
  const CrispFileContent({
    required this.name,
    required this.url,
    required this.mimeType,
  });

  @override
  String get type => 'file';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'url': url,
        'mimeType': mimeType,
      };
}

/// An animated image (e.g. a GIF).
///
/// {@category Local Messages}
class CrispAnimationContent extends CrispMessageContent {
  /// The public URL of the animation.
  final String url;

  /// The MIME type of the animation. Defaults to `image/gif`.
  final String mimeType;

  /// Creates an animation message.
  const CrispAnimationContent({
    required this.url,
    this.mimeType = 'image/gif',
  });

  @override
  String get type => 'animation';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        'mimeType': mimeType,
      };
}

/// An audio clip.
///
/// {@category Local Messages}
class CrispAudioContent extends CrispMessageContent {
  /// The public URL of the audio file.
  final String url;

  /// The MIME type of the audio file (e.g. `audio/mpeg`).
  final String mimeType;

  /// The duration of the clip, in seconds.
  final int duration;

  /// Creates an audio message.
  const CrispAudioContent({
    required this.url,
    required this.mimeType,
    required this.duration,
  });

  @override
  String get type => 'audio';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        'mimeType': mimeType,
        'duration': duration,
      };
}

/// A text input the visitor can fill in (e.g. asking for an email).
///
/// {@category Local Messages}
class CrispFieldContent extends CrispMessageContent {
  /// A unique identifier for this field.
  final String id;

  /// The question shown above the input.
  final String text;

  /// The input placeholder / explanation.
  final String explain;

  /// An optional pre-filled value.
  final String? value;

  /// Whether the visitor must fill the field. Android and Web only — ignored
  /// on iOS.
  final bool required;

  /// Creates a field message.
  const CrispFieldContent({
    required this.id,
    required this.text,
    required this.explain,
    this.value,
    this.required = false,
  });

  @override
  String get type => 'field';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'text': text,
        'explain': explain,
        'value': value,
        'required': required,
      };
}

/// A single choice of a [CrispPickerContent].
///
/// {@category Local Messages}
class CrispPickerChoice {
  /// The value reported when this choice is picked.
  final String value;

  /// The label shown to the visitor.
  final String label;

  /// Whether this choice is pre-selected.
  final bool selected;

  /// An optional emoji icon shown before the label.
  final String? icon;

  /// Creates a picker choice.
  const CrispPickerChoice({
    required this.value,
    required this.label,
    this.selected = false,
    this.icon,
  });

  /// Serializes this choice for the native method channel.
  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        'selected': selected,
        'icon': icon,
      };
}

/// A list of choices the visitor can pick from.
///
/// {@category Local Messages}
class CrispPickerContent extends CrispMessageContent {
  /// A unique identifier for this picker.
  final String id;

  /// The question shown above the choices.
  final String text;

  /// The choices. Must not be empty.
  final List<CrispPickerChoice> choices;

  /// Whether the visitor must pick a choice. Android and Web only — ignored
  /// on iOS.
  final bool required;

  /// Creates a picker message.
  const CrispPickerContent({
    required this.id,
    required this.text,
    required this.choices,
    this.required = false,
  });

  @override
  String get type => 'picker';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'text': text,
        'choices': choices.map((c) => c.toJson()).toList(),
        'required': required,
      };
}

/// A link button on a [CrispCarouselTarget].
///
/// {@category Local Messages}
class CrispCarouselAction {
  /// The button label.
  final String label;

  /// The URL opened when the button is tapped.
  final String url;

  /// Creates a carousel action.
  const CrispCarouselAction({required this.label, required this.url});

  /// Serializes this action for the native method channel.
  Map<String, dynamic> toJson() => {'label': label, 'url': url};
}

/// A single card of a [CrispCarouselContent].
///
/// {@category Local Messages}
class CrispCarouselTarget {
  /// The card title.
  final String title;

  /// The card description.
  final String description;

  /// An optional image URL shown on the card.
  final String? image;

  /// The link buttons shown on the card.
  final List<CrispCarouselAction> actions;

  /// Creates a carousel card.
  const CrispCarouselTarget({
    required this.title,
    required this.description,
    this.image,
    this.actions = const [],
  });

  /// Serializes this card for the native method channel.
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'image': image,
        'actions': actions.map((a) => a.toJson()).toList(),
      };
}

/// A horizontally scrolling list of cards.
///
/// {@category Local Messages}
class CrispCarouselContent extends CrispMessageContent {
  /// The text shown above the cards.
  final String text;

  /// The cards. Must not be empty.
  final List<CrispCarouselTarget> targets;

  /// Creates a carousel message.
  const CrispCarouselContent({required this.text, required this.targets});

  @override
  String get type => 'carousel';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'text': text,
        'targets': targets.map((t) => t.toJson()).toList(),
      };
}
