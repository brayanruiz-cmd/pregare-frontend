import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/state/async_state.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/ui/primitives/primitives.dart';
import '../providers/devotionals_provider.dart';

/// Web layout for Devotionals adhering to PREGARE tokens.
class DevotionalsWebLayout extends StatelessWidget {
  const DevotionalsWebLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DevotionalsProvider>();
    final devotionals = provider.currentDevotionals;
    final expandedId = provider.expandedId;

    return Scaffold(
      backgroundColor: PColors.ink,
      body: SafeArea(
        child: Row(
          children: [
            // ─── Left panel: list ───
            Container(
              width: 300,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: PColors.hairline, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Devotionals', style: PType.display.copyWith(fontSize: 26)),
                        const SizedBox(height: 4),
                        const PEyebrow('Daily reflection & prayer'),
                      ],
                    ),
                  ),
                  const Divider(color: PColors.hairline, height: 1),
                  Expanded(
                    child: provider.devotionals is AsyncLoading || provider.devotionals is AsyncInitial
                        ? const Center(child: CircularProgressIndicator(color: PColors.bone))
                        : provider.devotionals is AsyncError
                            ? Center(
                                child: GestureDetector(
                                  onTap: () => provider.loadDevotionals(),
                                  child: Text('Retry', style: PType.uiStrong),
                                ),
                              )
                            : devotionals.isEmpty
                                ? const Center(child: PEyebrow('No devotionals available'))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    itemCount: devotionals.length,
                                    itemBuilder: (context, index) {
                                      final d = devotionals[index];
                                      final isSelected = expandedId == d.id;
                                      return _DevotionalListTile(
                                        devotional: d,
                                        isSelected: isSelected,
                                        onTap: () => provider.toggleAccordion(d.id),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),

            // ─── Right panel: detail ───
            Expanded(
              child: (expandedId == null || devotionals.isEmpty)
                  ? const _DevotionalEmptyDetail()
                  : _DevotionalDetail(
                      devotional: devotionals.firstWhere(
                        (d) => d.id == expandedId,
                        orElse: () => devotionals.first,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevotionalListTile extends StatelessWidget {
  const _DevotionalListTile({
    required this.devotional,
    required this.isSelected,
    required this.onTap,
  });

  final dynamic devotional;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? PColors.glassFill : Colors.transparent,
            borderRadius: BorderRadius.circular(PRadius.tile),
            border: Border.all(
              color: isSelected ? PColors.bone : PColors.hairline,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected ? PColors.bone : PColors.glassFill,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Day ${devotional.day}',
                  style: PType.meta.copyWith(
                    fontSize: 11,
                    color: isSelected ? PColors.ink : PColors.bone70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  devotional.title,
                  style: PType.rowTitle.copyWith(
                    fontSize: 13,
                    color: isSelected ? PColors.bone : PColors.bone70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DevotionalEmptyDetail extends StatelessWidget {
  const _DevotionalEmptyDetail();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.spa_outlined, size: 56, color: PColors.bone45),
          const SizedBox(height: 16),
          const PEyebrow('Select a devotional'),
          const SizedBox(height: 6),
          Text('Choose a day from the list to read the reflection.', style: PType.body),
        ],
      ),
    );
  }
}

class _DevotionalDetail extends StatelessWidget {
  const _DevotionalDetail({required this.devotional});

  final dynamic devotional;

  @override
  Widget build(BuildContext context) {
    final d = devotional;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PEyebrow('Day ${d.day} · Devotional'),
          const SizedBox(height: 12),
          Text(d.title, style: PType.display.copyWith(fontSize: 32)),
          const SizedBox(height: 28),

          // Verse
          if (d.verse != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: PColors.bone, width: 2.0)),
              ),
              child: Text(
                d.verse!,
                style: PType.scripture.copyWith(fontSize: 20, height: 1.4),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // Reflection
          const PEyebrow('Reflection'),
          const SizedBox(height: 10),
          Text(d.text, style: PType.body.copyWith(fontSize: 16, height: 1.7)),
          const SizedBox(height: 28),

          // Prayer
          if (d.prayer != null) ...[
            const PEyebrow('Prayer'),
            const SizedBox(height: 10),
            Text(
              d.prayer!,
              style: PType.body.copyWith(
                fontSize: 16,
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
