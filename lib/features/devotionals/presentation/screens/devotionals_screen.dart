import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../bible/presentation/screens/bible_screen.dart';
import '../providers/devotionals_provider.dart';
import 'devotionals_web_layout.dart';

class DevotionalsScreen extends StatefulWidget {
  const DevotionalsScreen({super.key});

  @override
  State<DevotionalsScreen> createState() => _DevotionalsScreenState();
}

class _DevotionalsScreenState extends State<DevotionalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevotionalsProvider>().loadDevotionals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DevotionalsProvider>();

    if (AppBreakpoints.isDesktop(context)) {
      return const DevotionalsWebLayout();
    }

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: true,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 16),
          Text('Devotionals', style: PType.display),
          const SizedBox(height: 6),
          const PEyebrow('Daily reflection & prayer'),
          const SizedBox(height: 24),
          if (provider.devotionals is AsyncLoading)
            const Center(child: CircularProgressIndicator(color: PColors.bone))
          else if (provider.devotionals is AsyncError)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PEyebrow('Could not load devotionals'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => provider.loadDevotionals(),
                    child: Text('Retry', style: PType.uiStrong),
                  ),
                ],
              ),
            )
          else
            _DevotionalsList(
              devotionals: provider.currentDevotionals,
              expandedId: provider.expandedId,
              onToggle: provider.toggleAccordion,
            ),
          const SizedBox(height: PSpace.navClearance),
        ],
      ),
    );
  }
}

class _DevotionalsList extends StatelessWidget {
  const _DevotionalsList({
    required this.devotionals,
    required this.expandedId,
    required this.onToggle,
  });

  final List<dynamic> devotionals;
  final int? expandedId;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    if (devotionals.isEmpty) {
      return const Center(child: PEyebrow('No devotionals available'));
    }

    return Column(
      children: devotionals.map((d) {
        final isExpanded = expandedId == d.id;
        return _DevotionalsAccordion(
          devotional: d,
          isExpanded: isExpanded,
          onTap: () => onToggle(d.id),
        );
      }).toList(),
    );
  }
}

class _DevotionalsAccordion extends StatelessWidget {
  const _DevotionalsAccordion({
    required this.devotional,
    required this.isExpanded,
    required this.onTap,
  });

  final dynamic devotional;
  final bool isExpanded;
  final VoidCallback onTap;

  /// Parses a Bible reference like "John 3:16" or "2 Corinthians 5:17" and
  /// opens the [BibleReaderScreen] locked to KJV at the correct verse.
  void _openVerseInBible(BuildContext context, String reference) {
    final ref = reference.trim();
    if (ref.isEmpty) return;

    // Extract verse number: everything after the last colon
    final colonIdx = ref.lastIndexOf(':');
    int? verseNumber;
    String bookAndChapter = ref;
    if (colonIdx != -1) {
      verseNumber = int.tryParse(ref.substring(colonIdx + 1).trim().split(' ').first);
      bookAndChapter = ref.substring(0, colonIdx).trim();
    }

    // Separate chapter from book name
    final parts = bookAndChapter.split(' ');
    int chapter = 1;
    String bookName = bookAndChapter;
    if (parts.length >= 2) {
      final maybeCh = int.tryParse(parts.last);
      if (maybeCh != null) {
        chapter = maybeCh;
        bookName = parts.sublist(0, parts.length - 1).join(' ');
      }
    }

    // Build a URL-safe book ID
    var bookId = bookName.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
    if (bookId == 'psalm') bookId = 'psalms';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleReaderScreen(
          bookId: bookId,
          bookName: bookName,
          initialChapter: chapter,
          initialVerse: verseNumber,
          targetVersion: 'KJV',
          devotionalTitle: devotional.title,
          devotionalDay: devotional.day,
          isFromDevotional: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = devotional;
    // Resolve verse reference for navigation
    final String verseRef = (d.effectiveVerseReference != null &&
            (d.effectiveVerseReference as String).trim().isNotEmpty)
        ? (d.effectiveVerseReference as String).trim()
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PColors.glassFill,
            borderRadius: BorderRadius.circular(PRadius.tile),
            border: Border.all(color: isExpanded ? PColors.bone : PColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isExpanded ? PColors.bone : PColors.glassFill,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Day ${d.day}',
                      style: PType.meta.copyWith(
                        color: isExpanded ? PColors.ink : PColors.bone70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      d.title,
                      style: PType.rowTitle.copyWith(
                        color: isExpanded ? PColors.bone : PColors.bone70,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 20,
                    color: PColors.bone45,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                if (d.verse != null) ...[
                  // Tappable verse card — opens Bible reader in KJV at the verse
                  GestureDetector(
                    onTap: verseRef.isNotEmpty
                        ? () => _openVerseInBible(context, verseRef)
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        border: const Border(left: BorderSide(color: PColors.bone, width: 2.0)),
                        color: verseRef.isNotEmpty
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.transparent,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.verse!,
                            style: PType.scripture.copyWith(fontSize: 17, height: 1.4),
                          ),
                          if (verseRef.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '— $verseRef',
                                  style: PType.meta.copyWith(
                                    color: PColors.bone70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.menu_book_rounded,
                                        size: 11,
                                        color: PColors.bone45,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Abrir en Biblia · KJV',
                                        style: PType.meta.copyWith(
                                          color: PColors.bone45,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(d.text, style: PType.body.copyWith(height: 1.65)),
                if (d.prayer != null) ...[
                  const SizedBox(height: 16),
                  const PEyebrow('Prayer'),
                  const SizedBox(height: 6),
                  Text(
                    d.prayer!,
                    style: PType.body.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.65,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
