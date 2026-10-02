import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../providers/notifications_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      header: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left_rounded, color: PColors.bone, size: 28),
            ),
            const Expanded(
              child: Center(
                child: Text('Notifications', style: TextStyle(
                  color: PColors.bone,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Hanken Grotesk',
                )),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
      body: provider.preferences is AsyncLoading
          ? const Center(child: CircularProgressIndicator(color: PColors.bone))
          : provider.preferences is AsyncError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PEyebrow('Could not load preferences'),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => provider.loadPreferences(),
                        child: Text('Retry', style: PType.uiStrong),
                      ),
                    ],
                  ),
                )
              : _SettingsList(provider: provider),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.provider});

  final NotificationsProvider provider;

  @override
  Widget build(BuildContext context) {
    final prefs = provider.currentPreferences;
    if (prefs == null) return const SizedBox();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const PEyebrow('Daily reminders'),
        const SizedBox(height: 4),

        _ToggleRow(
          title: 'Daily Scripture',
          subtitle: 'Receive a verse each morning',
          value: prefs.dailyVerse,
          onChanged: (v) => provider.updatePreference(dailyVerse: v),
        ),
        _ToggleRow(
          title: 'Declarations',
          subtitle: 'New faith declarations ready to speak',
          value: prefs.declarations,
          onChanged: (v) => provider.updatePreference(declarations: v),
        ),
        _ToggleRow(
          title: 'Streak reminder',
          subtitle: 'Gentle nudge to maintain consistency',
          value: prefs.streakReminder,
          onChanged: (v) => provider.updatePreference(streakReminder: v),
        ),

        const SizedBox(height: 24),
        PListRow(
          title: 'Reminder time',
          meta: prefs.reminderTime,
          showChevron: true,
        ),

        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PColors.glassFill,
            borderRadius: BorderRadius.circular(PRadius.tile),
            border: Border.all(color: PColors.hairline),
          ),
          child: Text(
            'Notifications help you maintain rhythm and never miss a day of your daily space with Scripture.',
            style: PType.meta.copyWith(color: PColors.bone62, height: 1.5),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: PSpace.rowPaddingY),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PColors.hairline, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PType.rowTitle),
                const SizedBox(height: 3),
                Text(subtitle, style: PType.meta),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: PColors.bone,
            activeTrackColor: PColors.bone50,
            inactiveThumbColor: PColors.bone45,
            inactiveTrackColor: PColors.glassFill,
          ),
        ],
      ),
    );
  }
}
