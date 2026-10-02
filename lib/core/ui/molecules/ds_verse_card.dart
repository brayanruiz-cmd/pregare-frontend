import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// YouVersion style verse card with nature image background, bold title,
/// Newsreader serif verse text, and interactive action buttons at the bottom.
class DSVerseCard extends StatefulWidget {
  const DSVerseCard({
    super.key,
    required this.text,
    required this.reference,
    required this.version,
    this.onFavorite,
    this.onShare,
    this.isFavorited = false,
  });

  final String text;
  final String reference;
  final String version;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isFavorited;

  @override
  State<DSVerseCard> createState() => _DSVerseCardState();
}

class _DSVerseCardState extends State<DSVerseCard> {
  late bool _isLiked;
  int _likeCount = 1420000;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isFavorited;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
    widget.onFavorite?.call();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.', ',')} M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.', ',')} k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // ── Background Nature Image ──────────────────────────────────────
            Positioned.fill(
              child: Image.network(
                'verse_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback dark gradient if image fails to load
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF3B2D20), Color(0xFF181512)],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Gradient Overlay for Legibility ─────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 0.85, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ),

            // ── Card Content ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle: Versículo del Día
                  Text(
                    'Versículo del Día',
                    style: AppTypography.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Book & Chapter Reference Header
                  Text(
                    '${widget.reference} ${widget.version}',
                    style: AppTypography.verseReference.copyWith(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Main Verse Quote in Newsreader Serif Font
                  Text(
                    widget.text,
                    style: AppTypography.verseTextLarge.copyWith(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Bottom Metrics / Actions Row (YouVersion style) ──────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Like
                      _MetricActionButton(
                        icon: _isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        iconColor: _isLiked ? const Color(0xFFEF4444) : Colors.white,
                        label: _formatCount(_likeCount),
                        onTap: _toggleLike,
                      ),

                      // Comment
                      _MetricActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: Colors.white,
                        label: '26,4 k',
                        onTap: () {},
                      ),

                      // Share
                      _MetricActionButton(
                        icon: Icons.ios_share_rounded,
                        iconColor: Colors.white,
                        label: '538,7 k',
                        onTap: widget.onShare,
                      ),

                      // More
                      _MetricActionButton(
                        icon: Icons.more_horiz_rounded,
                        iconColor: Colors.white,
                        label: 'Más',
                        onTap: () {},
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

class _MetricActionButton extends StatelessWidget {
  const _MetricActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
