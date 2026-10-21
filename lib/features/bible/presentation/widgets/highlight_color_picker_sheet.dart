import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/molecules/auth_prompt_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/highlight_color_option.dart';
import '../../domain/models/chapter.dart';
import '../providers/bible_provider.dart';
import 'save_to_collection_sheet.dart';
import 'share_verse_sheet.dart';

/// Bottom modal sheet / dialog to choose a highlight color for a Bible verse.
class HighlightColorPickerSheet extends StatelessWidget {
  const HighlightColorPickerSheet({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
  });

  final String bookId;
  final String bookName;
  final int chapter;
  final Verse verse;

  static Future<void> show(
    BuildContext context, {
    required String bookId,
    required String bookName,
    required int chapter,
    required Verse verse,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => HighlightColorPickerSheet(
        bookId: bookId,
        bookName: bookName,
        chapter: chapter,
        verse: verse,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleProvider>();
    final isHighlighted = provider.isVerseHighlighted(bookId, chapter, verse.number);
    final currentColorHex = provider.getVerseHighlightColor(bookId, chapter, verse.number);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: PColors.bone,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2A141310),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: PColors.ink14,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header row with verse reference & close button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bookName $chapter:${verse.number}',
                        style: PType.rowTitle.copyWith(
                          fontSize: 18,
                          color: PColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        verse.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PType.body.copyWith(
                          color: PColors.stone,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ShareVerseSheet.show(
                      context,
                      bookName: bookName,
                      chapter: chapter,
                      verseNumber: verse.number,
                      verseText: verse.text,
                    );
                  },
                  icon: const Icon(Icons.ios_share_rounded, color: PColors.ink, size: 20),
                  splashRadius: 20,
                  tooltip: 'Compartir versículo',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: PColors.ink40, size: 20),
                  splashRadius: 20,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Title for color swatches
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HIGHLIGHT COLOR',
                  style: PType.eyebrow.copyWith(
                    color: PColors.stone,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isHighlighted)
                  GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await provider.removeVerseHighlight(bookId, chapter, verse.number);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$bookName $chapter:${verse.number} highlight removed',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.format_color_reset_rounded,
                          size: 15,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Remove',
                          style: PType.meta.copyWith(
                            color: const Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Color Swatches Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: HighlightColorOption.options.map((opt) {
                final isSelected = isHighlighted &&
                    currentColorHex?.toUpperCase() == opt.hex.toUpperCase();

                return GestureDetector(
                  onTap: () async {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isAuthenticated) {
                      Navigator.of(context).pop();
                      AuthPromptSheet.show(
                        context,
                        isLoginOnly: false,
                        onSuccess: () async {
                          final isNowHighlighted = await provider.setVerseHighlight(
                            bookId,
                            chapter,
                            verse.number,
                            colorHex: opt.hex,
                            verseText: verse.text,
                          );

                          if (context.mounted && isNowHighlighted) {
                            SaveToCollectionSheet.show(
                              context,
                              bookId: bookId,
                              bookName: bookName,
                              chapter: chapter,
                              verse: verse,
                              colorHex: opt.hex,
                            );
                          }
                        },
                      );
                      return;
                    }

                    Navigator.of(context).pop();

                    final isNowHighlighted = await provider.setVerseHighlight(
                      bookId,
                      chapter,
                      verse.number,
                      colorHex: opt.hex,
                      verseText: verse.text,
                    );

                    if (context.mounted) {
                      if (isNowHighlighted) {
                        SaveToCollectionSheet.show(
                          context,
                          bookId: bookId,
                          bookName: bookName,
                          chapter: chapter,
                          verse: verse,
                          colorHex: opt.hex,
                        );
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$bookName $chapter:${verse.number} highlight removed'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: opt.fill,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? opt.accent : opt.accent.withValues(alpha: 0.35),
                            width: isSelected ? 3.0 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: opt.accent.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isSelected
                              ? Icon(Icons.check_rounded, color: opt.accent, size: 24)
                              : Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: opt.accent.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        opt.name,
                        style: PType.meta.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? PColors.ink : PColors.stone,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            if (isHighlighted) ...[
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  SaveToCollectionSheet.show(
                    context,
                    bookId: bookId,
                    bookName: bookName,
                    chapter: chapter,
                    verse: verse,
                    colorHex: currentColorHex,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: PColors.ink06,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PColors.ink14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bookmark_add_rounded, size: 18, color: PColors.ink),
                      const SizedBox(width: 8),
                      Text(
                        'Guardar en colecciones',
                        style: PType.meta.copyWith(
                          color: PColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
