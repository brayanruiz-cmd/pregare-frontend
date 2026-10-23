import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../../core/state/async_state.dart';
import '../../../topics/domain/models/topic.dart';
import '../../../devotionals/domain/models/devotional.dart';
import '../../../topics/presentation/providers/topics_provider.dart';
import '../../../devotionals/presentation/providers/devotionals_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../onboarding/domain/models/focus_area.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _activeTab = 0; // 0: Topics, 1: Devotionals, 2: Strengths, 3: Overview
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAll();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await context.read<AdminProvider>().loadAll();
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados desde MySQL'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final topicsCount = admin.currentTopics.length;
    final devotionalsCount = admin.currentDevotionals.length;
    final strengthsCount = admin.currentFocusAreas.length;

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: EdgeInsets.zero,
      header: Container(
        padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x22F4F2EC), width: 0.8)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Row(
              children: [
                // Back Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(PRadius.chip),
                    onTap: () {
                      context.read<TopicsProvider>().loadTopics();
                      context.read<DevotionalsProvider>().loadDevotionals();
                      context.read<HomeProvider>().loadHomeData();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1C18),
                        borderRadius: BorderRadius.circular(PRadius.chip),
                        border: Border.all(color: const Color(0x28F4F2EC)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_rounded, color: PColors.bone, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'App',
                            style: PType.uiStrong.copyWith(color: PColors.bone, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Studio Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x258A6A4E),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0x458A6A4E)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE8C59A), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'PREGARE STUDIO',
                        style: PType.eyebrow.copyWith(
                          color: const Color(0xFFE8C59A),
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Live MySQL Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1834D399),
                    borderRadius: BorderRadius.circular(PRadius.pill),
                    border: Border.all(color: const Color(0x4034D399)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34D399),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'MySQL 3306',
                        style: PType.meta.copyWith(
                          color: const Color(0xFF34D399),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Refresh Button
                IconButton(
                  tooltip: 'Sincronizar datos',
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: PColors.bone,
                          ),
                        )
                      : const Icon(Icons.sync_rounded, color: PColors.bone70, size: 20),
                  onPressed: _isRefreshing ? null : _handleRefresh,
                ),

                // Admin Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PColors.clay.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(PRadius.chip),
                    border: Border.all(color: PColors.clay.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    'ADMIN',
                    style: PType.meta.copyWith(
                      color: const Color(0xFFE8C59A),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),

                // ── Studio Title & Description ────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Content Manager',
                            style: PType.greeting.copyWith(
                              fontSize: 32,
                              color: PColors.bone,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Administra series bíblicas vinculadas a YouTube, devocionales diarios y fortalezas espirituales.',
                            style: PType.body.copyWith(
                              color: PColors.bone70,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Segmented Tab Selector ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1A17),
                    borderRadius: BorderRadius.circular(PRadius.pill),
                    border: Border.all(color: const Color(0x33F4F2EC), width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        title: 'Series & YouTube',
                        badgeCount: topicsCount,
                        icon: Icons.ondemand_video_rounded,
                        isSelected: _activeTab == 0,
                        onTap: () => setState(() => _activeTab = 0),
                      ),
                      _TabButton(
                        title: 'Devocionales',
                        badgeCount: devotionalsCount,
                        icon: Icons.menu_book_rounded,
                        isSelected: _activeTab == 1,
                        onTap: () => setState(() => _activeTab = 1),
                      ),
                      _TabButton(
                        title: 'Fortalezas',
                        badgeCount: strengthsCount,
                        icon: Icons.auto_awesome_rounded,
                        isSelected: _activeTab == 2,
                        onTap: () => setState(() => _activeTab = 2),
                      ),
                      _TabButton(
                        title: 'Overview',
                        badgeCount: null,
                        icon: Icons.dashboard_outlined,
                        isSelected: _activeTab == 3,
                        onTap: () => setState(() => _activeTab = 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── Tab Content ───────────────────────────────────────────────
                Expanded(
                  child: IndexedStack(
                    index: _activeTab,
                    children: const [
                      _TopicsTab(),
                      _DevotionalsTab(),
                      _FocusAreasTab(),
                      _OverviewTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB BUTTON COMPONENT
// ─────────────────────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
    this.icon,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? PColors.bone : Colors.transparent,
            borderRadius: BorderRadius.circular(PRadius.pill),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x25000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? PColors.ink : PColors.bone62,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: PType.uiStrong.copyWith(
                    color: isSelected ? PColors.ink : PColors.bone70,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (badgeCount != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? PColors.ink.withValues(alpha: 0.12)
                        : const Color(0x358A6A4E),
                    borderRadius: BorderRadius.circular(PRadius.chip),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? PColors.ink : const Color(0xFFE8C59A),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: TOPICS & YOUTUBE VIDEOS
// ─────────────────────────────────────────────────────────────────────────────
class _TopicsTab extends StatelessWidget {
  const _TopicsTab();

  void _openTopicForm(BuildContext context, [Topic? topic]) {
    final isDesktop = MediaQuery.of(context).size.width > 680;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: const Color(0xFF161513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRadius.panel),
            side: const BorderSide(color: Color(0x33F4F2EC), width: 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
            child: _TopicFormSheet(topic: topic, isDialog: true),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF161513),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(PRadius.panel)),
        ),
        builder: (_) => _TopicFormSheet(topic: topic),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final topics = admin.currentTopics;

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                PEyebrow('SERIES PUBLICADAS (${topics.length})'),
                const SizedBox(width: 8),
                Text(
                  '· Conexión directa a canal YouTube',
                  style: PType.meta.copyWith(color: PColors.bone50, fontSize: 11),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(PRadius.pill),
                onTap: () => _openTopicForm(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: PColors.bone,
                    borderRadius: BorderRadius.circular(PRadius.pill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: PColors.ink, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Nueva Serie',
                        style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (admin.topics is AsyncLoading && topics.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(color: PColors.bone),
            ),
          )
        else if (topics.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1916),
              borderRadius: BorderRadius.circular(PRadius.panel),
              border: Border.all(color: const Color(0x28F4F2EC)),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.video_library_outlined, color: PColors.bone50, size: 52),
                  const SizedBox(height: 14),
                  Text(
                    'No hay series registradas',
                    style: PType.greeting.copyWith(fontSize: 22, color: PColors.bone),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Añade tu primera serie con video de YouTube y prácticas espirituales.',
                    style: PType.body.copyWith(color: PColors.bone70, fontSize: 13.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...topics.map((t) {
            return _TopicCard(
              topic: t,
              onEdit: () => _openTopicForm(context, t),
              onDelete: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1C18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PRadius.panel),
                      side: const BorderSide(color: Color(0x30F4F2EC)),
                    ),
                    title: Text(
                      '¿Eliminar serie?',
                      style: PType.greeting.copyWith(fontSize: 20, color: PColors.bone),
                    ),
                    content: Text(
                      '¿Estás seguro de que deseas eliminar la serie "${t.title}" de MySQL?',
                      style: PType.body.copyWith(color: PColors.bone70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancelar',
                          style: PType.meta.copyWith(color: PColors.bone70),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final topicId = t.uuid ?? t.id.toString();
                  await admin.deleteTopic(topicId);
                  if (context.mounted) {
                    context.read<TopicsProvider>().loadTopics();
                    context.read<HomeProvider>().loadHomeData();
                  }
                }
              },
            );
          }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOPIC CARD COMPONENT (Rich Luxury Card)
// ─────────────────────────────────────────────────────────────────────────────
class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.onEdit,
    required this.onDelete,
  });

  final Topic topic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasVideo = topic.youtubeVideoId != null || (topic.youtubeUrl != null && topic.youtubeUrl!.isNotEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1A17),
        borderRadius: BorderRadius.circular(PRadius.panel),
        border: Border.all(color: const Color(0x30F4F2EC), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Optional YouTube Card Header ─────────────────────────────────
          if (hasVideo)
            PYoutubePreviewCard(
              youtubeUrl: topic.youtubeUrl,
              youtubeVideoId: topic.youtubeVideoId,
              title: topic.title,
              durationMinutes: topic.videoDurationMinutes,
              height: 190,
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Metadata & Action Buttons Row ────────────────────────
                Row(
                  children: [
                    // Tag Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0x2A8A6A4E),
                        borderRadius: BorderRadius.circular(PRadius.chip),
                        border: Border.all(color: const Color(0x668A6A4E)),
                      ),
                      child: Text(
                        topic.tag.toUpperCase(),
                        style: PType.meta.copyWith(
                          color: const Color(0xFFE8C59A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Duration Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x18FFFFFF),
                        borderRadius: BorderRadius.circular(PRadius.chip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 13, color: PColors.bone62),
                          const SizedBox(width: 4),
                          Text(
                            '${topic.videoDurationMinutes} min',
                            style: PType.meta.copyWith(color: PColors.bone62, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Edit Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(PRadius.chip),
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0x18FFFFFF),
                            borderRadius: BorderRadius.circular(PRadius.chip),
                            border: Border.all(color: const Color(0x20FFFFFF)),
                          ),
                          child: const Icon(Icons.edit_outlined, color: PColors.bone, size: 17),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(PRadius.chip),
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0x18E53935),
                            borderRadius: BorderRadius.circular(PRadius.chip),
                            border: Border.all(color: const Color(0x35E53935)),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFFF6B6B),
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Topic Title (CRISP & LEGIBLE BONE COLOR) ──────────────────
                Text(
                  topic.title,
                  style: PType.greeting.copyWith(
                    fontSize: 22,
                    color: PColors.bone,
                    fontWeight: FontWeight.w300,
                    height: 1.2,
                  ),
                ),

                if (topic.subtitle != null && topic.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    topic.subtitle!,
                    style: PType.meta.copyWith(
                      color: const Color(0xFFC7A786),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // ── Topic Description ─────────────────────────────────────────
                Text(
                  topic.description,
                  style: PType.body.copyWith(
                    color: PColors.bone70,
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                // ── Scripture Quote Block (if exists) ─────────────────────────
                if (topic.scriptureQuote != null && topic.scriptureQuote!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x24141310),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(color: Color(0xFFE8C59A), width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“${topic.scriptureQuote!.trim()}”',
                          style: PType.scripture.copyWith(
                            fontSize: 13.5,
                            color: PColors.bone85,
                            fontStyle: FontStyle.italic,
                            height: 1.45,
                          ),
                        ),
                        if (topic.scriptureReference != null && topic.scriptureReference!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            topic.scriptureReference!,
                            style: PType.meta.copyWith(
                              color: const Color(0xFFE8C59A),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(color: Color(0x18F4F2EC), height: 1),
                const SizedBox(height: 12),

                // ── Footer: Weekly Practices Bar ──────────────────────────────
                Row(
                  children: [
                    const Icon(
                      Icons.task_alt_rounded,
                      color: Color(0xFFE8C59A),
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${topic.supportTips.length} prácticas semanales configuradas',
                      style: PType.meta.copyWith(
                        color: PColors.bone85,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (topic.youtubeQuery.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_rounded, size: 14, color: PColors.bone50),
                          const SizedBox(width: 4),
                          Text(
                            topic.youtubeQuery,
                            style: PType.meta.copyWith(color: PColors.bone50, fontSize: 11),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOPIC FORM SHEET & DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class _TopicFormSheet extends StatefulWidget {
  const _TopicFormSheet({this.topic, this.isDialog = false});
  final Topic? topic;
  final bool isDialog;

  @override
  State<_TopicFormSheet> createState() => _TopicFormSheetState();
}

class _TopicFormSheetState extends State<_TopicFormSheet> {
  late TextEditingController _urlCtrl;
  late TextEditingController _tagCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _scriptureQuoteCtrl;
  late TextEditingController _scriptureRefCtrl;
  late List<TextEditingController> _tipsControllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.topic;
    _urlCtrl = TextEditingController(text: t?.youtubeUrl ?? '');
    _tagCtrl = TextEditingController(text: t?.tag ?? 'Ansiedad');
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _subtitleCtrl = TextEditingController(text: t?.subtitle ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _scriptureQuoteCtrl = TextEditingController(text: t?.scriptureQuote ?? '');
    _scriptureRefCtrl = TextEditingController(text: t?.scriptureReference ?? '');

    final existingTips = t?.supportTips ?? [];
    if (existingTips.isNotEmpty) {
      _tipsControllers = existingTips.map((tip) => TextEditingController(text: tip)).toList();
    } else {
      _tipsControllers = [
        TextEditingController(text: 'Escribe tu preocupación principal antes de orar'),
        TextEditingController(text: 'Repite el versículo guía en voz alta tres veces'),
        TextEditingController(text: 'Entrega en silencio cada pensamiento antes de acostarte'),
      ];
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _tagCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _descCtrl.dispose();
    _scriptureQuoteCtrl.dispose();
    _scriptureRefCtrl.dispose();
    for (var c in _tipsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTip() {
    setState(() {
      _tipsControllers.add(TextEditingController());
    });
  }

  void _removeTip(int index) {
    if (_tipsControllers.length > 1) {
      setState(() {
        _tipsControllers.removeAt(index).dispose();
      });
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PColors.bone45, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF1E1C18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0x30F4F2EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0x30F4F2EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0xFFE8C59A), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.topic == null ? 'Nueva Serie de Tema' : 'Editar Serie de Tema',
                    style: PType.greeting.copyWith(fontSize: 22, color: PColors.bone),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vincula a YouTube y define prácticas prácticas para la comunidad.',
                    style: PType.meta.copyWith(color: PColors.bone62, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: PColors.bone70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Color(0x24F4F2EC), height: 24),
          Expanded(
            child: ListView(
              children: [
                // ── YouTube URL Input ──────────────────────────────────────────
                const PEyebrow('URL o ID del Video de YouTube'),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('https://www.youtube.com/watch?v=...').copyWith(
                    prefixIcon: const Icon(Icons.play_circle_fill_rounded, color: Colors.redAccent),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),

                // ── Live Video Preview Card ──────────────────────────────────
                if (_urlCtrl.text.isNotEmpty) ...[
                  const PEyebrow('Vista Previa en Vivo'),
                  const SizedBox(height: 8),
                  PYoutubePreviewCard(
                    youtubeUrl: _urlCtrl.text,
                    title: _titleCtrl.text.isNotEmpty ? _titleCtrl.text : 'Video Preview',
                    height: 180,
                  ),
                  const SizedBox(height: 18),
                ],

                // ── Tag & Title ────────────────────────────────────────────────
                const PEyebrow('Categoría / Tag'),
                const SizedBox(height: 8),
                TextField(
                  controller: _tagCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Ansiedad, Propósito, Ángeles'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Título de la Serie'),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Cuando el afán no te deja dormir'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Subtítulo o Duración'),
                const SizedBox(height: 8),
                TextField(
                  controller: _subtitleCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. 3 prácticas para los días de afán · 8 min video'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Descripción'),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('Descripción editorial de la serie...'),
                ),
                const SizedBox(height: 16),

                // ── Scripture Anchor ───────────────────────────────────────────
                const PEyebrow('Pasaje Bíblico Clave (Cita y Referencia)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _scriptureQuoteCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('Texto del versículo...'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _scriptureRefCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('Referencia: e.g. 1 Pedro 5:7'),
                ),
                const SizedBox(height: 24),

                // ── Weekly Practices ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PEyebrow('Pasos Prácticos de la Semana'),
                    TextButton.icon(
                      onPressed: _addTip,
                      icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFFE8C59A)),
                      label: Text(
                        'Añadir Paso',
                        style: PType.uiStrong.copyWith(color: const Color(0xFFE8C59A), fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(_tipsControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0x358A6A4E),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFFE8C59A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _tipsControllers[index],
                            style: const TextStyle(color: PColors.bone, fontSize: 13),
                            decoration: _inputDecoration('Instrucción práctica...'),
                          ),
                        ),
                        if (_tipsControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _removeTip(index),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // ── Save Button ────────────────────────────────────────────────
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(PRadius.pill),
                    onTap: _isSaving
                        ? null
                        : () async {
                            if (_titleCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor ingresa un título')),
                              );
                              return;
                            }

                            setState(() => _isSaving = true);
                            final admin = context.read<AdminProvider>();
                            final topicsProv = context.read<TopicsProvider>();
                            final homeProv = context.read<HomeProvider>();
                            final nav = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final tips = _tipsControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

                            final ok = await admin.saveTopic(
                              id: widget.topic?.uuid ?? widget.topic?.id.toString(),
                              tag: _tagCtrl.text.trim(),
                              title: _titleCtrl.text.trim(),
                              subtitle: _subtitleCtrl.text.trim(),
                              description: _descCtrl.text.trim(),
                              scriptureQuote: _scriptureQuoteCtrl.text.trim(),
                              scriptureReference: _scriptureRefCtrl.text.trim(),
                              youtubeUrl: _urlCtrl.text.trim(),
                              supportTips: tips,
                            );

                            setState(() => _isSaving = false);
                            if (ok) {
                              topicsProv.loadTopics();
                              homeProv.loadHomeData();
                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Serie guardada con éxito en MySQL')),
                              );
                            }
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: PColors.bone,
                        borderRadius: BorderRadius.circular(PRadius.pill),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: PColors.ink)
                          : Text(
                              widget.topic == null ? 'Publicar Serie' : 'Guardar Cambios',
                              style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 15),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: DEVOTIONALS MANAGER
// ─────────────────────────────────────────────────────────────────────────────
class _DevotionalsTab extends StatefulWidget {
  const _DevotionalsTab();

  @override
  State<_DevotionalsTab> createState() => _DevotionalsTabState();
}

class _DevotionalsTabState extends State<_DevotionalsTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openDevotionalForm(BuildContext context, [Devotional? dev]) {
    final isDesktop = MediaQuery.of(context).size.width > 680;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: const Color(0xFF161513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRadius.panel),
            side: const BorderSide(color: Color(0x33F4F2EC), width: 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
            child: _DevotionalFormSheet(devotional: dev, isDialog: true),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF161513),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(PRadius.panel)),
        ),
        builder: (_) => _DevotionalFormSheet(devotional: dev),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final allDevotionals = admin.currentDevotionals;

    final devotionals = _filter.isEmpty
        ? allDevotionals
        : allDevotionals.where((d) {
            return d.title.toLowerCase().contains(_filter.toLowerCase()) ||
                d.verse.toLowerCase().contains(_filter.toLowerCase()) ||
                d.day.toString().contains(_filter);
          }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        // ── Header Actions ────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PEyebrow('DEVOCIONALES DIARIOS (${allDevotionals.length} / 365)'),
                const SizedBox(height: 3),
                Text(
                  'Días programados para el año',
                  style: PType.meta.copyWith(color: PColors.bone50, fontSize: 11),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(PRadius.pill),
                onTap: () => _openDevotionalForm(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: PColors.bone,
                    borderRadius: BorderRadius.circular(PRadius.pill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: PColors.ink, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Nuevo Devocional',
                        style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Search & Filter ───────────────────────────────────────────────────
        TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: PColors.bone, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Buscar por día, título o versículo...',
            hintStyle: const TextStyle(color: PColors.bone45, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF1B1A17),
            prefixIcon: const Icon(Icons.search_rounded, color: PColors.bone50, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PRadius.pill),
              borderSide: const BorderSide(color: Color(0x25F4F2EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PRadius.pill),
              borderSide: const BorderSide(color: Color(0x25F4F2EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PRadius.pill),
              borderSide: const BorderSide(color: Color(0xFFE8C59A)),
            ),
          ),
          onChanged: (v) => setState(() => _filter = v.trim()),
        ),
        const SizedBox(height: 16),

        if (admin.devotionals is AsyncLoading && allDevotionals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(color: PColors.bone),
            ),
          )
        else if (devotionals.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1916),
              borderRadius: BorderRadius.circular(PRadius.panel),
              border: Border.all(color: const Color(0x28F4F2EC)),
            ),
            alignment: Alignment.center,
            child: Text(
              _filter.isEmpty ? 'No hay devocionales cargados' : 'No se encontraron resultados para "$_filter"',
              style: PType.body.copyWith(color: PColors.bone70),
            ),
          )
        else
          ...devotionals.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1A17),
                borderRadius: BorderRadius.circular(PRadius.panel),
                border: Border.all(color: const Color(0x28F4F2EC)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Day Medallion
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0x2A8A6A4E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x558A6A4E)),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'DÍA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xFFE8C59A),
                          ),
                        ),
                        Text(
                          '${d.day}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE8C59A),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title & Verse Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.title,
                          style: PType.greeting.copyWith(
                            fontSize: 18,
                            color: PColors.bone,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          d.verse,
                          style: PType.meta.copyWith(
                            color: PColors.bone70,
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Edit Action
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: PColors.bone, size: 18),
                    onPressed: () => _openDevotionalForm(context, d),
                  ),

                  // Delete Action
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B), size: 18),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1C18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PRadius.panel),
                            side: const BorderSide(color: Color(0x30F4F2EC)),
                          ),
                          title: Text(
                            '¿Eliminar devocional?',
                            style: PType.greeting.copyWith(fontSize: 20, color: PColors.bone),
                          ),
                          content: Text(
                            '¿Eliminar Día ${d.day} "${d.title}" de MySQL?',
                            style: PType.body.copyWith(color: PColors.bone70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancelar', style: PType.meta.copyWith(color: PColors.bone70)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final devId = d.uuid ?? d.id.toString();
                        await admin.deleteDevotional(devId);
                        if (context.mounted) {
                          context.read<DevotionalsProvider>().loadDevotionals();
                          context.read<HomeProvider>().loadHomeData();
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEVOTIONAL FORM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _DevotionalFormSheet extends StatefulWidget {
  const _DevotionalFormSheet({this.devotional, this.isDialog = false});
  final Devotional? devotional;
  final bool isDialog;

  @override
  State<_DevotionalFormSheet> createState() => _DevotionalFormSheetState();
}

class _DevotionalFormSheetState extends State<_DevotionalFormSheet> {
  late TextEditingController _dayCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _verseCtrl;
  late TextEditingController _verseRefCtrl;
  late TextEditingController _reflectionCtrl;
  late TextEditingController _prayerCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.devotional;
    _dayCtrl = TextEditingController(text: d?.day.toString() ?? '1');
    _titleCtrl = TextEditingController(text: d?.title ?? '');
    final cleanVerse = d?.cleanVerseText ?? '';
    _verseCtrl = TextEditingController(text: cleanVerse.isNotEmpty ? cleanVerse : (d?.verse ?? ''));
    _verseRefCtrl = TextEditingController(text: d?.effectiveVerseReference ?? (d?.verseReference ?? ''));
    _reflectionCtrl = TextEditingController(text: d?.text ?? '');
    _prayerCtrl = TextEditingController(text: d?.prayer ?? '');
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _titleCtrl.dispose();
    _verseCtrl.dispose();
    _verseRefCtrl.dispose();
    _reflectionCtrl.dispose();
    _prayerCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PColors.bone45, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF1E1C18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0x30F4F2EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0x30F4F2EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0xFFE8C59A), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.devotional == null ? 'Crear Devocional Diario' : 'Editar Devocional',
                style: PType.greeting.copyWith(fontSize: 22, color: PColors.bone),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: PColors.bone70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Color(0x24F4F2EC), height: 24),
          Expanded(
            child: ListView(
              children: [
                const PEyebrow('Número de Día (1 al 365)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _dayCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. 1'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Título'),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Finding Peace in Uncertainty'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Versículo Central'),
                const SizedBox(height: 8),
                TextField(
                  controller: _verseCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. "Y la paz de Dios, que sobrepasa todo entendimiento..."'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Referencia del Versículo'),
                const SizedBox(height: 8),
                TextField(
                  controller: _verseRefCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Filipenses 4:7'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Texto de Reflexión'),
                const SizedBox(height: 8),
                TextField(
                  controller: _reflectionCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('Escribe la reflexión del día...'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Oración Guiada'),
                const SizedBox(height: 8),
                TextField(
                  controller: _prayerCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('Escribe la oración de cierre...'),
                ),
                const SizedBox(height: 26),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(PRadius.pill),
                    onTap: _isSaving
                        ? null
                        : () async {
                            final day = int.tryParse(_dayCtrl.text.trim()) ?? 1;
                            if (_titleCtrl.text.trim().isEmpty || _verseCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor completa el título y el versículo')),
                              );
                              return;
                            }

                            setState(() => _isSaving = true);
                            final admin = context.read<AdminProvider>();
                            final devProv = context.read<DevotionalsProvider>();
                            final homeProv = context.read<HomeProvider>();
                            final nav = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            final ok = await admin.saveDevotional(
                              id: widget.devotional?.uuid ?? widget.devotional?.id.toString(),
                              dayNumber: day,
                              title: _titleCtrl.text.trim(),
                              verseText: _verseCtrl.text.trim(),
                              verseReference: _verseRefCtrl.text.trim(),
                              reflectionText: _reflectionCtrl.text.trim(),
                              prayerText: _prayerCtrl.text.trim(),
                            );

                            setState(() => _isSaving = false);
                            if (ok) {
                              devProv.loadDevotionals();
                              homeProv.loadHomeData();
                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Devocional guardado con éxito')),
                              );
                            }
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: PColors.bone,
                        borderRadius: BorderRadius.circular(PRadius.pill),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: PColors.ink)
                          : Text(
                              widget.devotional == null ? 'Publicar Devocional' : 'Guardar Cambios',
                              style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 15),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: OVERVIEW & STATS
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  Future<void> _launchChannel() async {
    final uri = Uri.parse('https://www.youtube.com/@PregareApp');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final stats = admin.stats is AsyncData ? (admin.stats as AsyncData).data as Map<String, dynamic> : null;

    final usersCount = stats?['totalUsers'] ?? 0;
    final topicsCount = admin.currentTopics.length;
    final devCount = admin.currentDevotionals.length;
    final strengthsCount = admin.currentFocusAreas.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        const PEyebrow('MÉTRICAS Y ESTADO DEL SISTEMA'),
        const SizedBox(height: 16),

        // ── 4 Metric Cards Grid ───────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Usuarios Registrados',
                value: '$usersCount',
                subtitle: 'Cuentas en MySQL',
                icon: Icons.people_outline_rounded,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                title: 'Series con YouTube',
                value: '$topicsCount',
                subtitle: 'Temas activos en App',
                icon: Icons.ondemand_video_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Devocionales',
                value: '$devCount / 365',
                subtitle: '${((devCount / 365) * 100).toStringAsFixed(1)}% del año cubierto',
                icon: Icons.menu_book_rounded,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                title: 'Fortalezas & Áreas',
                value: '$strengthsCount',
                subtitle: 'Disponibles en onboarding',
                icon: Icons.auto_awesome_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Connected YouTube Showcase Card ──────────────────────────────────
        const PEyebrow('CANAL DE YOUTUBE CONECTADO'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1A17),
            borderRadius: BorderRadius.circular(PRadius.panel),
            border: Border.all(color: const Color(0x30F4F2EC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFF141310),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: PBrandLogo(height: 26, isLight: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PREGARE · The Word of God',
                        style: PType.greeting.copyWith(fontSize: 19, color: PColors.bone),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '@PregareApp · Canal Oficial',
                        style: PType.meta.copyWith(color: const Color(0xFFE8C59A)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(PRadius.chip),
                      onTap: _launchChannel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x18FFFFFF),
                          borderRadius: BorderRadius.circular(PRadius.chip),
                          border: Border.all(color: const Color(0x28FFFFFF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.open_in_new_rounded, size: 14, color: PColors.bone),
                            const SizedBox(width: 6),
                            Text('Ver Canal', style: PType.uiStrong.copyWith(color: PColors.bone, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Al publicar nuevas series en este Studio, los miembros de la comunidad podrán reproducir tus videos de YouTube directamente dentro de la aplicación móvil y web, junto a las reflexiones y prácticas espirituales.',
                style: PType.body.copyWith(color: PColors.bone70, fontSize: 13.5, height: 1.55),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// METRIC CARD COMPONENT
// ─────────────────────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1A17),
        borderRadius: BorderRadius.circular(PRadius.panel),
        border: Border.all(color: const Color(0x28F4F2EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: PType.meta.copyWith(color: PColors.bone62, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Color(0x258A6A4E),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFE8C59A), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: PType.greeting.copyWith(
              fontSize: 26,
              color: PColors.bone,
              fontWeight: FontWeight.w300,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: PType.meta.copyWith(color: PColors.bone50, fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STRENGTHS & FOCUS AREAS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _FocusAreasTab extends StatelessWidget {
  const _FocusAreasTab();

  void _openCreateModal(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 680;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: const Color(0xFF161513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRadius.panel),
            side: const BorderSide(color: Color(0x33F4F2EC), width: 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 600),
            child: const _FocusAreaFormModal(),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _FocusAreaFormModal(),
      );
    }
  }

  void _openEditModal(BuildContext context, FocusArea area) {
    final isDesktop = MediaQuery.of(context).size.width > 680;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: const Color(0xFF161513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRadius.panel),
            side: const BorderSide(color: Color(0x33F4F2EC), width: 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 600),
            child: _FocusAreaFormModal(area: area),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _FocusAreaFormModal(area: area),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final areas = admin.currentFocusAreas;

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                PEyebrow('FORTALEZAS & ÁREAS DE ENFOQUE (${areas.length})'),
                const SizedBox(width: 8),
                Text(
                  '· Personalización de oraciones',
                  style: PType.meta.copyWith(color: PColors.bone50, fontSize: 11),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(PRadius.pill),
                onTap: () => _openCreateModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: PColors.bone,
                    borderRadius: BorderRadius.circular(PRadius.pill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: PColors.ink, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Añadir Fortaleza',
                        style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (admin.focusAreas is AsyncLoading && areas.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(color: PColors.bone),
            ),
          )
        else if (areas.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1916),
              borderRadius: BorderRadius.circular(PRadius.panel),
              border: Border.all(color: const Color(0x28F4F2EC)),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.fitness_center_rounded, color: PColors.bone50, size: 40),
                const SizedBox(height: 12),
                Text(
                  'No hay fortalezas registradas en MySQL.',
                  style: PType.body.copyWith(color: PColors.bone70),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => _openCreateModal(context),
                  child: Text(
                    '+ Crear Primera Fortaleza',
                    style: PType.uiStrong.copyWith(color: const Color(0xFFE8C59A)),
                  ),
                ),
              ],
            ),
          )
        else
          ...areas.map((area) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1A17),
                borderRadius: BorderRadius.circular(PRadius.panel),
                border: Border.all(color: const Color(0x28F4F2EC)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0x2A8A6A4E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x558A6A4E)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${area.order}',
                      style: const TextStyle(
                        color: Color(0xFFE8C59A),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.name,
                          style: PType.uiStrong.copyWith(fontSize: 15, color: PColors.bone),
                        ),
                        if (area.description != null && area.description!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            area.description!,
                            style: PType.meta.copyWith(color: PColors.bone70, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: PColors.bone, size: 18),
                    onPressed: () => _openEditModal(context, area),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B), size: 18),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1C18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PRadius.panel),
                            side: const BorderSide(color: Color(0x30F4F2EC)),
                          ),
                          title: Text(
                            '¿Eliminar "${area.name}"?',
                            style: PType.greeting.copyWith(color: PColors.bone, fontSize: 20),
                          ),
                          content: const Text(
                            'Esto removerá la fortaleza de MySQL y del onboarding.',
                            style: TextStyle(color: PColors.bone70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancelar', style: PType.meta.copyWith(color: PColors.bone70)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await admin.deleteFocusArea(area.id);
                        if (context.mounted) {
                          context.read<OnboardingProvider>().loadFocusAreas();
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOCUS AREA FORM MODAL
// ─────────────────────────────────────────────────────────────────────────────
class _FocusAreaFormModal extends StatefulWidget {
  const _FocusAreaFormModal({this.area});
  final FocusArea? area;

  @override
  State<_FocusAreaFormModal> createState() => _FocusAreaFormModalState();
}

class _FocusAreaFormModalState extends State<_FocusAreaFormModal> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _orderCtrl;
  bool _isSaving = false;

  InputDecoration _modalInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PColors.bone45, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF1E1C18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0x30F4F2EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0x30F4F2EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: Color(0xFFE8C59A), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.area?.name ?? '');
    _descCtrl = TextEditingController(text: widget.area?.description ?? '');
    _orderCtrl = TextEditingController(text: (widget.area?.order ?? 1).toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.area != null;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161513),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Editar Fortaleza' : 'Nueva Fortaleza',
                  style: PType.greeting.copyWith(fontSize: 22, color: PColors.bone),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: PColors.bone70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Las fortalezas aparecen en el onboarding para que los miembros personalicen sus declaraciones.',
              style: PType.body.copyWith(color: PColors.bone62, fontSize: 13),
            ),
            const SizedBox(height: 20),

            const PEyebrow('Nombre / Título (requerido)'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: PColors.bone),
              decoration: _modalInput('e.g. Paz y Calma Interior'),
            ),
            const SizedBox(height: 16),

            const PEyebrow('Descripción Corta (opcional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              style: const TextStyle(color: PColors.bone),
              decoration: _modalInput('e.g. Descansar en Dios y quietud en el corazón'),
            ),
            const SizedBox(height: 16),

            const PEyebrow('Orden de visualización (número)'),
            const SizedBox(height: 8),
            TextField(
              controller: _orderCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: PColors.bone),
              decoration: _modalInput('1'),
            ),
            const SizedBox(height: 24),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(PRadius.pill),
                onTap: _isSaving
                    ? null
                    : () async {
                        final name = _nameCtrl.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor ingresa un nombre para la fortaleza')),
                          );
                          return;
                        }

                        setState(() => _isSaving = true);
                        final admin = context.read<AdminProvider>();
                        final onboardingProv = context.read<OnboardingProvider>();
                        final nav = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final order = int.tryParse(_orderCtrl.text.trim()) ?? 1;

                        final ok = await admin.saveFocusArea(
                          id: widget.area?.id,
                          name: name,
                          description: _descCtrl.text.trim(),
                          order: order,
                        );

                        setState(() => _isSaving = false);
                        if (ok) {
                          onboardingProv.loadFocusAreas();
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit ? 'Fortaleza actualizada en MySQL' : 'Fortaleza creada en MySQL',
                              ),
                            ),
                          );
                        }
                      },
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: PColors.bone,
                    borderRadius: BorderRadius.circular(PRadius.pill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: PColors.ink)
                      : Text(
                          isEdit ? 'Guardar Cambios' : 'Crear Fortaleza en MySQL',
                          style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 14),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
