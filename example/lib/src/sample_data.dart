import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter/material.dart';

/// A signed-in user of the host app. In a real app this comes from your
/// own auth system.
class DemoUser {
  const DemoUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.phone,
    required this.avatar,
    required this.plan,
    required this.company,
    required this.role,
    required this.city,
    required this.country,
  });

  /// Your app's stable user ID. Used as the Crisp session token so the
  /// conversation follows the user across devices.
  final String id;
  final String email;
  final String nickname;
  final String phone;
  final String avatar;

  /// Used as the session segment, e.g. to route Pro users to a priority inbox.
  final String plan;
  final String company;
  final String role;
  final String city;
  final String country;

  User toCrispUser() => User(
        email: email,
        nickName: nickname,
        phone: phone,
        avatar: avatar,
        company: Company(
          name: company,
          url: 'https://example.com',
          companyDescription: '$company is a demo company.',
          employment: Employment(title: role, role: role),
          geoLocation: GeoLocation(city: city, country: country),
        ),
      );
}

const demoUsers = [
  DemoUser(
    id: 'user_1001',
    email: 'jane.cooper@example.com',
    nickname: 'Jane Cooper',
    phone: '+14155550101',
    avatar: 'https://i.pravatar.cc/150?img=47',
    plan: 'pro',
    company: 'Acme Inc.',
    role: 'Product Manager',
    city: 'San Francisco',
    country: 'United States',
  ),
  DemoUser(
    id: 'user_1002',
    email: 'leo.martins@example.com',
    nickname: 'Leo Martins',
    phone: '+351210000102',
    avatar: 'https://i.pravatar.cc/150?img=12',
    plan: 'trial',
    company: 'Globex',
    role: 'Mobile Developer',
    city: 'Lisbon',
    country: 'Portugal',
  ),
];

/// Greeting shown by `CrispConfig.localMessages` when the chat first opens.
List<CrispMessageContent> welcomeMessagesFor(DemoUser? user) => [
      CrispTextContent(
        user == null
            ? '👋 Hi there! How can we help you today?'
            : '👋 Welcome back, ${user.nickname.split(' ').first}!',
      ),
      const CrispPickerContent(
        id: 'topic',
        text: 'What is your question about?',
        choices: [
          CrispPickerChoice(value: 'billing', label: 'Billing', icon: '💳'),
          CrispPickerChoice(
              value: 'technical', label: 'Technical', icon: '🛠️'),
          CrispPickerChoice(value: 'other', label: 'Something else'),
        ],
      ),
    ];

/// One card in the Messages tab.
class LocalMessageSample {
  const LocalMessageSample({
    required this.title,
    required this.description,
    required this.icon,
    required this.content,
  });

  final String title;
  final String description;
  final IconData icon;
  final CrispMessageContent content;
}

/// One of each [CrispMessageContent] type, for `FlutterCrispChat.showMessage`.
const localMessageSamples = [
  LocalMessageSample(
    title: 'Text',
    description: 'A plain operator message. Supports emoji and Markdown.',
    icon: Icons.chat_bubble_outline,
    content: CrispTextContent(
      'Our team usually replies in **under 5 minutes** ⚡',
    ),
  ),
  LocalMessageSample(
    title: 'Picker',
    description: 'Buttons the visitor taps to pick one answer.',
    icon: Icons.checklist_rounded,
    content: CrispPickerContent(
      id: 'satisfaction',
      text: 'How would you rate our app?',
      choices: [
        CrispPickerChoice(value: 'great', label: 'Great', icon: '😍'),
        CrispPickerChoice(value: 'ok', label: 'Okay', icon: '🙂'),
        CrispPickerChoice(value: 'bad', label: 'Not great', icon: '😕'),
      ],
    ),
  ),
  LocalMessageSample(
    title: 'Field',
    description: 'Asks for a value, such as an email or an order number.',
    icon: Icons.edit_note_rounded,
    content: CrispFieldContent(
      id: 'order_number',
      text: 'What is your order number?',
      explain: 'e.g. #10234',
      required: true,
    ),
  ),
  LocalMessageSample(
    title: 'Carousel',
    description: 'Swipeable cards with links, e.g. product suggestions.',
    icon: Icons.view_carousel_outlined,
    content: CrispCarouselContent(
      text: 'These guides might help:',
      targets: [
        CrispCarouselTarget(
          title: 'Getting started',
          description: 'Install the plugin and open your first chat.',
          image: 'https://picsum.photos/seed/crisp1/600/400',
          actions: [
            CrispCarouselAction(
              label: 'Read guide',
              url: 'https://alamin-karno.github.io/flutter-crisp-chat/',
            ),
          ],
        ),
        CrispCarouselTarget(
          title: 'Push notifications',
          description: 'Get notified when an operator replies.',
          image: 'https://picsum.photos/seed/crisp2/600/400',
          actions: [
            CrispCarouselAction(
              label: 'Set up',
              url: 'https://alamin-karno.github.io/flutter-crisp-chat/'
                  'notifications/firebase_setup.html',
            ),
          ],
        ),
      ],
    ),
  ),
  LocalMessageSample(
    title: 'File',
    description: 'A downloadable attachment, such as an invoice.',
    icon: Icons.picture_as_pdf_outlined,
    content: CrispFileContent(
      name: 'invoice-10234.pdf',
      url:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      mimeType: 'application/pdf',
    ),
  ),
  LocalMessageSample(
    title: 'Animation',
    description: 'An animated GIF.',
    icon: Icons.gif_box_outlined,
    content: CrispAnimationContent(
      url: 'https://upload.wikimedia.org/wikipedia/commons/2/2c/'
          'Rotating_earth_%28large%29.gif',
      mimeType: 'image/gif',
    ),
  ),
  LocalMessageSample(
    title: 'Audio',
    description: 'A voice note the visitor can play.',
    icon: Icons.graphic_eq_rounded,
    content: CrispAudioContent(
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      mimeType: 'audio/mpeg',
      duration: 30,
    ),
  ),
];

/// Locales offered for `CrispConfig.locale` (Web and desktop only).
const demoLocales = {
  null: 'Auto',
  'en': 'English',
  'fr': 'Français',
  'de': 'Deutsch',
  'es': 'Español',
  'pt-br': 'Português (BR)',
  'bn': 'বাংলা',
  'ja': '日本語',
};
