import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/tokens.dart';

enum ShareCardTheme { ink, bone, dawn }

class ShareVerseSheet extends StatefulWidget {
  const ShareVerseSheet({
    super.key,
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
    this.version = 'RVR1960',
  });

  final String bookName;
  final int chapter;
  final int verseNumber;
  final String verseText;
  final String version;

  static Future<void> show(
    BuildContext context, {
    required String bookName,
    required int chapter,
    required int verseNumber,
    required String verseText,
    String version = 'RVR1960',
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareVerseSheet(
        bookName: bookName,
        chapter: chapter,
        verseNumber: verseNumber,
        verseText: verseText,
        version: version,
      ),
    );
  }

  @override
  State<ShareVerseSheet> createState() => _ShareVerseSheetState();
}

class _ShareVerseSheetState extends State<ShareVerseSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  ShareCardTheme _selectedTheme = ShareCardTheme.ink;
  bool _isGenerating = false;

  Future<void> _shareImage() async {
    setState(() => _isGenerating = true);
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Capture at 3.0 pixel ratio for high-resolution retina export
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/pregare_verse_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      final shareText = '«${widget.verseText}»\n— ${widget.bookName} ${widget.chapter}:${widget.verseNumber} (${widget.version})\n\nLeído en Pregare App';

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: shareText,
        subject: '${widget.bookName} ${widget.chapter}:${widget.verseNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al preparar imagen: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _shareTextOnly() async {
    final shareText = '«${widget.verseText}»\n— ${widget.bookName} ${widget.chapter}:${widget.verseNumber} (${widget.version})\n\nLeído en Pregare App · https://pregare.app';
    await Share.share(
      shareText,
      subject: '${widget.bookName} ${widget.chapter}:${widget.verseNumber}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: PColors.bone,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33141310),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: PColors.ink14,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Compartir versículo',
                    style: GoogleFonts.hankenGrotesk(
                      color: PColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: PColors.ink40, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Theme Selector Chips
              Row(
                children: [
                  _buildThemeChip(
                    label: 'Ink Luxury',
                    theme: ShareCardTheme.ink,
                    color: PColors.inkDeep,
                    textColor: PColors.bone,
                  ),
                  const SizedBox(width: 8),
                  _buildThemeChip(
                    label: 'Bone Editorial',
                    theme: ShareCardTheme.bone,
                    color: PColors.cream,
                    textColor: PColors.ink,
                  ),
                  const SizedBox(width: 8),
                  _buildThemeChip(
                    label: 'Amanecer',
                    theme: ShareCardTheme.dawn,
                    color: const Color(0xFF2E1A1B),
                    textColor: PColors.bone,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Visual Share Card Preview (Wrapped in RepaintBoundary)
              Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: _buildShareCard(),
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _shareImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColors.ink,
                    foregroundColor: PColors.bone,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: PColors.bone,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.ios_share_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Compartir en Redes Sociales',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: _shareTextOnly,
                child: Text(
                  'Compartir solo texto',
                  style: GoogleFonts.hankenGrotesk(
                    color: PColors.ink40,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip({
    required String label,
    required ShareCardTheme theme,
    required Color color,
    required Color textColor,
  }) {
    final isSelected = _selectedTheme == theme;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTheme = theme),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : PColors.ink14,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              color: textColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareCard() {
    final isDark = _selectedTheme == ShareCardTheme.ink;
    final isDawn = _selectedTheme == ShareCardTheme.dawn;

    final bgColor = isDark
        ? PColors.inkDeep
        : (isDawn ? Colors.black : const Color(0xFFFAF8F5));

    final textColor = (isDark || isDawn) ? PColors.bone : PColors.ink;
    final metaColor = (isDark || isDawn) ? PColors.bone62 : PColors.stone;
    final borderColor = (isDark || isDawn)
        ? PColors.hairline
        : const Color(0x1F141310);

    return Container(
      width: 320,
      height: 440,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        image: isDawn
            ? const DecorationImage(
                image: AssetImage('assets/photo-dawn.jpg'),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Dark gradient overlay for Dawn theme
            if (isDawn)
              Container(
                decoration: const BoxDecoration(
                  gradient: PScrims.hero,
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Eyebrow: Reference
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark || isDawn)
                          ? PColors.glassFill
                          : PColors.ink06,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isDark || isDawn) ? PColors.glassStroke : PColors.ink10,
                      ),
                    ),
                    child: Text(
                      '${widget.bookName.toUpperCase()} ${widget.chapter}:${widget.verseNumber} · ${widget.version}',
                      style: GoogleFonts.hankenGrotesk(
                        color: metaColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Center Quotation & Verse Text
                  Text(
                    '“',
                    style: GoogleFonts.newsreader(
                      color: metaColor.withValues(alpha: 0.5),
                      fontSize: 42,
                      height: 0.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.verseText,
                    style: GoogleFonts.newsreader(
                      color: textColor,
                      fontSize: widget.verseText.length > 150 ? 16 : 18,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 7,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(flex: 3),

                  // Divider
                  Container(
                    width: 48,
                    height: 1,
                    color: (isDark || isDawn) ? PColors.hairline : PColors.ink14,
                  ),

                  const SizedBox(height: 16),

                  // Bottom Branding Row: Logo + App Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        (isDark || isDawn)
                            ? 'assets/brand-logo-light.png'
                            : 'assets/brand-logo-dark.png',
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.bookmark_rounded,
                          size: 18,
                          color: PColors.bone,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREGARE',
                            style: GoogleFonts.hankenGrotesk(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            'Oración & Escrituras',
                            style: GoogleFonts.hankenGrotesk(
                              color: metaColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
