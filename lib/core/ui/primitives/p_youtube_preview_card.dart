import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/tokens.dart';

class PYoutubePreviewCard extends StatefulWidget {
  const PYoutubePreviewCard({
    super.key,
    this.youtubeUrl,
    this.youtubeVideoId,
    this.title,
    this.durationMinutes = 8,
    this.height = 200,
  });

  final String? youtubeUrl;
  final String? youtubeVideoId;
  final String? title;
  final int durationMinutes;
  final double height;

  static String? extractVideoId(String? urlOrId) {
    if (urlOrId == null || urlOrId.trim().isEmpty) return null;
    final str = urlOrId.trim();
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(str)) {
      return str;
    }
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/|youtube\.com\/shorts\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(str);
    return match?.group(1);
  }

  @override
  State<PYoutubePreviewCard> createState() => _PYoutubePreviewCardState();
}

class _PYoutubePreviewCardState extends State<PYoutubePreviewCard> {
  bool _isHovered = false;

  String? get videoId =>
      widget.youtubeVideoId ?? PYoutubePreviewCard.extractVideoId(widget.youtubeUrl);

  Future<void> _launchYouTube() async {
    final vId = videoId;
    final targetUrl = widget.youtubeUrl != null && widget.youtubeUrl!.isNotEmpty
        ? widget.youtubeUrl!
        : (vId != null
            ? 'https://www.youtube.com/watch?v=$vId'
            : 'https://www.youtube.com/@PregareApp');

    final uri = Uri.parse(targetUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final vId = videoId;
    final thumbnailUrl =
        vId != null ? 'https://img.youtube.com/vi/$vId/hqdefault.jpg' : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _launchYouTube,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          decoration: BoxDecoration(
            color: PColors.glassFill,
            borderRadius: BorderRadius.circular(PRadius.panel),
            border: Border.all(
              color: _isHovered ? PColors.bone : PColors.glassStroke,
              width: 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: PColors.ink.withValues(alpha: 0.6),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background Thumbnail or Fallback ─────────────────────────
              if (thumbnailUrl != null)
                Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: PColors.inkDeep,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: PColors.bone50,
                        size: 48,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  color: PColors.inkDeep,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.ondemand_video_rounded,
                          color: PColors.bone50,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PREGARE · YouTube Series',
                          style: PType.meta.copyWith(color: PColors.bone50),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Gradient Scrim ───────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      PColors.ink.withValues(alpha: 0.25),
                      PColors.ink.withValues(alpha: _isHovered ? 0.65 : 0.45),
                    ],
                  ),
                ),
              ),

              // ── YouTube & Channel Badge (Top Left) ────────────────────────
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: PColors.ink.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(PRadius.chip),
                    border: Border.all(color: PColors.hairline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF0000), // YouTube red
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PREGARE · YouTube',
                        style: PType.meta.copyWith(
                          color: PColors.bone,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Duration Badge (Bottom Right) ────────────────────────────
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PColors.ink.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(PRadius.chip),
                    border: Border.all(color: PColors.hairline),
                  ),
                  child: Text(
                    '${widget.durationMinutes} min',
                    style: PType.meta.copyWith(
                      color: PColors.bone,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              // ── Center Play Button ───────────────────────────────────────
              Center(
                child: AnimatedScale(
                  scale: _isHovered ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PColors.ink.withValues(alpha: 0.75),
                      border: Border.all(color: PColors.bone, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: PColors.ink.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: PColors.bone,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
