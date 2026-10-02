import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/state/async_state.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/ui/primitives/primitives.dart';
import '../providers/declaration_provider.dart';

/// Web layout for Declarations: left sidebar filters + central shareable Bone Card.
class DeclarationsWebLayout extends StatelessWidget {
  const DeclarationsWebLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeclarationProvider>();

    return Scaffold(
      backgroundColor: PColors.ink,
      body: SafeArea(
        child: Row(
          children: [
            // ─── Left panel: filters ───
            Container(
              width: 280,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: PColors.hairline, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Declarations', style: PType.display.copyWith(fontSize: 26)),
                        const SizedBox(height: 4),
                        const PEyebrow('Today\'s faith declarations'),
                      ],
                    ),
                  ),
                  const Divider(color: PColors.hairline, height: 1),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: PEyebrow('Filter by'),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _WebFilterTile(
                          label: 'All declarations',
                          icon: Icons.graphic_eq_rounded,
                          isSelected: provider.selectedGender == 'all',
                          onTap: () {
                            provider.setGender('all');
                            provider.loadDeclarations();
                          },
                        ),
                        const SizedBox(height: 8),
                        _WebFilterTile(
                          label: 'For Men',
                          icon: Icons.male_rounded,
                          isSelected: provider.selectedGender == 'hombre',
                          onTap: () {
                            provider.setGender('hombre');
                            provider.loadDeclarations();
                          },
                        ),
                        const SizedBox(height: 8),
                        _WebFilterTile(
                          label: 'For Women',
                          icon: Icons.female_rounded,
                          isSelected: provider.selectedGender == 'mujer',
                          onTap: () {
                            provider.setGender('mujer');
                            provider.loadDeclarations();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Right panel: central declaration card ───
            Expanded(
              child: _DeclarationWebContent(provider: provider),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebFilterTile extends StatelessWidget {
  const _WebFilterTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? PColors.glassFill : Colors.transparent,
          borderRadius: BorderRadius.circular(PRadius.tile),
          border: Border.all(
            color: isSelected ? PColors.bone : PColors.hairline,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? PColors.bone : PColors.bone45),
            const SizedBox(width: 12),
            Text(
              label,
              style: PType.uiStrong.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? PColors.bone : PColors.bone62,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeclarationWebContent extends StatelessWidget {
  const _DeclarationWebContent({required this.provider});

  final DeclarationProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.declarations is AsyncLoading || provider.declarations is AsyncInitial) {
      return const Center(
        child: CircularProgressIndicator(color: PColors.bone),
      );
    }

    if (provider.declarations is AsyncError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56, color: PColors.bone45),
            const SizedBox(height: 16),
            const PEyebrow('Could not load declarations'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => provider.loadDeclarations(),
              child: Text('Retry', style: PType.uiStrong),
            ),
          ],
        ),
      );
    }

    final declarations = provider.currentDeclarations;
    final declaration = provider.currentDeclaration;

    if (declarations.isEmpty || declaration == null) {
      return const Center(
        child: PEyebrow('No declarations available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Column(
        children: [
          // Tarjeta Central Bone Card
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
                child: PBoneCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TODAY I DECLARE', style: PType.eyebrow.copyWith(color: PColors.clay)),
                          const Icon(Icons.graphic_eq_rounded, color: PColors.clay, size: 20),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        declaration.text,
                        style: PType.cardTitle.copyWith(fontSize: 28, height: 1.3),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        declaration.reference,
                        style: PType.meta.copyWith(color: PColors.stone),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: PColors.clay,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PREGARE',
                            style: PType.wordmark.copyWith(color: PColors.stone, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Desktop Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: provider.currentIndex > 0
                    ? () => provider.previousDeclaration()
                    : null,
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                color: provider.currentIndex > 0 ? PColors.bone : PColors.bone45,
              ),
              const SizedBox(width: 16),
              Text(
                '${provider.currentIndex + 1} / ${declarations.length}',
                style: PType.counter.copyWith(color: PColors.bone),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: provider.currentIndex < declarations.length - 1
                    ? () => provider.nextDeclaration()
                    : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                color: provider.currentIndex < declarations.length - 1
                    ? PColors.bone
                    : PColors.bone45,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
