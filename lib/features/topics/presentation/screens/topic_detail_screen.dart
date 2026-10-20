import 'package:flutter/material.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../../core/ui/molecules/reading_scroll_capsule.dart';
import '../../../bible/presentation/screens/bible_screen.dart';
import '../../domain/models/topic.dart';

/// TopicDetailScreen — Experiencia editorial de lectura tipo Libro.
///
/// Características principales:
/// 1. Modo Libro Paginado (por defecto en móvil): Cada tema se divide en capítulos
///    claros (Portada con video, Enseñanza dosificada, Escritura sagrada y Práctica semanal).
/// 2. Navegación fluida: Swipe horizontal o barra inferior de control con Anterior / Siguiente.
/// 3. Toggle a lectura continua: Quien prefiera scroll continuo puede alternar con un toque.
/// 4. Responsivo: En móvil ocupa el 100% y en pantallas anchas se centra en un ancho óptimo de lectura (640px).
class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({super.key, required this.topic});

  final Topic topic;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  bool _isBookMode = true;
  int _currentPage = 0;
  int _maxReadPage = 0; // highest page index the user has visited
  late final PageController _pageController;
  late final ScrollController _continuousScrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _continuousScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _continuousScrollController.dispose();
    super.dispose();
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Al finalizar el libro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Has completado la lectura de "${widget.topic.title}"!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// Divide una descripción larga en fragmentos digeribles de 1 a 2 párrafos (350-500 caracteres).
  List<String> _paginateDescription(String text) {
    if (text.trim().isEmpty) return [];

    final rawParagraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (rawParagraphs.isEmpty) return [text.trim()];

    final pages = <String>[];
    String currentBuffer = '';

    for (final paragraph in rawParagraphs) {
      if (currentBuffer.isEmpty) {
        currentBuffer = paragraph;
      } else if (currentBuffer.length + paragraph.length < 520) {
        currentBuffer += '\n\n$paragraph';
      } else {
        pages.add(currentBuffer);
        currentBuffer = paragraph;
      }
    }
    if (currentBuffer.isNotEmpty) {
      pages.add(currentBuffer);
    }
    return pages;
  }

  (String bookId, String bookName, int chapter) _parseVerseRef(String ref) {
    final clean = ref.split('·').first.trim();
    final lastColon = clean.lastIndexOf(':');
    if (lastColon == -1) return (clean.toLowerCase().replaceAll(' ', '-'), clean, 1);
    final bookAndChapter = clean.substring(0, lastColon).trim();
    final parts = bookAndChapter.split(' ');
    int chapter = 1;
    String bookName = bookAndChapter;
    if (parts.length >= 2) {
      final maybeCh = int.tryParse(parts.last);
      if (maybeCh != null) {
        chapter = maybeCh;
        bookName = parts.sublist(0, parts.length - 1).join(' ');
      }
    }
    var bookId = bookName.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
    if (bookId == 'psalm') bookId = 'psalms';
    return (bookId, bookName, chapter);
  }

  void _openBibleReader(String reference) {
    final (bookId, bookName, chapter) = _parseVerseRef(reference);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleReaderScreen(
          bookId: bookId,
          bookName: bookName,
          initialChapter: chapter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final readingChunks = _paginateDescription(topic.description);
    final hasScripture = topic.scriptureQuote != null && topic.scriptureQuote!.trim().isNotEmpty;
    final hasTips = topic.supportTips.isNotEmpty;

    // Calcular páginas totales
    final totalPages = 1 + readingChunks.length + (hasScripture ? 1 : 0) + (hasTips ? 1 : 0);

    return PScreen(
      background: const PScreenBackground.bone(),
      hasNav: false,
      padding: EdgeInsets.zero,
      header: _buildHeader(totalPages),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _isBookMode
              ? _buildBookMode(readingChunks, hasScripture, hasTips, totalPages)
              : _buildContinuousMode(),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutterLight, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PColors.ink10, width: 0.5)),
      ),
      child: Row(
        children: [
          PInteractive(
            onTap: () => Navigator.pop(context),
            tooltip: 'Volver a temas',
            child: const Icon(
              Icons.chevron_left_rounded,
              color: PColors.ink,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),

          // Indicador de modo o página en centro
          Expanded(
            child: Center(
              child: _isBookMode
                  ? Text(
                      'CAPÍTULO ${_currentPage + 1} DE $totalPages',
                      style: PType.eyebrow.copyWith(color: PColors.stone, fontSize: 10),
                    )
                  : Text(
                      widget.topic.tag.toUpperCase(),
                      style: PType.eyebrow.copyWith(color: PColors.stone, fontSize: 10),
                    ),
            ),
          ),

          // Toggle de Modo Libro vs Continuo
          PInteractive(
            onTap: () {
              setState(() {
                _isBookMode = !_isBookMode;
              });
            },
            tooltip: _isBookMode ? 'Cambiar a lectura continua' : 'Cambiar a modo libro paginado',
            builder: (context, isHovered, isPressed) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isHovered ? PColors.ink06 : Colors.transparent,
                borderRadius: BorderRadius.circular(PRadius.chip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isBookMode ? Icons.menu_book_rounded : Icons.view_headline_rounded,
                    color: PColors.ink,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isBookMode ? 'Libro' : 'Lista',
                    style: PType.meta.copyWith(
                      color: PColors.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Modo Libro Paginado
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBookMode(
    List<String> readingChunks,
    bool hasScripture,
    bool hasTips,
    int totalPages,
  ) {
    return Column(
      children: [
        // Indicador de progreso fino superior
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PSpace.gutterLight, vertical: 8),
          child: Row(
            children: List.generate(totalPages, (index) {
              final isPassed = index < _currentPage;
              final isCurrent = index == _currentPage;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? PColors.clay
                        : isPassed
                            ? PColors.clay.withValues(alpha: 0.35)
                            : PColors.ink10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),

        // Páginas con PageView
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() {
              _currentPage = i;
              if (i > _maxReadPage) _maxReadPage = i;
            }),
            children: [
              // Página 1: Portada & Video
              _buildCoverPage(totalPages),

              // Páginas 2..N: Enseñanza
              ...readingChunks.asMap().entries.map((entry) {
                final chunkIndex = entry.key + 1;
                final pageIndex = entry.key + 1; // 0-based page index in PageView
                final text = entry.value;
                final isRead = pageIndex < _currentPage;
                return _buildReadingPage(chunkIndex, text, readingChunks.length, isRead: isRead);
              }),

              // Página N+1: Escritura Sagrada
              if (hasScripture) _buildScripturePage(),

              // Página Final: Práctica de la semana
              if (hasTips) _buildPracticePage(),
            ],
          ),
        ),

        // Barra inferior de navegación del libro
        _buildReadingBottomBar(totalPages),
      ],
    );
  }

  /// Página 1: Portada, Título y Video
  Widget _buildCoverPage(int totalPages) {
    final topic = widget.topic;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        PSpace.gutterLight,
        12,
        PSpace.gutterLight,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PColors.ink10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  topic.tag.toUpperCase(),
                  style: PType.eyebrow.copyWith(
                    color: PColors.clay,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${topic.videoDurationMinutes} min · $totalPages páginas',
                style: PType.meta.copyWith(color: PColors.stone, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            topic.title,
            style: PType.display.copyWith(
              color: PColors.ink,
              fontSize: 28,
              height: 1.18,
            ),
          ),
          if (topic.subtitle != null && topic.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              topic.subtitle!,
              style: PType.body.copyWith(
                color: PColors.stone,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Tarjeta de video interactiva
          PYoutubePreviewCard(
            youtubeUrl: topic.youtubeUrl,
            youtubeVideoId: topic.youtubeVideoId,
            title: topic.title,
            durationMinutes: topic.videoDurationMinutes,
            height: 205,
          ),
          const SizedBox(height: 20),

          // Pista de lectura para el usuario
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: PColors.cardFill,
              borderRadius: BorderRadius.circular(PRadius.chip),
              border: Border.all(color: PColors.ink10),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward_rounded, size: 16, color: PColors.clay),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Desliza o presiona "Siguiente" para comenzar la lectura de la enseñanza.',
                    style: PType.meta.copyWith(color: PColors.ink, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Página de Lectura de la Enseñanza
  Widget _buildReadingPage(int chapterNumber, String text, int totalChapters, {bool isRead = false}) {
    return Stack(
      children: [
        SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        PSpace.gutterLight,
        16,
        PSpace.gutterLight,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'LA ENSEÑANZA',
                style: PType.eyebrow.copyWith(color: PColors.clay, fontSize: 11),
              ),
              if (totalChapters > 1) ...[
                const SizedBox(width: 6),
                Text(
                  '· Parte $chapterNumber de $totalChapters',
                  style: PType.meta.copyWith(color: PColors.stone, fontSize: 11),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Tarjeta de lectura estilo libro con tipografía generosa
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PColors.cardFill,
              borderRadius: BorderRadius.circular(PRadius.card),
              border: Border.all(color: PColors.ink10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10141310),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              text,
              style: PType.body.copyWith(
                color: PColors.ink,
                fontSize: 17,
                height: 1.72,
                letterSpacing: 0.15,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Toma un momento para reflexionar en esta idea',
              style: PType.meta.copyWith(
                color: PColors.stone,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
        ),
        // "Ya leído" indicator shown when user has moved past this page
        if (isRead)
          Positioned(
            top: 12,
            right: PSpace.gutterLight,
            child: AnimatedOpacity(
              opacity: isRead ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 11,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Leído',
                      style: PType.meta.copyWith(
                        color: const Color(0xFF4CAF50),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Página de Escritura Sagrada
  Widget _buildScripturePage() {
    final topic = widget.topic;
    final quote = topic.scriptureQuote!.trim();
    final ref = topic.scriptureReference?.trim() ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        PSpace.gutterLight,
        16,
        PSpace.gutterLight,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESCRITURA SAGRADA',
            style: PType.eyebrow.copyWith(color: PColors.clay, fontSize: 11),
          ),
          const SizedBox(height: 18),

          // Tarjeta de versículo central
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: PColors.cardFill,
              borderRadius: BorderRadius.circular(PRadius.card),
              border: Border.all(color: PColors.clay.withValues(alpha: 0.35), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x15141310),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 32,
                  color: PColors.clay,
                ),
                const SizedBox(height: 12),
                Text(
                  '"$quote"',
                  style: PType.scripture.copyWith(
                    color: PColors.ink,
                    fontSize: 20,
                    height: 1.55,
                  ),
                ),
                if (ref.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '— $ref',
                        style: PType.meta.copyWith(
                          color: PColors.stone,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      PLink(
                        text: 'Abrir en Biblia',
                        textStyle: PType.meta.copyWith(color: PColors.clay, fontSize: 12),
                        trailingIcon: Icons.arrow_outward_rounded,
                        iconSize: 12,
                        onTap: () => _openBibleReader(ref),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'La Palabra es viva y eficaz.',
              style: PType.meta.copyWith(
                color: PColors.stone,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Página de Práctica de la Semana
  Widget _buildPracticePage() {
    final topic = widget.topic;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        PSpace.gutterLight,
        16,
        PSpace.gutterLight,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRÁCTICA DE LA SEMANA',
            style: PType.eyebrow.copyWith(color: PColors.clay, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            'Cómo llevar esta verdad al día a día',
            style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 16),
          ),
          const SizedBox(height: 18),

          ...topic.supportTips.asMap().entries.map((entry) {
            final num = (entry.key + 1).toString().padLeft(2, '0');
            final tipText = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: PColors.cardFill,
                borderRadius: BorderRadius.circular(PRadius.tile),
                border: Border.all(color: PColors.ink10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PColors.ink.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      num,
                      style: PType.meta.copyWith(
                        color: PColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      tipText,
                      style: PType.body.copyWith(
                        color: PColors.ink,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Barra de navegación inferior del libro (Anterior · Indicador · Siguiente)
  Widget _buildReadingBottomBar(int totalPages) {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutterLight, vertical: 12),
      decoration: const BoxDecoration(
        color: PColors.bone,
        border: Border(top: BorderSide(color: PColors.ink10, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Botón Anterior
            if (!isFirst)
              PInteractive(
                onTap: _prevPage,
                tooltip: 'Página anterior',
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(PRadius.chip),
                    border: Border.all(color: PColors.ink14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 16, color: PColors.ink),
                      const SizedBox(width: 6),
                      Text(
                        'Anterior',
                        style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(width: 44),

            const Spacer(),

            // Indicador central
            Text(
              '${_currentPage + 1} / $totalPages',
              style: PType.counter.copyWith(color: PColors.ink, fontSize: 13),
            ),

            const Spacer(),

            // Botón Siguiente / Finalizar
            PInteractive(
              onTap: () => _nextPage(totalPages),
              tooltip: isLast ? 'Finalizar lectura' : 'Siguiente página',
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isLast ? PColors.clay : PColors.ink,
                  borderRadius: BorderRadius.circular(PRadius.chip),
                ),
                child: Row(
                  children: [
                    Text(
                      isLast ? 'Finalizar' : 'Siguiente',
                      style: PType.uiStrong.copyWith(color: PColors.bone, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      size: 16,
                      color: PColors.bone,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Modo Continuo (Scroll clásico)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildContinuousMode() {
    final topic = widget.topic;
    final hasScripture = topic.scriptureQuote != null && topic.scriptureQuote!.trim().isNotEmpty;
    final hasTips = topic.supportTips.isNotEmpty;

    return Stack(
      children: [
        ListView(
          controller: _continuousScrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: PSpace.gutterLight, vertical: 12),
          children: [
            PEyebrow('Topic · ${topic.tag}', color: PColors.stone),
            const SizedBox(height: 12),
            Text(
              topic.title,
              style: PType.display.copyWith(
                color: PColors.ink,
                fontSize: 28,
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

            PYoutubePreviewCard(
              youtubeUrl: topic.youtubeUrl,
              youtubeVideoId: topic.youtubeVideoId,
              title: topic.title,
              durationMinutes: topic.videoDurationMinutes,
              height: 210,
            ),
            const SizedBox(height: 24),

            Text(
              topic.description,
              style: PType.body.copyWith(color: PColors.ink, height: 1.65, fontSize: 16),
            ),
            const SizedBox(height: 24),

            if (hasScripture) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: PColors.cardFill,
                  borderRadius: BorderRadius.circular(PRadius.panel),
                  border: Border.all(color: PColors.stone.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${topic.scriptureQuote!.trim()}"',
                      style: PType.scripture.copyWith(color: PColors.ink, fontSize: 16, height: 1.45),
                    ),
                    if (topic.scriptureReference != null && topic.scriptureReference!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '— ${topic.scriptureReference!.trim()}',
                        style: PType.meta.copyWith(color: PColors.stone, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            if (hasTips) ...[
              PEyebrow('Practise this week', color: PColors.stone),
              const SizedBox(height: 16),
              ...topic.supportTips.asMap().entries.map((e) {
                final num = (e.key + 1).toString().padLeft(2, '0');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(num, style: PType.meta.copyWith(color: PColors.stone, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(e.value, style: PType.body.copyWith(color: PColors.ink, height: 1.5)),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 40),
          ],
        ),

        // Floating reading progress capsule — right edge
        Positioned(
          right: 6,
          top: 80,
          child: ReadingScrollCapsule(
            scrollController: _continuousScrollController,
            capsuleHeight: 120,
            capsuleWidth: 18,
            thumbHeight: 30,
            dotCount: 5,
            thumbColor: PColors.clay,
            backgroundColor: PColors.ink10,
          ),
        ),
      ],
    );
  }
}
