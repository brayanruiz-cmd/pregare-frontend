import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../domain/models/bible_highlight.dart';
import '../../domain/models/highlight_color_option.dart';
import '../../domain/models/verse_collection.dart';
import '../../domain/models/verse_collection_item.dart';
import '../providers/bible_provider.dart';
import '../widgets/share_verse_sheet.dart';
import 'bible_screen.dart';

class CollectionsLibraryScreen extends StatefulWidget {
  const CollectionsLibraryScreen({super.key});

  @override
  State<CollectionsLibraryScreen> createState() => _CollectionsLibraryScreenState();
}

class _CollectionsLibraryScreenState extends State<CollectionsLibraryScreen> {
  int _activeTab = 0; // 0 = Colecciones, 1 = Todos los Highlights

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BibleProvider>();
      provider.loadCollections();
      provider.loadHighlights();
    });
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PColors.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: PColors.hairline),
        ),
        title: Text(
          'Nueva Colección',
          style: GoogleFonts.hankenGrotesk(
            color: PColors.bone,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: titleController,
          autofocus: true,
          style: GoogleFonts.hankenGrotesk(color: PColors.bone, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Título (ej. Fe, Promesas, Dios)',
            hintStyle: GoogleFonts.hankenGrotesk(color: PColors.bone45, fontSize: 14),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: PColors.bone.withValues(alpha: 0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: PColors.bone),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.hankenGrotesk(color: PColors.bone55),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = titleController.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(ctx).pop();
                await context.read<BibleProvider>().createCollection(text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.bone,
              foregroundColor: PColors.ink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _openCollection(VerseCollection collection) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionDetailScreen(collection: collection),
      ),
    );
  }

  void _goToVerseInBible(String bookId, int chapter, int verseNumber, {String? bookName}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleReaderScreen(
          bookId: bookId,
          bookName: bookName ?? bookId.toUpperCase(),
          initialChapter: chapter,
          initialVerse: verseNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleProvider>();
    final collections = provider.collections;
    final highlights = provider.highlights;

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: PColors.glassFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PColors.hairline),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: PColors.bone, size: 16),
                  ),
                ),
                Text(
                  'Librería',
                  style: GoogleFonts.hankenGrotesk(
                    color: PColors.bone,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: _showCreateDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: PColors.bone,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded, color: PColors.ink, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Nueva',
                          style: GoogleFonts.hankenGrotesk(
                            color: PColors.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tab Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: PColors.glassFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PColors.hairline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTab == 0 ? PColors.bone : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Colecciones (${collections.length})',
                          style: GoogleFonts.hankenGrotesk(
                            color: _activeTab == 0 ? PColors.ink : PColors.bone55,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTab == 1 ? PColors.bone : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Highlights (${highlights.length})',
                          style: GoogleFonts.hankenGrotesk(
                            color: _activeTab == 1 ? PColors.ink : PColors.bone55,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _activeTab == 0
                  ? _buildCollectionsGrid(collections, provider.isLoadingCollections)
                  : _buildHighlightsList(highlights),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsGrid(List<VerseCollection> collections, bool isLoading) {
    if (isLoading && collections.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: PColors.bone, strokeWidth: 2),
      );
    }

    if (collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PColors.glassFill,
                shape: BoxShape.circle,
                border: Border.all(color: PColors.hairline),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.bookmark_outline_rounded, color: PColors.bone55, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes colecciones',
              style: GoogleFonts.hankenGrotesk(
                color: PColors.bone,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guarda y clasifica versículos subrayados con títulos personalizados.',
              style: GoogleFonts.hankenGrotesk(
                color: PColors.bone55,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showCreateDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: PColors.bone,
                foregroundColor: PColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Crear primera colección'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: collections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final col = collections[index];
        final firstVerse = col.previewVerses.isNotEmpty ? col.previewVerses.first : null;

        return GestureDetector(
          onTap: () => _openCollection(col),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: PColors.bone.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.bookmark_rounded, color: PColors.bone, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          col.title,
                          style: GoogleFonts.hankenGrotesk(
                            color: PColors.bone,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: PColors.bone.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${col.itemsCount} ${col.itemsCount == 1 ? 'versículo' : 'versículos'}',
                            style: GoogleFonts.hankenGrotesk(
                              color: PColors.bone70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded, color: PColors.bone45, size: 20),
                      ],
                    ),
                  ],
                ),
                if (firstVerse != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '«${firstVerse.verseText}»',
                      style: GoogleFonts.newsreader(
                        color: PColors.bone70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightsList(List<BibleHighlight> highlights) {
    if (highlights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.border_color_rounded, color: PColors.bone55, size: 36),
            const SizedBox(height: 12),
            Text(
              'No hay versículos subrayados',
              style: GoogleFonts.hankenGrotesk(
                color: PColors.bone,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Toca cualquier versículo mientras lees la Biblia para subrayarlo.',
              style: GoogleFonts.hankenGrotesk(
                color: PColors.bone55,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: highlights.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final h = highlights[index];
        final colorOption = HighlightColorOption.fromHex(h.colorHex);

        return GestureDetector(
          onTap: () => _goToVerseInBible(h.bookId, h.chapter, h.verseNumber),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colorOption.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${h.bookId.toUpperCase()} ${h.chapter}:${h.verseNumber}',
                          style: GoogleFonts.hankenGrotesk(
                            color: PColors.bone,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      h.version,
                      style: GoogleFonts.hankenGrotesk(
                        color: PColors.bone55,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  h.verseText,
                  style: GoogleFonts.newsreader(
                    color: PColors.bone85,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ShareVerseSheet.show(
                          context,
                          bookName: h.bookId.toUpperCase(),
                          chapter: h.chapter,
                          verseNumber: h.verseNumber,
                          verseText: h.verseText,
                          version: h.version,
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.ios_share_rounded, size: 14, color: PColors.bone70),
                          const SizedBox(width: 5),
                          Text(
                            'Compartir',
                            style: GoogleFonts.hankenGrotesk(
                              color: PColors.bone70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Toca para leer en la Biblia →',
                      style: GoogleFonts.hankenGrotesk(
                        color: PColors.bone55,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pantalla de detalle para una colección específica
class CollectionDetailScreen extends StatefulWidget {
  const CollectionDetailScreen({super.key, required this.collection});

  final VerseCollection collection;

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  VerseCollection? _currentCollection;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentCollection = widget.collection;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    final provider = context.read<BibleProvider>();
    final details = await provider.getCollectionDetails(widget.collection.id);
    if (mounted) {
      setState(() {
        if (details != null) {
          _currentCollection = details;
        }
        _isLoading = false;
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PColors.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: PColors.hairline),
        ),
        title: Text(
          '¿Eliminar colección?',
          style: GoogleFonts.hankenGrotesk(color: PColors.bone, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Se eliminará la colección "${widget.collection.title}". Los versículos seguirán subrayados en tu Biblia.',
          style: GoogleFonts.hankenGrotesk(color: PColors.bone70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: GoogleFonts.hankenGrotesk(color: PColors.bone55)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<BibleProvider>().deleteCollection(widget.collection.id);
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _goToVerse(VerseCollectionItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleReaderScreen(
          bookId: item.bookId,
          bookName: item.bookName.isNotEmpty ? item.bookName : item.bookId.toUpperCase(),
          initialChapter: item.chapter,
          initialVerse: item.verseNumber,
        ),
      ),
    );
  }

  Future<void> _removeItem(VerseCollectionItem item) async {
    final provider = context.read<BibleProvider>();
    await provider.toggleVerseInCollection(
      widget.collection.id,
      bookId: item.bookId,
      bookName: item.bookName,
      chapter: item.chapter,
      verseNumber: item.verseNumber,
      verseText: item.verseText,
    );
    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    final items = _currentCollection?.previewVerses ?? [];

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: PColors.glassFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PColors.hairline),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: PColors.bone, size: 16),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.collection.title,
                      style: GoogleFonts.hankenGrotesk(
                        color: PColors.bone,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _confirmDelete,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: PColors.glassFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PColors.hairline),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Metadata row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PColors.hairline),
                  ),
                  child: Text(
                    '${items.length} ${items.length == 1 ? 'versículo' : 'versículos'}',
                    style: GoogleFonts.hankenGrotesk(
                      color: PColors.bone70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Privada',
                  style: GoogleFonts.hankenGrotesk(
                    color: PColors.bone45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Verses List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: PColors.bone, strokeWidth: 2),
                    )
                  : items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bookmark_add_outlined, color: PColors.bone45, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'Colección vacía',
                                style: GoogleFonts.hankenGrotesk(
                                  color: PColors.bone,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Subraya versículos en la Biblia y guárdalos aquí.',
                                style: GoogleFonts.hankenGrotesk(
                                  color: PColors.bone55,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final colorOption = HighlightColorOption.fromHex(item.colorHex);

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: PColors.glassFill,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: PColors.hairline),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: colorOption.accent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${item.bookName.isNotEmpty ? item.bookName : item.bookId.toUpperCase()} ${item.chapter}:${item.verseNumber}',
                                            style: GoogleFonts.hankenGrotesk(
                                              color: PColors.bone,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_horiz_rounded, color: PColors.bone55, size: 20),
                                        color: PColors.ink,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: const BorderSide(color: PColors.hairline),
                                        ),
                                        onSelected: (val) {
                                          if (val == 'share') {
                                            ShareVerseSheet.show(
                                              context,
                                              bookName: item.bookName.isNotEmpty ? item.bookName : item.bookId.toUpperCase(),
                                              chapter: item.chapter,
                                              verseNumber: item.verseNumber,
                                              verseText: item.verseText,
                                              version: item.version,
                                            );
                                          } else if (val == 'read') {
                                            _goToVerse(item);
                                          } else if (val == 'remove') {
                                            _removeItem(item);
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          PopupMenuItem(
                                            value: 'share',
                                            child: Text(
                                              'Compartir versículo',
                                              style: GoogleFonts.hankenGrotesk(color: PColors.bone, fontSize: 13),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'read',
                                            child: Text(
                                              'Leer en la Biblia',
                                              style: GoogleFonts.hankenGrotesk(color: PColors.bone, fontSize: 13),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'remove',
                                            child: Text(
                                              'Quitar de colección',
                                              style: GoogleFonts.hankenGrotesk(color: const Color(0xFFEF4444), fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.verseText,
                                    style: GoogleFonts.newsreader(
                                      color: PColors.bone85,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          ShareVerseSheet.show(
                                            context,
                                            bookName: item.bookName.isNotEmpty ? item.bookName : item.bookId.toUpperCase(),
                                            chapter: item.chapter,
                                            verseNumber: item.verseNumber,
                                            verseText: item.verseText,
                                            version: item.version,
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(Icons.ios_share_rounded, color: PColors.bone70, size: 14),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Compartir',
                                              style: GoogleFonts.hankenGrotesk(
                                                color: PColors.bone70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _goToVerse(item),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.menu_book_rounded, color: PColors.bone55, size: 14),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Ir al capítulo →',
                                              style: GoogleFonts.hankenGrotesk(
                                                color: PColors.bone55,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
