import 'package:flutter/material.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../domain/models/topic.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return PScreen(
      background: const PScreenBackground.bone(),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutterLight),
      header: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: PColors.ink,
                size: 28,
              ),
            ),
            const Spacer(),
            const Icon(Icons.ios_share_rounded, color: PColors.ink40, size: 20),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          PEyebrow('Topic · ${topic.tag}', color: PColors.stone),
          const SizedBox(height: 12),
          Text(
            topic.title,
            style: PType.display.copyWith(
              color: PColors.ink,
              fontSize: 30,
              height: 1.15,
            ),
          ),
          if (topic.subtitle != null && topic.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              topic.subtitle!,
              style: PType.meta.copyWith(color: PColors.stone, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),

          // ── YouTube Video Preview Card ─────────────────────────────────
          PYoutubePreviewCard(
            youtubeUrl: topic.youtubeUrl,
            youtubeVideoId: topic.youtubeVideoId,
            title: topic.title,
            durationMinutes: topic.videoDurationMinutes,
            height: 210,
          ),
          const SizedBox(height: 24),

          // ── Description ────────────────────────────────────────────────
          Text(
            topic.description,
            style: PType.body.copyWith(color: PColors.ink, height: 1.65),
          ),
          const SizedBox(height: 24),

          // ── Scripture Quote (if present) ───────────────────────────────
          if (topic.scriptureQuote != null &&
              topic.scriptureQuote!.trim().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: PColors.cardFill,
                borderRadius: BorderRadius.circular(PRadius.panel),
                border: Border.all(
                  color: PColors.stone.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${topic.scriptureQuote!.trim()}"',
                    style: PType.scripture.copyWith(
                      color: PColors.ink,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                  if (topic.scriptureReference != null &&
                      topic.scriptureReference!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '— ${topic.scriptureReference!.trim()}',
                      style: PType.meta.copyWith(
                        color: PColors.stone,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── Support Practices / Tips ───────────────────────────────────
          if (topic.supportTips.isNotEmpty) ...[
            PEyebrow('Practise this week', color: PColors.stone),
            const SizedBox(height: 16),
            ...topic.supportTips.asMap().entries.map((e) {
              final num = (e.key + 1).toString().padLeft(2, '0');
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      num,
                      style: PType.meta.copyWith(
                        color: PColors.stone,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        e.value,
                        style: PType.body.copyWith(
                          color: PColors.ink,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
