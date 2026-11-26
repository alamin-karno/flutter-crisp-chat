import 'package:flutter/material.dart';

import '../demo_controller.dart';
import '../sample_data.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Signing users in and out, and setting user details without opening the
/// chat.
class IdentityPage extends StatelessWidget {
  const IdentityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBody(
      children: [
        _SignIn(),
        _LoginSequence(),
        _ProfileSetters(),
      ],
    );
  }
}

class _SignIn extends StatelessWidget {
  const _SignIn();

  @override
  Widget build(BuildContext context) {
    final c = DemoScope.of(context);
    final current = c.currentUser;
    return SectionCard(
      icon: Icons.account_circle_outlined,
      title: 'Sign in',
      subtitle: 'Pick a demo account. Each one gets its own conversation, '
          'which comes back after signing out and in again.',
      api: 'configure() · setTokenId() · resetCrispChatSession()',
      trailing: current != null
          ? Pill('Signed in', color: context.palette.success)
          : const Pill('Guest'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final user in demoUsers) ...[
            _UserCard(user: user, selected: current?.id == user.id),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: current == null
                ? null
                : () => runAction(context, 'Sign out', (c) => c.logOut()),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.selected});

  final DemoUser user;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.surfaceContainerHigh,
            foregroundImage: NetworkImage(user.avatar),
            onForegroundImageError: (_, __) {},
            child: Text(user.nickname[0]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.nickname,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Pill(
                      user.plan,
                      color: user.plan == 'pro'
                          ? CrispColors.purple
                          : CrispColors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.role} at ${user.company}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(user.email, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (selected)
            Icon(Icons.check_circle_rounded, color: scheme.primary)
          else
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () => runAction(
                context,
                'Sign in as ${user.nickname}',
                (c) => c.logIn(user),
              ),
              child: const Text('Sign in'),
            ),
        ],
      ),
    );
  }
}

/// Explains the order of calls, since getting it wrong leaks one user's
/// conversation to the next.
class _LoginSequence extends StatelessWidget {
  const _LoginSequence();

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      icon: Icons.route_outlined,
      title: 'What happens',
      subtitle: 'The login and logout sequence Crisp recommends.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Step(1, 'configure(websiteId)', 'Set up Crisp without opening it.'),
          _Step(2, 'setTokenId(user.id)', 'Tie the conversation to the user.'),
          _Step(
            3,
            'resetCrispChatSession()',
            'Start the session that uses the new token.',
          ),
          _Step(
            4,
            'setUserEmail() · setUserNickname() …',
            'Send the profile before the chat opens.',
          ),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 12),
          _Step(
            null,
            'setTokenId(null) → resetCrispChatSession()',
            "On sign-out, so the next person doesn't see this user's chat.",
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.code, this.text);

  final int? number;
  final String code;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor:
                number == null ? CrispColors.orange : scheme.primary,
            foregroundColor: Colors.white,
            child: number == null
                ? const Icon(Icons.logout_rounded, size: 13)
                : Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ApiTag(code),
                const SizedBox(height: 4),
                Text(text, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSetters extends StatefulWidget {
  const _ProfileSetters();

  @override
  State<_ProfileSetters> createState() => _ProfileSettersState();
}

class _ProfileSettersState extends State<_ProfileSetters> {
  final _email = TextEditingController(text: 'alex@example.com');
  final _nickname = TextEditingController(text: 'Alex');
  final _phone = TextEditingController(text: '+15555550123');
  final _avatar =
      TextEditingController(text: 'https://i.pravatar.cc/150?img=5');

  @override
  void dispose() {
    _email.dispose();
    _nickname.dispose();
    _phone.dispose();
    _avatar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.badge_outlined,
      title: 'Update user details',
      subtitle: 'Each value is sent on its own, without opening the chat. '
          'Invalid values are rejected before reaching Crisp — try one.',
      api: 'setUserEmail() · setUserNickname() · setUserPhone() · '
          'setUserAvatar()',
      child: Column(
        children: [
          _SetterField(
            controller: _email,
            label: 'Email',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            onSet: () =>
                runAction(context, 'Set email', (c) => c.setEmail(_email.text)),
          ),
          _SetterField(
            controller: _nickname,
            label: 'Nickname',
            icon: Icons.person_outline_rounded,
            onSet: () => runAction(
              context,
              'Set nickname',
              (c) => c.setNickname(_nickname.text),
            ),
          ),
          _SetterField(
            controller: _phone,
            label: 'Phone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onSet: () =>
                runAction(context, 'Set phone', (c) => c.setPhone(_phone.text)),
          ),
          _SetterField(
            controller: _avatar,
            label: 'Avatar URL',
            icon: Icons.image_outlined,
            keyboardType: TextInputType.url,
            onSet: () => runAction(
              context,
              'Set avatar',
              (c) => c.setAvatar(_avatar.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetterField extends StatelessWidget {
  const _SetterField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onSet,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final VoidCallback onSet;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, size: 20),
              ),
              onSubmitted: (_) => onSet(),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonal(onPressed: onSet, child: const Text('Set')),
        ],
      ),
    );
  }
}
