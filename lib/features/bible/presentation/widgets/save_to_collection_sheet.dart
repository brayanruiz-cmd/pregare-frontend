import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/verse_collection.dart';
import '../providers/bible_provider.dart';
import 'share_verse_sheet.dart';

/// Modal bottom sheet matching Instagram's "Guardado en Colecciones" experience.
class SaveToCollectionSheet extends StatefulWidget {
  const SaveToCollectionSheet({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    this.colorHex,
  });

  final String bookId;
  final String bookName;
  final int chapter;
  final Verse verse;
  final String? colorHex;

  static Future<void> show(
    BuildContext context, {
    required String bookId,
    required String bookName,
    required int chapter,
    required Verse verse,
    String? colorHex,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SaveToCollectionSheet(
        bookId: bookId,
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        colorHex: colorHex,
      ),
    );
  }

  @override
  State<SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<SaveToCollectionSheet> {
  final Set<String> _inCollectionIds = {};
  bool _isLoading = true;
  bool _isCreatingInline = false;
  final TextEditingController _newTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _newTitleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<BibleProvider>();
    await provider.loadCollections();
    final ids = await provider.getVerseCollectionIds(
      widget.bookId,
      widget.chapter,
      widget.verse.number,
    );
    if (mounted) {
      setState(() {
        _inCollectionIds.clear();
        _inCollectionIds.addAll(ids);
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCollection(VerseCollection collection) async {
    final provider = context.read<BibleProvider>();
    final isCurrentlyIn = _inCollectionIds.contains(collection.id);

    // Optimistic toggle
    setState(() {
      if (isCurrentlyIn) {
        _inCollectionIds.remove(collection.id);
      } else {
        _inCollectionIds.add(collection.id);
      }
    });

    final inCollection = await provider.toggleVerseInCollection(
      collection.id,
      bookId: widget.bookId,
      bookName: widget.bookName,
      chapter: widget.chapter,
      verseNumber: widget.verse.number,
      verseText: widget.verse.text,
      colorHex: widget.colorHex,
    );

    if (mounted) {
      setState(() {
        if (inCollection) {
          _inCollectionIds.add(collection.id);
        } else {
          _inCollectionIds.remove(collection.id);
        }
      });
    }
  }

  Future<void> _createAndAdd() async {
    final title = _newTitleController.text.trim();
    if (title.isEmpty) return;

    final provider = context.read<BibleProvider>();
    final newCol = await provider.createCollection(title);
    if (newCol != null) {
      _newTitleController.clear();
      setState(() {
        _isCreatingInline = false;
      });
      await _toggleCollection(newCol);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleProvider>();
    final collections = provider.collections;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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

            // Item Guardado Row (exact style as Instagram screenshot)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: PColors.ink06,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PColors.ink14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: PColors.ink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.bookName.length > 5
                                ? widget.bookName.substring(0, 4).toUpperCase()
                                : widget.bookName.toUpperCase(),
                            style: const TextStyle(
                              color: PColors.bone,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.chapter}:${widget.verse.number}',
                            style: TextStyle(
                              color: PColors.bone.withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Guardado',
                          style: TextStyle(
                            color: PColors.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.bookName} ${widget.chapter}:${widget.verse.number} · Privada',
                          style: const TextStyle(
                            color: PColors.ink40,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      ShareVerseSheet.show(
                        context,
                        bookName: widget.bookName,
                        chapter: widget.chapter,
                        verseNumber: widget.verse.number,
                        verseText: widget.verse.text,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: PColors.ink10,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.ios_share_rounded,
                        color: PColors.ink,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.bookmark_rounded,
                    color: PColors.ink,
                    size: 24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Colecciones Header + "Nueva colección" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Colecciones',
                  style: TextStyle(
                    color: PColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCreatingInline = !_isCreatingInline;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      _isCreatingInline ? 'Cancelar' : 'Nueva colección',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Inline New Collection Input
            if (_isCreatingInline) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newTitleController,
                        autofocus: true,
                        style: const TextStyle(color: PColors.ink, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Título de la colección (ej. Fe, Promesas)',
                          hintStyle: TextStyle(color: PColors.ink40, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _createAndAdd(),
                      ),
                    ),
                    TextButton(
                      onPressed: _createAndAdd,
                      style: TextButton.styleFrom(
                        backgroundColor: PColors.ink,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Crear',
                        style: TextStyle(
                          color: PColors.bone,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Collections List
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: PColors.ink, strokeWidth: 2),
                ),
              )
            else if (collections.isEmpty && !_isCreatingInline)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 40, color: PColors.ink40),
                      const SizedBox(height: 8),
                      const Text(
                        'Aún no tienes colecciones creadas',
                        style: TextStyle(
                          color: PColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Crea una con "Nueva colección" para agrupar tus versículos.',
                        style: TextStyle(color: PColors.ink40, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isCreatingInline = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PColors.ink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        ),
                        child: const Text(
                          'Crear colección',
                          style: TextStyle(color: PColors.bone, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final col = collections[index];
                    final isInCol = _inCollectionIds.contains(col.id);

                    return GestureDetector(
                      onTap: () => _toggleCollection(col),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isInCol ? const Color(0x102563EB) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isInCol ? const Color(0x332563EB) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Collection thumbnail
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: PColors.ink.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: PColors.ink14),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.bookmark_border_rounded,
                                color: PColors.ink,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Title & subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    col.title,
                                    style: const TextStyle(
                                      color: PColors.ink,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Privada · ${col.itemsCount} ${col.itemsCount == 1 ? 'versículo' : 'versículos'}',
                                    style: const TextStyle(
                                      color: PColors.ink40,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // (+) or (check) icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isInCol ? const Color(0xFF2563EB) : Colors.transparent,
                                border: Border.all(
                                  color: isInCol ? const Color(0xFF2563EB) : PColors.ink40,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                isInCol ? Icons.check_rounded : Icons.add_rounded,
                                size: 20,
                                color: isInCol ? Colors.white : PColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),
            // Ready / Done button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: PColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Listo',
                  style: TextStyle(
                    color: PColors.bone,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
