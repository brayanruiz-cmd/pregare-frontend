import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  int _activeTab = 0; // 0: Topics, 1: Devotionals, 2: Stats

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      header: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                context.read<TopicsProvider>().loadTopics();
                context.read<DevotionalsProvider>().loadDevotionals();
                context.read<HomeProvider>().loadHomeData();
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.chevron_left_rounded,
                color: PColors.bone,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'STUDIO',
              style: PType.eyebrow.copyWith(
                color: PColors.clay,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: PColors.clay.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(PRadius.chip),
                border: Border.all(color: PColors.clay.withValues(alpha: 0.5)),
              ),
              child: Text(
                'ADMIN',
                style: PType.meta.copyWith(
                  color: PColors.clay,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Content Manager', style: PType.display.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Create topics linked to YouTube series and manage daily devotionals.',
            style: PType.body.copyWith(color: PColors.bone70, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // ── Segmented Tab Selector ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(PRadius.pill),
              border: Border.all(color: PColors.hairline),
            ),
            child: Row(
              children: [
                _TabButton(
                  title: 'Topics & YouTube',
                  isSelected: _activeTab == 0,
                  onTap: () => setState(() => _activeTab = 0),
                ),
                _TabButton(
                  title: 'Devotionals',
                  isSelected: _activeTab == 1,
                  onTap: () => setState(() => _activeTab = 1),
                ),
                _TabButton(
                  title: 'Strengths',
                  isSelected: _activeTab == 2,
                  onTap: () => setState(() => _activeTab = 2),
                ),
                _TabButton(
                  title: 'Overview',
                  isSelected: _activeTab == 3,
                  onTap: () => setState(() => _activeTab = 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Tab Content ──────────────────────────────────────────────────
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
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? PColors.bone : Colors.transparent,
            borderRadius: BorderRadius.circular(PRadius.pill),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: PType.uiStrong.copyWith(
              color: isSelected ? PColors.ink : PColors.bone70,
              fontSize: 13,
            ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PRadius.panel)),
      ),
      builder: (_) => _TopicFormSheet(topic: topic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final topics = admin.currentTopics;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PEyebrow('Published Series (${topics.length})'),
            GestureDetector(
              onTap: () => _openTopicForm(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: PColors.bone,
                  borderRadius: BorderRadius.circular(PRadius.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, color: PColors.ink, size: 18),
                    const SizedBox(width: 6),
                    Text('New Topic', style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (admin.topics is AsyncLoading && topics.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: PColors.bone),
            ),
          )
        else if (topics.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(PRadius.panel),
              border: Border.all(color: PColors.hairline),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.video_library_outlined, color: PColors.bone50, size: 48),
                  const SizedBox(height: 12),
                  Text('No topics yet', style: PType.cardTitle),
                  const SizedBox(height: 6),
                  Text(
                    'Add your first YouTube video series and practices.',
                    style: PType.body.copyWith(color: PColors.bone70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...topics.map((t) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PColors.glassFill,
                borderRadius: BorderRadius.circular(PRadius.panel),
                border: Border.all(color: PColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.youtubeVideoId != null || t.youtubeUrl != null) ...[
                    PYoutubePreviewCard(
                      youtubeUrl: t.youtubeUrl,
                      youtubeVideoId: t.youtubeVideoId,
                      title: t.title,
                      durationMinutes: t.videoDurationMinutes,
                      height: 160,
                    ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: PColors.bone.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(PRadius.chip),
                          border: Border.all(color: PColors.hairline),
                        ),
                        child: Text(
                          t.tag.toUpperCase(),
                          style: PType.meta.copyWith(color: PColors.clay, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: PColors.bone70, size: 20),
                            onPressed: () => _openTopicForm(context, t),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: PColors.ink,
                                  title: Text('Delete topic?', style: PType.cardTitle),
                                  content: Text('Are you sure you want to delete "${t.title}"?', style: PType.body),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancel', style: PType.meta),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && t.uuid != null) {
                                await admin.deleteTopic(t.uuid!);
                                if (context.mounted) {
                                  context.read<TopicsProvider>().loadTopics();
                                  context.read<HomeProvider>().loadHomeData();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(t.title, style: PType.cardTitle.copyWith(fontSize: 18)),
                  if (t.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(t.subtitle!, style: PType.meta.copyWith(color: PColors.bone62)),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    t.description,
                    style: PType.body.copyWith(color: PColors.bone70, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: PColors.clay, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${t.supportTips.length} weekly practices defined',
                        style: PType.meta.copyWith(color: PColors.bone70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _TopicFormSheet extends StatefulWidget {
  const _TopicFormSheet({this.topic});
  final Topic? topic;

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
    _tagCtrl = TextEditingController(text: t?.tag ?? 'Ángeles');
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
        TextEditingController(text: 'Lee el pasaje bíblico contemplando la majestad divina'),
        TextEditingController(text: 'Medita en la reverencia y santidad que rodea el trono de Dios'),
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.fromLTRB(PSpace.gutter, 20, PSpace.gutter, bottomInset + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.topic == null ? 'Create Topic Series' : 'Edit Topic Series',
                style: PType.cardTitle.copyWith(fontSize: 20),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: PColors.bone70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: PColors.hairline, height: 24),
          Expanded(
            child: ListView(
              children: [
                // ── YouTube URL Input ──────────────────────────────────────────
                const PEyebrow('YouTube Video URL or ID'),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: InputDecoration(
                    hintText: 'https://www.youtube.com/watch?v=... or @PregareApp',
                    hintStyle: const TextStyle(color: PColors.bone45),
                    filled: true,
                    fillColor: PColors.glassFill,
                    prefixIcon: const Icon(Icons.link_rounded, color: Colors.redAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PRadius.panel),
                      borderSide: const BorderSide(color: PColors.glassStroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PRadius.panel),
                      borderSide: const BorderSide(color: PColors.glassStroke),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),

                // ── Live Video Preview Card ──────────────────────────────────
                if (_urlCtrl.text.isNotEmpty) ...[
                  const PEyebrow('Live Video Preview'),
                  const SizedBox(height: 8),
                  PYoutubePreviewCard(
                    youtubeUrl: _urlCtrl.text,
                    title: _titleCtrl.text.isNotEmpty ? _titleCtrl.text : 'Video Preview',
                    height: 180,
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Tag & Title ────────────────────────────────────────────────
                const PEyebrow('Topic Tag & Category'),
                const SizedBox(height: 8),
                TextField(
                  controller: _tagCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Ángeles, Ansiedad, Propósito, Fe'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Title'),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Biblical Angels Are Not What You Think'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Subtitle / Series Note'),
                const SizedBox(height: 8),
                TextField(
                  controller: _subtitleCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Exploring the visions of Ezekiel and Isaiah · 8 min video'),
                ),
                const SizedBox(height: 16),

                // ── Description ────────────────────────────────────────────────
                const PEyebrow('Description'),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('Provide context and background for the community...'),
                ),
                const SizedBox(height: 16),

                // ── Scripture Quote & Reference ────────────────────────────────
                const PEyebrow('Scripture Quote (Optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _scriptureQuoteCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. En cuanto a la semejanza de sus caras...'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _scriptureRefCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Ezequiel 1:10'),
                ),
                const SizedBox(height: 24),

                // ── Dynamic Practices / Support Tips ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PEyebrow('Weekly Support Practices'),
                    GestureDetector(
                      onTap: _addTip,
                      child: Text('+ Add Step', style: PType.uiStrong.copyWith(color: PColors.clay, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._tipsControllers.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text('${e.key + 1}.', style: PType.meta.copyWith(color: PColors.clay, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: e.value,
                            style: const TextStyle(color: PColors.bone, fontSize: 13),
                            decoration: _inputDecoration('Action step for user...'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: PColors.bone45, size: 20),
                          onPressed: () => _removeTip(e.key),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 30),

                // ── Save Button ────────────────────────────────────────────────
                GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () async {
                          if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill title and description')),
                            );
                            return;
                          }

                          setState(() => _isSaving = true);
                          final admin = context.read<AdminProvider>();
                          final tips = _tipsControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

                          final ok = await admin.saveTopic(
                            id: widget.topic?.uuid,
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
                          if (ok && mounted) {
                            context.read<TopicsProvider>().loadTopics();
                            context.read<HomeProvider>().loadHomeData();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Topic saved successfully!')),
                            );
                          }
                        },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: PColors.bone,
                      borderRadius: BorderRadius.circular(PRadius.pill),
                    ),
                    alignment: Alignment.center,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: PColors.ink)
                        : Text(
                            widget.topic == null ? 'Publish Topic to App' : 'Save Changes',
                            style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 15),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PColors.bone45, fontSize: 13),
      filled: true,
      fillColor: PColors.glassFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.panel),
        borderSide: const BorderSide(color: PColors.glassStroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.panel),
        borderSide: const BorderSide(color: PColors.glassStroke),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: DEVOTIONALS MANAGER
// ─────────────────────────────────────────────────────────────────────────────
class _DevotionalsTab extends StatelessWidget {
  const _DevotionalsTab();

  void _openDevotionalForm(BuildContext context, [Devotional? dev]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PRadius.panel)),
      ),
      builder: (_) => _DevotionalFormSheet(devotional: dev),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final devotionals = admin.currentDevotionals;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PEyebrow('Daily Devotionals (${devotionals.length})'),
            GestureDetector(
              onTap: () => _openDevotionalForm(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: PColors.bone,
                  borderRadius: BorderRadius.circular(PRadius.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, color: PColors.ink, size: 18),
                    const SizedBox(width: 6),
                    Text('New Devotional', style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (admin.devotionals is AsyncLoading && devotionals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: PColors.bone),
            ),
          )
        else
          ...devotionals.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PColors.glassFill,
                borderRadius: BorderRadius.circular(PRadius.panel),
                border: Border.all(color: PColors.hairline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PColors.clay.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(PRadius.chip),
                      border: Border.all(color: PColors.clay.withValues(alpha: 0.4)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'D${d.day}',
                      style: PType.meta.copyWith(color: PColors.clay, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.title, style: PType.cardTitle.copyWith(fontSize: 16)),
                        const SizedBox(height: 3),
                        Text(
                          d.verse,
                          style: PType.meta.copyWith(color: PColors.bone62, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: PColors.bone70, size: 20),
                    onPressed: () => _openDevotionalForm(context, d),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: PColors.ink,
                          title: Text('Delete devotional?', style: PType.cardTitle),
                          content: Text('Delete Day ${d.day} "${d.title}"?', style: PType.body),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel', style: PType.meta),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await admin.deleteDevotional(d.id.toString());
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
        const SizedBox(height: 40),
      ],
    );
  }
}

class _DevotionalFormSheet extends StatefulWidget {
  const _DevotionalFormSheet({this.devotional});
  final Devotional? devotional;

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
    _verseCtrl = TextEditingController(text: d?.verse ?? '');
    _verseRefCtrl = TextEditingController(text: '');
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.fromLTRB(PSpace.gutter, 20, PSpace.gutter, bottomInset + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.devotional == null ? 'Create Devotional' : 'Edit Devotional',
                style: PType.cardTitle.copyWith(fontSize: 20),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: PColors.bone70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: PColors.hairline, height: 24),
          Expanded(
            child: ListView(
              children: [
                const PEyebrow('Day Number (1 to 365)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _dayCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. 1'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Title'),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. Empezar de nuevo'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Central Verse'),
                const SizedBox(height: 8),
                TextField(
                  controller: _verseCtrl,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('e.g. "Sus misericordias son nuevas cada mañana."'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Reflection Text'),
                const SizedBox(height: 8),
                TextField(
                  controller: _reflectionCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('Write daily reflection...'),
                ),
                const SizedBox(height: 16),

                const PEyebrow('Guided Prayer'),
                const SizedBox(height: 8),
                TextField(
                  controller: _prayerCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: PColors.bone),
                  decoration: _inputDecoration('Write closing prayer...'),
                ),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () async {
                          final day = int.tryParse(_dayCtrl.text.trim()) ?? 1;
                          if (_titleCtrl.text.trim().isEmpty || _verseCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill title and verse')),
                            );
                            return;
                          }

                          setState(() => _isSaving = true);
                          final admin = context.read<AdminProvider>();
                          final ok = await admin.saveDevotional(
                            id: widget.devotional?.id.toString(),
                            dayNumber: day,
                            title: _titleCtrl.text.trim(),
                            verseText: _verseCtrl.text.trim(),
                            verseReference: _verseRefCtrl.text.trim(),
                            reflectionText: _reflectionCtrl.text.trim(),
                            prayerText: _prayerCtrl.text.trim(),
                          );

                          setState(() => _isSaving = false);
                          if (ok && mounted) {
                            context.read<DevotionalsProvider>().loadDevotionals();
                            context.read<HomeProvider>().loadHomeData();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Devotional saved successfully!')),
                            );
                          }
                        },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: PColors.bone,
                      borderRadius: BorderRadius.circular(PRadius.pill),
                    ),
                    alignment: Alignment.center,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: PColors.ink)
                        : Text(
                            widget.devotional == null ? 'Publish Devotional' : 'Save Changes',
                            style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 15),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PColors.bone45, fontSize: 13),
      filled: true,
      fillColor: PColors.glassFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.panel),
        borderSide: const BorderSide(color: PColors.glassStroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.panel),
        borderSide: const BorderSide(color: PColors.glassStroke),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: OVERVIEW & STATS
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final stats = admin.stats is AsyncData ? (admin.stats as AsyncData).data as Map<String, dynamic> : null;

    final usersCount = stats?['totalUsers'] ?? 0;
    final topicsCount = stats?['totalTopics'] ?? 0;
    final devCount = stats?['totalDevotionals'] ?? 0;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const PEyebrow('Overview & Community Impact'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Users',
                value: '$usersCount',
                icon: Icons.people_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Topics & Videos',
                value: '$topicsCount',
                icon: Icons.ondemand_video_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Devotionals',
                value: '$devCount / 365',
                icon: Icons.menu_book_rounded,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _MetricCard(
                title: 'YouTube Channel',
                value: '@PregareApp',
                icon: Icons.play_circle_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),

        const PEyebrow('Connected YouTube Channel'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PColors.glassFill,
            borderRadius: BorderRadius.circular(PRadius.panel),
            border: Border.all(color: PColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: PColors.inkDeep,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: PBrandLogo(height: 24, isLight: true),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PREGARE', style: PType.cardTitle.copyWith(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text('@PregareApp · The word of God', style: PType.meta.copyWith(color: PColors.bone62)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'When you publish new topics in this Studio, community members will be able to watch your video, read the biblical scriptural analysis, and complete the weekly practical action steps directly inside PREGARE.',
                style: PType.body.copyWith(color: PColors.bone70, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PColors.glassFill,
        borderRadius: BorderRadius.circular(PRadius.panel),
        border: Border.all(color: PColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: PColors.clay, size: 24),
          const SizedBox(height: 12),
          Text(value, style: PType.display.copyWith(fontSize: 22, height: 1.1)),
          const SizedBox(height: 4),
          Text(title, style: PType.meta.copyWith(color: PColors.bone55, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STRENGTHS & FOCUS AREAS TAB (MySQL dynamic management)
// ─────────────────────────────────────────────────────────────────────────────
class _FocusAreasTab extends StatelessWidget {
  const _FocusAreasTab();

  void _openCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FocusAreaFormModal(),
    );
  }

  void _openEditModal(BuildContext context, FocusArea area) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FocusAreaFormModal(area: area),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final areas = admin.currentFocusAreas;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const PEyebrow('Strengths & Focus Areas'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    borderRadius: BorderRadius.circular(PRadius.chip),
                  ),
                  child: Text(
                    '${areas.length}',
                    style: PType.meta.copyWith(color: PColors.clay, fontSize: 11),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _openCreateModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: PColors.bone,
                  borderRadius: BorderRadius.circular(PRadius.chip),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: PColors.ink, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Add Strength',
                      style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (admin.focusAreas is AsyncLoading && areas.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: PColors.bone),
            ),
          )
        else if (areas.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(PRadius.card),
              border: Border.all(color: PColors.hairline),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.fitness_center_rounded, color: PColors.bone55, size: 36),
                const SizedBox(height: 12),
                Text(
                  'No focus areas found in database.',
                  style: PType.body.copyWith(color: PColors.bone70),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => _openCreateModal(context),
                  child: Text(
                    'Create First Strength',
                    style: PType.uiStrong.copyWith(color: PColors.clay),
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
                color: PColors.glassFill,
                borderRadius: BorderRadius.circular(PRadius.card),
                border: Border.all(color: PColors.hairline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: PColors.clay.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${area.order}',
                      style: PType.meta.copyWith(color: PColors.clay, fontWeight: FontWeight.w700),
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
                            style: PType.meta.copyWith(color: PColors.bone62, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: PColors.bone70, size: 18),
                    onPressed: () => _openEditModal(context, area),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: PColors.inkDeep,
                          title: Text(
                            'Delete "${area.name}"?',
                            style: PType.cardTitle.copyWith(color: PColors.bone),
                          ),
                          content: const Text(
                            'This will remove this strength from MySQL and onboarding.',
                            style: TextStyle(color: PColors.bone70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
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
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Focus Area / Strength Form Modal (Create & Edit)
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
      fillColor: PColors.glassFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: PColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: PColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PRadius.chip),
        borderSide: const BorderSide(color: PColors.clay, width: 1.5),
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
        color: PColors.inkDeep,
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
                  isEdit ? 'Edit Strength Area' : 'New Strength Area',
                  style: PType.cardTitle.copyWith(fontSize: 20, color: PColors.bone),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: PColors.bone70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Strengths appear in the onboarding selection so users can personalize their prayers and declarations.',
              style: PType.body.copyWith(color: PColors.bone62, fontSize: 13),
            ),
            const SizedBox(height: 20),

            const PEyebrow('Name / Title (required)'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: PColors.bone),
              decoration: _modalInput('e.g. Overcoming Fear & Anxiety'),
            ),
            const SizedBox(height: 16),

            const PEyebrow('Short Description (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              style: const TextStyle(color: PColors.bone),
              decoration: _modalInput('e.g. Supernatural peace and anchoring in God promises'),
            ),
            const SizedBox(height: 16),

            const PEyebrow('Display Order (number)'),
            const SizedBox(height: 8),
            TextField(
              controller: _orderCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: PColors.bone),
              decoration: _modalInput('1'),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _isSaving
                  ? null
                  : () async {
                      final name = _nameCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a strength name.')),
                        );
                        return;
                      }

                      setState(() => _isSaving = true);
                      final admin = context.read<AdminProvider>();
                      final order = int.tryParse(_orderCtrl.text.trim()) ?? 1;

                      final ok = await admin.saveFocusArea(
                        id: widget.area?.id,
                        name: name,
                        description: _descCtrl.text.trim(),
                        order: order,
                      );

                      setState(() => _isSaving = false);
                      if (ok && mounted) {
                        context.read<OnboardingProvider>().loadFocusAreas();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit ? 'Strength updated in MySQL!' : 'Strength created in MySQL!',
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
                ),
                alignment: Alignment.center,
                child: _isSaving
                    ? const CircularProgressIndicator(color: PColors.ink)
                    : Text(
                        isEdit ? 'Save Changes' : 'Create Strength in Database',
                        style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
