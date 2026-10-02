import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../providers/streaks_provider.dart';

class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});

  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreaksProvider>().loadStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StreaksProvider>();

    return PScreen(
      background: const PScreenBackground.photo('assets/photo-milestone.jpg', scrim: PScrims.home),
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
                child: Text('Your Growth', style: TextStyle(
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
      body: provider.streak is AsyncLoading
          ? const Center(child: CircularProgressIndicator(color: PColors.bone))
          : _buildContent(provider),
    );
  }

  Widget _buildContent(StreaksProvider provider) {
    final streak = provider.currentStreak;
    if (streak == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PEyebrow('No streak recorded yet'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => provider.checkIn(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: PColors.bone,
                  borderRadius: BorderRadius.circular(PRadius.pill),
                ),
                child: Text('Check-in', style: PType.uiStrong.copyWith(color: PColors.ink)),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PEyebrow('You are building something'),
          const SizedBox(height: 16),
          Text(
            '${streak.currentStreak}',
            style: PType.display.copyWith(fontSize: 72, height: 1.0),
          ),
          const SizedBox(height: 8),
          Text('days in a row', style: PType.body.copyWith(color: PColors.bone70, fontSize: 16)),
          const SizedBox(height: 24),
          Text(
            provider.getMotivationalMessage(streak.currentStreak),
            style: PType.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          GestureDetector(
            onTap: () => provider.checkIn(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: PColors.bone,
                borderRadius: BorderRadius.circular(PRadius.pill),
              ),
              child: Text('Today\'s check-in', style: PType.uiStrong.copyWith(color: PColors.ink)),
            ),
          ),
        ],
      ),
    );
  }
}
