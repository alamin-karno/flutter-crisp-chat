---
head:
  - - meta
    - name: description
      content: Show local operator messages in the Crisp chatbox from Flutter — welcome text, pickers, input fields, carousels, files, GIFs, and audio — on Android, iOS, Web, and desktop.

  - - meta
    - name: keywords
      content: "flutter crisp welcome message, crisp showMessage flutter, crisp local message, crisp message:show flutter, crisp_chat localMessages, crisp picker flutter, crisp carousel flutter"

prev:
  text: 'Chat Events'
  link: '/core_feature/chat_events'

next:
  text: 'Firebase Setup'
  link: '/notifications/firebase_setup'
---

# Local Messages

Show a message **as an operator** in the visitor's chatbox, such as a welcome text, a quick-reply picker or an email field. Local messages are displayed on the device only. They are **never sent to your Crisp inbox**, so your operators don't see them, and they don't create a conversation on their own.

There are two ways to use them:

| API                           | When the message is shown                                                                                             |
|-------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `CrispConfig.localMessages`   | Automatically, the **first time** `openCrispChat` is called in the app's lifetime, and again after `resetCrispChatSession`. |
| `FlutterCrispChat.showMessage` | Immediately, whenever you call it (after the chat is open).                                                         |

## Platform support

| Platform    | Implementation                                              |
|-------------|-------------------------------------------------------------|
| **Android** | Native SDK: `Crisp.showMessage(Content)`                    |
| **iOS**     | Native SDK: `CrispSDK.showMessage(with: Message.Content)`   |
| **Web**     | `$crisp.push(["do", "message:show", [type, content]])`      |
| **Desktop** | Same `$crisp` command in the embedded WebView               |

On desktop, local messages need the embedded WebView. They aren't shown when the plugin falls back to opening Crisp in the system browser.

## Welcome message on first open

Pass `localMessages` to `CrispConfig`. The plugin shows them right after the chatbox opens:

```dart
final config = CrispConfig(
  websiteID: 'YOUR_WEBSITE_ID',
  localMessages: const [
    CrispTextContent('👋 Hi! How can we help you today?'),
    CrispPickerContent(
      id: 'topic',
      text: 'What is your question about?',
      choices: [
        CrispPickerChoice(value: 'billing', label: 'Billing', icon: '💳'),
        CrispPickerChoice(value: 'technical', label: 'Technical', icon: '🛠️'),
        CrispPickerChoice(value: 'other', label: 'Something else'),
      ],
    ),
  ],
);

await FlutterCrispChat.openCrispChat(config: config);
```

### How "first time" works

- The plugin remembers in memory that the messages were shown, so reopening the chat doesn't add them again.
- `FlutterCrispChat.resetCrispChatSession()` clears that flag, so the next `openCrispChat` shows them again for the new session.
- The flag isn't persisted: after the app restarts, the messages show again on the first open. If you only want them **once per install** or **once per user**, store your own flag (for example with [`shared_preferences`](https://pub.dev/packages/shared_preferences)) and only pass `localMessages` when it isn't set:

```dart
final prefs = await SharedPreferences.getInstance();
final isFirstChat = !(prefs.getBool('crisp_welcome_shown') ?? false);

await FlutterCrispChat.openCrispChat(
  config: CrispConfig(
    websiteID: 'YOUR_WEBSITE_ID',
    localMessages: isFirstChat
        ? const [CrispTextContent('👋 Welcome! Ask us anything.')]
        : null,
  ),
);
await prefs.setBool('crisp_welcome_shown', true);
```

::: tip Need operators to see it?
Local messages stay on the device. If the greeting must appear in your Crisp inbox, use a Crisp Bot scenario instead. See [`runBotScenario`](/core_feature/session_management).
:::

## Show a message at any time

```dart
await FlutterCrispChat.showMessage(
  const CrispTextContent('Our team usually replies in a few minutes.'),
);
```

The message goes into the chatbox that is currently open, so call `showMessage` **after** `openCrispChat`. Calling it before the chat has been opened at least once may have no effect, because the native SDK isn't configured yet.

**Throws:** `ArgumentError` if a `CrispTextContent` text is empty or whitespace-only, a `CrispPickerContent` has no choices, or a `CrispCarouselContent` has no targets. `openCrispChat` runs the same checks on `localMessages` before opening the chat.

## Message types

All types extend the sealed `CrispMessageContent` class.

### Text — `CrispTextContent`

```dart
const CrispTextContent('Hello world');
```

