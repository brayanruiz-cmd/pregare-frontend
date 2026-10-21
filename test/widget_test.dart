import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pregare_app/features/bible/presentation/providers/bible_provider.dart';
import 'package:pregare_app/features/bible/presentation/screens/bible_screen.dart';
import 'package:pregare_app/features/bible/domain/ports/bible_repository.dart';
import 'package:pregare_app/features/bible/domain/models/bible_highlight.dart';
import 'package:pregare_app/features/bible/domain/models/bible_version.dart';
import 'package:pregare_app/features/bible/domain/models/book.dart';
import 'package:pregare_app/features/bible/domain/models/chapter.dart';
import 'package:pregare_app/features/bible/domain/models/verse_collection.dart';
import 'package:pregare_app/core/theme/app_theme.dart';

void main() {
  testWidgets('BibleScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ChangeNotifierProvider(
          create: (_) => BibleProvider(repository: _MockBibleRepository()),
          child: const BibleScreen(),
        ),
      ),
    );
    expect(find.text('Bible'), findsOneWidget);
  });
}

class _MockBibleRepository implements BibleRepository {
  @override
  Future<List<BibleVersion>> getVersions() async => [];

  @override
  Future<List<Book>> getBooks(String version) async => [];

  @override
  Future<Chapter> getChapter(String book, int chapter, String version) async =>
      Chapter(book: book, chapter: chapter, verses: []);

  @override
  Future<List<BibleHighlight>> getHighlights() async => [];

  @override
  Future<bool> toggleHighlight({
    required String bookId,
    required int chapter,
    required int verseNumber,
    required String verseText,
    String? version,
    String? colorHex,
  }) async =>
      false;

  @override
  Future<List<VerseCollection>> getCollections() async => [];

  @override
  Future<VerseCollection> createCollection(String title, {String? colorHex, String? description}) async =>
      VerseCollection(
        id: '1',
        userId: '1',
        title: title,
        colorHex: '#B58D3D',
        isPrivate: true,
        itemsCount: 0,
        previewVerses: [],
        createdAt: DateTime.now(),
      );

  @override
  Future<bool> deleteCollection(String id) async => true;

  @override
  Future<List<String>> getVerseCollectionIds({
    required String bookId,
    required int chapter,
    required int verseNumber,
  }) async =>
      [];

  @override
  Future<bool> toggleVerseInCollection({
    required String collectionId,
    required String bookId,
    String? bookName,
    required int chapter,
    required int verseNumber,
    required String verseText,
    String? colorHex,
    String? version,
  }) async =>
      true;

  @override
  Future<VerseCollection?> getCollectionDetails(String id) async => null;
}
