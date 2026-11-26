import 'package:flutter/material.dart';

import '../demo_controller.dart';
import '../platform_support.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// A live log of the actions the example ran and the native Crisp events
/// received from `FlutterCrispChat.onCrispEvent`.
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = DemoScope.of(context);
    final entries = c.activity;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!PlatformSupport.liveEvents) ...[
                      const UnsupportedNote(
                        'Native events (session loaded, chat opened, '
                        'messages) are only sent on Android and iOS. Actions '
                        'you run are still logged here.',
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${entries.length} entries',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: entries.isEmpty ? null : c.clearActivity,
                          icon: const Icon(Icons.clear_all_rounded, size: 18),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (entries.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _EntryTile(entries[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile(this.entry);

  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final (icon, color) = switch (entry.kind) {
      ActivityKind.success => (Icons.check_rounded, palette.success),
      ActivityKind.error => (Icons.close_rounded, theme.colorScheme.error),
      ActivityKind.event => (Icons.bolt_rounded, CrispColors.purple),
      ActivityKind.info => (Icons.info_outline_rounded, palette.muted),
    };
    final t = entry.time;
    final time = '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon: icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (entry.kind == ActivityKind.event)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Pill('event', color: CrispColors.purple),
                        ),
                      Text(time, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  if (entry.detail != null) ...[
                    const SizedBox(height: 4),
                    SelectableText(
                      entry.detail!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const IconBadge(icon: Icons.history_rounded, size: 56),
          const SizedBox(height: 16),
          Text('Nothing yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Open the chat or run an action to see it here.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
