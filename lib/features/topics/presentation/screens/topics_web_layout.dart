import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/state/async_state.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/ui/primitives/primitives.dart';
import '../providers/topics_provider.dart';
import '../../domain/models/topic.dart';

/// Web layout for Topics adhering to PREGARE tokens.
class TopicsWebLayout extends StatefulWidget {
  const TopicsWebLayout({super.key});

  @override
  State<TopicsWebLayout> createState() => _TopicsWebLayoutState();
}

class _TopicsWebLayoutState extends State<TopicsWebLayout> {
  Topic? _selectedTopic;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TopicsProvider>();
    final topics = provider.currentTopics;

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
                        Text('Topics', style: PType.display.copyWith(fontSize: 26)),
                        const SizedBox(height: 4),
                        const PEyebrow('Themes & video practice'),
                      ],
                    ),
                  ),
                  const Divider(color: PColors.hairline, height: 1),
                  Expanded(
                    child: provider.topics is AsyncLoading || provider.topics is AsyncInitial
                        ? const Center(child: CircularProgressIndicator(color: PColors.bone))
                        : provider.topics is AsyncError
                            ? Center(
                                child: GestureDetector(
                                  onTap: () => provider.loadTopics(),
                                  child: Text('Retry', style: PType.uiStrong),
                                ),
                              )
                            : topics.isEmpty
                                ? const Center(
                                    child: PEyebrow('No topics available'),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    itemCount: topics.length,
                                    itemBuilder: (context, index) {
                                      final topic = topics[index];
                                      final isSelected = _selectedTopic?.id == topic.id;
                                      return _TopicListTile(
                                        topic: topic,
                                        isSelected: isSelected,
                                        onTap: () => setState(() => _selectedTopic = topic),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),

            // ─── Right panel: detail ───
            Expanded(
              child: _selectedTopic == null
                  ? _TopicEmptyDetail()
                  : _TopicDetail(
                      topic: _selectedTopic!,
                      onYouTube: () => provider.openYouTube(_selectedTopic!.youtubeQuery),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicListTile extends StatelessWidget {
  const _TopicListTile({
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  final Topic topic;
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? PColors.bone : PColors.glassFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 20,
                  color: isSelected ? PColors.ink : PColors.bone70,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: PType.rowTitle.copyWith(
                        fontSize: 14,
                        color: isSelected ? PColors.bone : PColors.bone70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(topic.tag, style: PType.meta),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicEmptyDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_outlined, size: 56, color: PColors.bone45),
          const SizedBox(height: 16),
          const PEyebrow('Select a topic'),
          const SizedBox(height: 6),
          Text('Choose a topic from the list to view reflection and practice.', style: PType.body),
        ],
      ),
    );
  }
}

class _TopicDetail extends StatelessWidget {
  const _TopicDetail({required this.topic, required this.onYouTube});

  final Topic topic;
  final VoidCallback onYouTube;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag
          PEyebrow('Topic · ${topic.tag}'),
          const SizedBox(height: 12),

          // Title
          Text(topic.title, style: PType.display.copyWith(fontSize: 32)),
          const SizedBox(height: 24),

          // Video Card
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(PRadius.panel),
              border: Border.all(color: PColors.hairline),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onYouTube,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: PColors.bone,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, size: 36, color: PColors.ink),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Watch Video Practice', style: PType.uiStrong),
                const SizedBox(height: 6),
                Text('Click to open and watch on YouTube', style: PType.meta),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // CTA Button
          GestureDetector(
            onTap: onYouTube,
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PColors.bone,
                borderRadius: BorderRadius.circular(PRadius.pill),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.open_in_new, size: 18, color: PColors.ink),
                  const SizedBox(width: 8),
                  Text('Open on YouTube', style: PType.uiStrong.copyWith(color: PColors.ink)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
