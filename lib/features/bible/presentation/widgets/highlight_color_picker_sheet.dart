import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/molecules/auth_prompt_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/highlight_color_option.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/verse_popularity.dart';
import '../providers/bible_provider.dart';
import 'save_to_collection_sheet.dart';
import 'share_verse_sheet.dart';

/// Bottom modal sheet / dialog to choose a highlight color for a Bible verse
/// and show community popularity feedback ("Subrayado por X personas").
class _HighlightResult {
  final String? colorHex;
  final bool shouldOpenCollections;
  final bool removed;

  const _HighlightResult({
    this.colorHex,
    this.shouldOpenCollections = false,
    this.removed = false,
  });
}

class HighlightColorPickerSheet extends StatefulWidget {
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
  }) async {
    final result = await showModalBottomSheet<_HighlightResult>(
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

    if (!context.mounted || result == null) return;

    if (result.removed) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$bookName $chapter:${verse.number} subrayado removido',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (result.shouldOpenCollections) {
      SaveToCollectionSheet.show(
        context,
        bookId: bookId,
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        colorHex: result.colorHex,
      );
    }
  }

  @override
  State<HighlightColorPickerSheet> createState() => _HighlightColorPickerSheetState();
}

class _HighlightColorPickerSheetState extends State<HighlightColorPickerSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BibleProvider>().fetchVersePopularity(
              widget.bookId,
              widget.chapter,
              widget.verse.number,
            );
      }
    });
  }

  Widget _buildPopularityBadge(VersePopularity? popularity) {
    if (popularity == null) {
      return const SizedBox.shrink();
    }

    final bool hasCount = popularity.count > 0;
    final bool isPopular = popularity.isPopular;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: isPopular
            ? (popularity.tier >= 2 ? const Color(0xFFFFF9EE) : const Color(0xFFFBF8F2))
            : PColors.ink06,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPopular
              ? (popularity.tier >= 2
                  ? const Color(0xFFE5A93C).withValues(alpha: 0.6)
                  : const Color(0xFFD4AF37).withValues(alpha: 0.35))
              : PColors.ink14,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            popularity.tier >= 2
                ? Icons.local_fire_department_rounded
                : (popularity.tier == 1
                    ? Icons.auto_awesome_rounded
                    : (hasCount ? Icons.people_outline_rounded : Icons.bookmark_border_rounded)),
            size: 14,
            color: isPopular
                ? (popularity.tier >= 2 ? const Color(0xFFD97706) : const Color(0xFFB58D3D))
                : PColors.stone,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              popularity.label.isNotEmpty
                  ? popularity.label
                  : 'Sé de los primeros en resaltar este versículo',
              style: PType.meta.copyWith(
                color: isPopular
                    ? (popularity.tier >= 2 ? const Color(0xFF92400E) : const Color(0xFF785B1B))
                    : PColors.stone,
                fontSize: 11.5,
                fontWeight: isPopular ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleProvider>();
    final isHighlighted = provider.isVerseHighlighted(widget.bookId, widget.chapter, widget.verse.number);
    final currentColorHex = provider.getVerseHighlightColor(widget.bookId, widget.chapter, widget.verse.number);
    final popularity = provider.getVersePopularity(widget.bookId, widget.chapter, widget.verse.number);

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
                        '${widget.bookName} ${widget.chapter}:${widget.verse.number}',
                        style: PType.rowTitle.copyWith(
                          fontSize: 18,
                          color: PColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.verse.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PType.body.copyWith(
                          color: PColors.stone,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      _buildPopularityBadge(popularity),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ShareVerseSheet.show(
                      context,
                      bookName: widget.bookName,
                      chapter: widget.chapter,
                      verseNumber: widget.verse.number,
                      verseText: widget.verse.text,
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

            const SizedBox(height: 18),

            // Title for color swatches
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COLOR DE SUBRAYADO',
                  style: PType.eyebrow.copyWith(
                    color: PColors.stone,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isHighlighted)
                  GestureDetector(
                    onTap: () async {
                      await provider.removeVerseHighlight(widget.bookId, widget.chapter, widget.verse.number);
                      if (context.mounted) {
                        Navigator.of(context).pop(const _HighlightResult(removed: true));
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
                          'Quitar',
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
                            widget.bookId,
                            widget.chapter,
                            widget.verse.number,
                            colorHex: opt.hex,
                            verseText: widget.verse.text,
                          );

                          if (context.mounted && isNowHighlighted) {
                            SaveToCollectionSheet.show(
                              context,
                              bookId: widget.bookId,
                              bookName: widget.bookName,
                              chapter: widget.chapter,
                              verse: widget.verse,
                              colorHex: opt.hex,
                            );
                          }
                        },
                      );
                      return;
                    }

                    final isNowHighlighted = await provider.setVerseHighlight(
                      widget.bookId,
                      widget.chapter,
                      widget.verse.number,
                      colorHex: opt.hex,
                      verseText: widget.verse.text,
                    );

                    if (context.mounted) {
                      if (isNowHighlighted) {
                        // If it's a popular verse, show motivational feedback
                        final updatedPop = provider.getVersePopularity(
                          widget.bookId,
                          widget.chapter,
                          widget.verse.number,
                        );

                        if (updatedPop != null && updatedPop.isPopular) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    updatedPop.tier >= 2
                                        ? Icons.local_fire_department_rounded
                                        : Icons.auto_awesome_rounded,
                                    color: const Color(0xFFF59E0B),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '¡Te uniste a ${updatedPop.count} personas que destacaron este versículo!',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF1E293B),
                            ),
                          );
                        }

                        Navigator.of(context).pop(
                          _HighlightResult(
                            colorHex: opt.hex,
                            shouldOpenCollections: true,
                          ),
                        );
                      } else {
                        Navigator.of(context).pop(const _HighlightResult(removed: true));
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
                  Navigator.of(context).pop(
                    _HighlightResult(
                      colorHex: currentColorHex,
                      shouldOpenCollections: true,
                    ),
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
