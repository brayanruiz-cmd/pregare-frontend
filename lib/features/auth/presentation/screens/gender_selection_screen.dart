import 'package:flutter/material.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/primitives/primitives.dart';

class GenderSelectionScreen extends StatelessWidget {
  const GenderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PEyebrow('Personalize your experience'),
            const SizedBox(height: 12),
            Text(
              'Who are your declarations\nwritten for?',
              style: PType.display.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'Written in her or his voice to accompany your daily walk.',
              style: PType.body,
            ),
            const SizedBox(height: 40),

            _GenderOption(
              label: 'For Women',
              subtitle: 'Written in her voice',
              icon: Icons.female_rounded,
              onTap: () => _selectGender(context, 'mujeres'),
            ),
            const SizedBox(height: 16),

            _GenderOption(
              label: 'For Men',
              subtitle: 'Written in his voice',
              icon: Icons.male_rounded,
              onTap: () => _selectGender(context, 'hombres'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectGender(BuildContext context, String gender) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PColors.glassFill,
          borderRadius: BorderRadius.circular(PRadius.panel),
          border: Border.all(color: PColors.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: PColors.glassFill,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: PColors.bone, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: PType.rowTitle.copyWith(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: PType.meta),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: PColors.bone45, size: 20),
          ],
        ),
      ),
    );
  }
}
