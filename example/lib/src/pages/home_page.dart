import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter/material.dart';

import '../demo_controller.dart';
import '../platform_support.dart';
import '../sample_data.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Opening the chat and helpdesk, unread messages, ready-made scenarios,
/// and the chat appearance options.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DemoScope.of(context);
    return PageBody(
      children: [
        if (!c.hasWebsiteId) const _MissingConfigBanner(),
        const _Hero(),
        const _QuickActions(),
        const _Scenarios(),
        const _Appearance(),
      ],
    );
  }
}

class _MissingConfigBanner extends StatelessWidget {
  const _MissingConfigBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.palette.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.key_off_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add your website ID', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Find it in Crisp under Settings › Workspace settings › '
                  'Setup & integrations, then run:',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                const ApiTag(
                  'flutter run --dart-define=websiteId=YOUR_WEBSITE_ID',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Navy-to-blue hero card, echoing the dark sections of crisp.chat.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final c = DemoScope.of(context);
    final palette = context.palette;
    final theme = Theme.of(context);
    final user = c.currentUser;
    final unread = c.unreadCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.heroStart, palette.heroEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white24,
                foregroundImage:
                    user != null ? NetworkImage(user.avatar) : null,
                onForegroundImageError: user != null ? (_, __) {} : null,
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user == null ? 'Browsing as guest' : user.nickname,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user == null
                          ? 'Sign in on the Identity tab'
                          : '${user.email} · ${user.plan}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'How can we help?',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Chat with the team, browse the helpdesk, or try the '
            'scenarios below.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Badge.count(
            count: unread,
            isLabelVisible: unread > 0,
            backgroundColor: CrispColors.orange,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: CrispColors.blue,
              ),
              onPressed: () =>
                  runAction(context, 'Open chat', (c) => c.openChat()),
              icon: const Icon(Icons.chat_rounded),
              label: const Text('Open chat'),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(Icons.devices_rounded, PlatformSupport.name),
              _HeroChip(
                Icons.bolt_rounded,
                PlatformSupport.liveEvents ? 'Live events' : 'No live events',
                enabled: PlatformSupport.liveEvents,
              ),
              _HeroChip(
                Icons.notifications_rounded,
                PlatformSupport.pushNotifications ? 'Push' : 'No push',
                enabled: PlatformSupport.pushNotifications,
              ),
              _HeroChip(
                Icons.videocam_rounded,
                switch (c.videoCallsSupported) {
                  true => 'Video calls',
                  false => 'No video calls',
                  null => 'Video calls ?',
                },
                enabled: c.videoCallsSupported ?? false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip(this.icon, this.label, {this.enabled = true});

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white : Colors.white54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: enabled ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final c = DemoScope.of(context);
    final restNote = c.hasRestCredentials ? null : const Pill('Needs API key');
    return SectionCard(
      icon: Icons.grid_view_rounded,
      title: 'Help center & unread',
      subtitle: 'Self-service articles, and unread messages via the REST API.',
      child: ResponsiveGrid(
        children: [
          ActionTile(
            icon: Icons.menu_book_rounded,
            title: 'Open helpdesk',
            subtitle: 'Search the knowledge base',
            onTap: () =>
                runAction(context, 'Open helpdesk', (c) => c.openHelpdesk()),
          ),
          ActionTile(
            icon: Icons.article_outlined,
            title: 'Open an article',
            subtitle: 'Jump straight to one article',
            color: CrispColors.purple,
            onTap: () => _openArticle(context),
          ),
          ActionTile(
            icon: Icons.mark_chat_unread_outlined,
            title: 'Check unread',
            subtitle: c.unreadCount == null
                ? 'getUnreadMessageCount()'
                : '${c.unreadCount} unread',
            color: CrispColors.orange,
            badge: restNote,
            onTap: () => runAction(
              context,
              'Check unread',
              (c) => c.fetchUnreadCount(),
            ),
          ),
          ActionTile(
            icon: Icons.done_all_rounded,
            title: 'Mark as read',
            subtitle: 'markMessagesAsRead()',
            color: CrispColors.green,
            badge: restNote,
            onTap: () =>
                runAction(context, 'Mark as read', (c) => c.markAsRead()),
          ),
        ],
      ),
    );
  }

  Future<void> _openArticle(BuildContext context) async {
    final slugField = TextEditingController(text: 'example-article');
    final localeField = TextEditingController(text: 'en');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open a helpdesk article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: slugField,
              decoration: const InputDecoration(labelText: 'Article slug'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: localeField,
              decoration: const InputDecoration(labelText: 'Locale'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open'),
          ),
        ],
      ),
    );
    final slug = slugField.text;
    final locale = localeField.text;
    slugField.dispose();
    localeField.dispose();
    if (confirmed != true || !context.mounted) return;
    await runAction(
      context,
      'Open article',
      (c) => c.openHelpdeskArticle(locale: locale, slug: slug),
    );
  }
}

