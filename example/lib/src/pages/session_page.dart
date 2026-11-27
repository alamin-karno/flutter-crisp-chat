import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter/material.dart';

import '../demo_controller.dart';
import '../platform_support.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Session status, custom data, segments, events, bot scenarios and reset.
class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBody(
      children: [
        _Status(),
        _SessionData(),
        _Segments(),
        _Events(),
        _BotScenario(),
        _Reset(),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status();

  @override
  Widget build(BuildContext context) {
    final c = DemoScope.of(context);
    final palette = context.palette;
    return SectionCard(
      icon: Icons.fingerprint_rounded,
      title: 'Current session',
      subtitle: 'The ID is cached in the background once the chat opens.',
      api: 'getSessionIdentifier() · isSessionOngoing()',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoRow(label: 'Session ID', value: c.sessionId ?? '—'),
          InfoRow(
            label: 'Has messages',
            value: !PlatformSupport.sessionOngoing
                ? 'Not available on Android'
                : switch (c.sessionOngoing) {
                    true => 'Yes',
                    false => 'No',
                    null => 'Unknown',
                  },
            valueColor: c.sessionOngoing == true ? palette.success : null,
          ),
          InfoRow(
            label: 'Signed in as',
            value: c.currentUser?.nickname ?? 'Guest',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => runAction(
                    context,
                    'Get session ID',
                    (c) => c.refreshSessionId(),
                  ),
                  child: const Text('Get session ID'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => runAction(
                    context,
                    'Is session ongoing',
                    (c) => c.checkSessionOngoing(),
                  ),
                  child: const Text('Has messages?'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionData extends StatefulWidget {
  const _SessionData();

  @override
  State<_SessionData> createState() => _SessionDataState();
}

class _SessionDataState extends State<_SessionData> {
  final _key = TextEditingController(text: 'favorite_feature');
  final _value = TextEditingController(text: 'dark mode');
  bool _isNumber = false;

  @override
  void dispose() {
    _key.dispose();
    _value.dispose();
    super.dispose();
  }

  void _save() {
    final key = _key.text;
    final value = _value.text;
    if (_isNumber) {
      final number = int.tryParse(value.trim());
      runAction(context, 'Set session data', (c) {
        if (number == null) {
          throw ArgumentError('"$value" is not a whole number');
        }
        return c.setSessionInt(key, number);
      });
    } else {
      runAction(
        context,
        'Set session data',
        (c) => c.setSessionString(key, value),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.data_object_rounded,
      title: 'Session data',
      subtitle: 'Key–value pairs operators see next to the conversation.',
      api: 'setSessionString() · setSessionInt()',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.text_fields_rounded, size: 18),
                label: Text('Text'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.pin_outlined, size: 18),
                label: Text('Number'),
              ),
            ],
            selected: {_isNumber},
            onSelectionChanged: (value) => setState(() {
              _isNumber = value.first;
              _key.text = _isNumber ? 'cart_items' : 'favorite_feature';
              _value.text = _isNumber ? '3' : 'dark mode';
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _key,
            decoration: const InputDecoration(labelText: 'Key'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _value,
            keyboardType: _isNumber ? TextInputType.number : null,
            decoration: const InputDecoration(labelText: 'Value'),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('Save to session')),
        ],
      ),
    );
  }
}

class _Segments extends StatefulWidget {
  const _Segments();

  @override
  State<_Segments> createState() => _SegmentsState();
}

class _SegmentsState extends State<_Segments> {
  static const _suggestions = [
    'vip',
    'beta-tester',
    'mobile',
    'churn-risk',
    'newsletter',
  ];
  final Set<String> _selected = {'mobile'};
  bool _overwrite = false;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.label_outline_rounded,
      title: 'Segments',
      subtitle: 'Tags for filtering conversations and routing them.',
      api: 'setSessionSegments(segments, overwrite)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final segment in _suggestions)
                FilterChip(
                  label: Text(segment),
                  selected: _selected.contains(segment),
                  onSelected: (on) => setState(
                    () =>
                        on ? _selected.add(segment) : _selected.remove(segment),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Replace existing segments'),
            subtitle: const Text('Off adds to the segments already set'),
            value: _overwrite,
            onChanged: (value) => setState(() => _overwrite = value),
          ),
          FilledButton(
            onPressed: _selected.isEmpty
                ? null
                : () => runAction(
                      context,
                      'Set segments',
                      (c) => c.setSegments(
                        _selected.toList(),
                        overwrite: _overwrite,
                      ),
                    ),
            child: const Text('Apply segments'),
          ),
        ],
      ),
    );
  }
}

class _Events extends StatefulWidget {
  const _Events();

  @override
  State<_Events> createState() => _EventsState();
}

class _EventsState extends State<_Events> {
  final _name = TextEditingController(text: 'Viewed pricing page');
  SessionEventColor _color = SessionEventColor.blue;

  static const _swatches = {
    SessionEventColor.blue: CrispColors.blue,
    SessionEventColor.green: Color(0xFF12B76A),
    SessionEventColor.orange: CrispColors.orange,
    SessionEventColor.red: Color(0xFFF04438),
    SessionEventColor.purple: CrispColors.purple,
    SessionEventColor.pink: Color(0xFFEE46BC),
    SessionEventColor.yellow: Color(0xFFFDB022),
    SessionEventColor.brown: Color(0xFF9D4B0F),
    SessionEventColor.grey: Color(0xFF98A2B3),
    SessionEventColor.black: Color(0xFF101828),
  };

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      icon: Icons.timeline_rounded,
      title: 'Session events',
      subtitle: 'Milestones shown on the conversation timeline, e.g. '
          '"Checked out" or "Payment failed".',
      api: 'pushSessionEvent(name, color)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Event name'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final entry in _swatches.entries)
                Tooltip(
                  message: entry.key.name,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() => _color = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == entry.key
                              ? scheme.onSurface
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: _color == entry.key
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => runAction(
              context,
              'Push event',
              (c) => c.pushEvent(_name.text, _color),
            ),
            child: const Text('Push event'),
          ),
        ],
      ),
    );
  }
}

class _BotScenario extends StatefulWidget {
  const _BotScenario();

  @override
  State<_BotScenario> createState() => _BotScenarioState();
}

class _BotScenarioState extends State<_BotScenario> {
  final _id = TextEditingController();

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.smart_toy_outlined,
      title: 'Bot scenario',
      subtitle: 'Starts a scenario built with the Crisp Bot plugin. Find its '
          'ID in the scenario editor.',
      api: 'runBotScenario(scenarioId)',
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _id,
              decoration: const InputDecoration(
                labelText: 'Scenario ID',
                hintText: 'e.g. 8d6f…',
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: () => runAction(
              context,
              'Run bot scenario',
              (c) => c.runBotScenario(_id.text),
            ),
            child: const Text('Run'),
          ),
        ],
      ),
    );
  }
}

class _Reset extends StatelessWidget {
  const _Reset();

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return SectionCard(
      icon: Icons.restart_alt_rounded,
      title: 'Reset session',
      subtitle: 'Clears the conversation, user details and session data on '
          'this device. The welcome messages show again on the next open.',
      api: 'resetCrispChatSession()',
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: error,
          side: BorderSide(color: error.withValues(alpha: 0.5)),
        ),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset the session?'),
              content: const Text(
                'This clears the chat session on this device and starts a '
                'new one.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: error),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await runAction(context, 'Reset session', (c) => c.resetSession());
          }
        },
        icon: const Icon(Icons.delete_sweep_outlined),
        label: const Text('Reset session'),
      ),
    );
  }
}