| Parameter | Type     | Required | Description                     |
|-----------|----------|----------|---------------------------------|
| `text`    | `String` | Yes      | The message text. Must not be empty. |

### Picker — `CrispPickerContent`

A question with buttons the visitor can tap.

```dart
const CrispPickerContent(
  id: 'plan',
  text: 'Which plan are you on?',
  choices: [
    CrispPickerChoice(value: 'free', label: 'Free'),
    CrispPickerChoice(value: 'pro', label: 'Pro', icon: '🚀', selected: true),
  ],
);
```

| Parameter  | Type                      | Required | Default | Description                                    |
|------------|---------------------------|----------|---------|------------------------------------------------|
| `id`       | `String`                  | Yes      | —       | Unique identifier of the picker                |
| `text`     | `String`                  | Yes      | —       | The question shown above the choices           |
| `choices`  | `List<CrispPickerChoice>` | Yes      | —       | The choices. Must not be empty.                |
| `required` | `bool`                    | No       | `false` | Must the visitor pick a choice (Android & Web only) |

`CrispPickerChoice` takes `value` and `label` (required), plus `selected` (default `false`) and an optional emoji `icon`.

### Field — `CrispFieldContent`

A text input, for example to collect the visitor's email.

```dart
const CrispFieldContent(
  id: 'email',
  text: 'What email can we reach you at?',
  explain: 'name@example.com',
  required: true,
);
```

| Parameter  | Type      | Required | Default | Description                                        |
|------------|-----------|----------|---------|----------------------------------------------------|
| `id`       | `String`  | Yes      | —       | Unique identifier of the field                     |
| `text`     | `String`  | Yes      | —       | The question shown above the input                 |
| `explain`  | `String`  | Yes      | —       | The input placeholder                              |
| `value`    | `String?` | No       | `null`  | A pre-filled value                                 |
| `required` | `bool`    | No       | `false` | Must the visitor fill it (Android & Web only)      |

### Carousel — `CrispCarouselContent`

Horizontally scrolling cards with link buttons.

```dart
const CrispCarouselContent(
  text: 'Popular guides',
  targets: [
    CrispCarouselTarget(
      title: 'Getting started',
      description: 'Set up your account in 5 minutes.',
      image: 'https://example.com/getting-started.png',
      actions: [
        CrispCarouselAction(label: 'Read', url: 'https://example.com/start'),
      ],
    ),
  ],
);
```

| Parameter | Type                        | Required | Description                     |
|-----------|-----------------------------|----------|---------------------------------|
| `text`    | `String`                    | Yes      | Text shown above the cards      |
| `targets` | `List<CrispCarouselTarget>` | Yes      | The cards. Must not be empty.   |

`CrispCarouselTarget` takes `title` and `description` (required), an optional `image` URL, and `actions` (a list of `CrispCarouselAction(label:, url:)`).

### File — `CrispFileContent`

```dart
const CrispFileContent(
  name: 'Pricing.pdf',
  url: 'https://example.com/pricing.pdf',
  mimeType: 'application/pdf',
);
```

### Animation — `CrispAnimationContent`

```dart
const CrispAnimationContent(url: 'https://example.com/hello.gif');
```

`mimeType` defaults to `image/gif`.

### Audio — `CrispAudioContent`

```dart
const CrispAudioContent(
  url: 'https://example.com/welcome.mp3',
  mimeType: 'audio/mpeg',
  duration: 12, // seconds
);
```

::: warning URLs on iOS
On iOS, every URL (`url`, `image`, carousel action `url`) must be a valid absolute URL. If one can't be parsed, the native call fails with an `INVALID_ARGUMENTS` `PlatformException`, and the message isn't shown.
:::

## Platform differences

| Behaviour                                    | Android | iOS    | Web / Desktop |
|----------------------------------------------|---------|--------|---------------|
| `required` on fields and pickers             | ✅      | Ignored | ✅           |
| Sent to the Crisp inbox                      | ❌      | ❌     | ❌            |
| Shown in the browser fallback (desktop)      | —       | —      | ❌            |

::: info Desktop reopens
On desktop, every `openCrispChat` loads a fresh WebView page. Messages shown on the first open may be gone when the chat window is reopened, and `localMessages` won't add them again until `resetCrispChatSession`. To show a message on every desktop open, call `showMessage` after `openCrispChat`.
:::

## Next steps

- [Chat Events](/core_feature/chat_events): react to messages the visitor sends after your welcome message
- [Session Management](/core_feature/session_management): run Bot scenarios and reset sessions
- [API Documentation](/reference/api_documentation#showmessage)
