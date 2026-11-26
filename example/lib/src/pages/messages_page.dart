import 'package:flutter/material.dart';

import '../demo_controller.dart';
import '../sample_data.dart';
import '../widgets/common.dart';

/// Local operator messages: the welcome messages in [CrispConfig] and one
/// sample of every [CrispMessageContent] type for `showMessage`.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DemoScope.of(context);
    return PageBody(
      children: [
        SectionCard(
          icon: Icons.waving_hand_outlined,
          title: 'Welcome messages',
          subtitle: 'A greeting and a topic picker, shown as operator '
              'messages the first time the chat opens and after each reset.',
          api: 'CrispConfig(localMessages: [...])',
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show welcome messages'),
            subtitle: const Text('Only on this device. Never sent to Crisp.'),
            value: c.welcomeMessages,
            onChanged: (value) =>
                c.updateOptions(() => c.welcomeMessages = value),
          ),
        ),
        SectionCard(
          icon: Icons.chat_outlined,
          title: 'Message types',
          subtitle: 'Opens the chat and shows the message locally. Operators '
              "don't see it, but they do see the visitor's answer.",
          api: 'showMessage(CrispMessageContent)',
          child: ResponsiveGrid(
            children: [
              for (final sample in localMessageSamples)
                ActionTile(
                  icon: sample.icon,
                  title: sample.title,
                  subtitle: sample.description,
                  onTap: () => runAction(
                    context,
                    'Show ${sample.title.toLowerCase()} message',
                    (c) => c.showLocalMessage(sample.content),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