class _Scenarios extends StatelessWidget {
  const _Scenarios();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.auto_awesome_rounded,
      title: 'Real-world scenarios',
      subtitle: 'Each one combines session data, segments, events and local '
          'messages, then opens the chat.',
      child: Column(
        children: [
          ActionTile(
            icon: Icons.local_shipping_outlined,
            title: 'Help with an order',
            subtitle: 'Attaches order #10234 to the session',
            onTap: () => runAction(
              context,
              'Scenario: order support',
              (c) => c.orderSupportScenario(),
            ),
          ),
          const SizedBox(height: 10),
          ActionTile(
            icon: Icons.bug_report_outlined,
            title: 'Report a bug',
            subtitle: 'Records the app version and asks for severity',
            color: CrispColors.red,
            onTap: () => runAction(
              context,
              'Scenario: bug report',
              (c) => c.bugReportScenario(),
            ),
          ),
          const SizedBox(height: 10),
          ActionTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Talk to sales',
            subtitle: 'Tags the visitor for sales and asks for an email',
            color: CrispColors.purple,
            onTap: () => runAction(
              context,
              'Scenario: sales',
              (c) => c.salesScenario(),
            ),
          ),
          const SizedBox(height: 10),
          ActionTile(
            icon: Icons.restart_alt_rounded,
            title: 'Start fresh',
            subtitle: 'Resets the session so the welcome messages show again',
            color: CrispColors.orange,
            onTap: () => runAction(
              context,
              'Scenario: fresh start',
              (c) => c.freshStartScenario(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Appearance extends StatelessWidget {
  const _Appearance();

  @override
  Widget build(BuildContext context) {
    final c = DemoScope.of(context);
    final theme = Theme.of(context);
    return SectionCard(
      icon: Icons.palette_outlined,
      title: 'Chat appearance',
      subtitle: 'Applied the next time the chat opens.',
      api: 'CrispConfig(colorMode, locale, modalPresentationStyle)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Color mode', style: theme.textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(
            'Default keeps the mode set in your Crisp dashboard.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          if (PlatformSupport.colorMode)
            SegmentedButton<CrispColorMode?>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: null, label: Text('Default')),
                ButtonSegment(
                    value: CrispColorMode.light, label: Text('Light')),
                ButtonSegment(value: CrispColorMode.dark, label: Text('Dark')),
                ButtonSegment(value: CrispColorMode.auto, label: Text('Auto')),
              ],
              selected: {c.colorMode},
              onSelectionChanged: (value) =>
                  c.updateOptions(() => c.colorMode = value.first),
            )
          else
            const UnsupportedNote(
              'The Crisp Android SDK has no color mode setting. The chat '
              'uses the mode set in your Crisp dashboard.',
            ),
          const SizedBox(height: 20),
          Text('Language', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          if (PlatformSupport.locale)
            DropdownButtonFormField<String?>(
              initialValue: c.locale,
              items: [
                for (final entry in demoLocales.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (value) => c.updateOptions(() => c.locale = value),
            )
          else
            const UnsupportedNote(
              'On Android and iOS the chat follows the app language. Change '
              'it in the system settings for this app.',
            ),
          if (PlatformSupport.modalStyle) ...[
            const SizedBox(height: 20),
            Text('Presentation (iOS)', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<ModalPresentationStyle>(
              initialValue: c.modalStyle,
              items: const [
                DropdownMenuItem(
                  value: ModalPresentationStyle.fullScreen,
                  child: Text('Full screen (default)'),
                ),
                DropdownMenuItem(
                  value: ModalPresentationStyle.pageSheet,
                  child: Text('Page sheet'),
                ),
                DropdownMenuItem(
                  value: ModalPresentationStyle.formSheet,
                  child: Text('Form sheet'),
                ),
                DropdownMenuItem(
                  value: ModalPresentationStyle.overFullScreen,
                  child: Text('Over full screen'),
                ),
                DropdownMenuItem(
                  value: ModalPresentationStyle.overCurrentContext,
                  child: Text('Over current context'),
                ),
                DropdownMenuItem(
                  value: ModalPresentationStyle.popover,
                  child: Text('Popover (iPad)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) c.updateOptions(() => c.modalStyle = value);
              },
            ),
          ],
        ],
      ),
    );
  }
}
