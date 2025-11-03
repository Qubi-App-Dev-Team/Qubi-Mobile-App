import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:qubi_app/pages/learn/models/chapter.dart';
import 'package:qubi_app/pages/learn/models/chapter_content.dart';
import 'package:qubi_app/pages/learn/models/section_routes.dart';

/// Central data store for 'chapters'.
/// - Static in-memory cache so all imports share the latest data
/// - Persists to a local JSON file for offline use

class ChapterDataStore {
  /// Shared in-memory cache of chapter documents:
  /// each entry is a Map`<`String, dynamic`>` representing one document.
  static List<Map<String, dynamic>> chapters = <Map<String, dynamic>>[];

  static const String collectionPath = 'chapters';
  static const String folderName = 'user_docs';     
  static const String fileName = 'chapters.json';   

  /// Public: Refresh the in-memory cache.
  ///
  /// Flow:
  /// 1) Try Firestore server read. On success:
  ///    - updates [chapters] in memory
  ///    - writes snapshot to disk
  /// 2) If Firestore read fails:
  ///    - if disk file exists, read it and update [chapters]
  ///    - else create empty file with {"chapters": []} and keep [chapters] empty
  static Future<void> refreshChaptersCache({bool includeDocId = true}) async {
    try {
      // 1) Prefer fresh server data (requires Firebase initialized & permitted)
      final qs = await FirebaseFirestore.instance
          .collection(collectionPath)
          .get(const GetOptions(source: Source.server));

      final next = <Map<String, dynamic>>[];
      for (final doc in qs.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        if (includeDocId) data['id'] = doc.id;
        next.add(data);
      }

      chapters = next; // update in-memory cache
      chapters.sort((a, b) => a['number'].compareTo(b['number']));
      await _writeSnapshotToDisk(); // persist for offline use

      if (kDebugMode) {
        debugPrint('[ChapterDataStore] Refreshed from Firestore: ${chapters.length} docs');
      }
    } catch (e, st) {
      // 2) Firestore failed → try local disk snapshot
      if (kDebugMode) {
        debugPrint('[ChapterDataStore] Firestore refresh failed: $e');
        debugPrint('$st');
      }

      final file = await _ensureLocalFile(); // ensure path + file exist
      if (await file.exists()) {
        try {
          final text = await file.readAsString();
          final decoded = jsonDecode(text);

          // Expecting { "chapters": [ ... ] }
          final list = (decoded is Map && decoded['chapters'] is List)
              ? (decoded['chapters'] as List).map<Map<String, dynamic>>((e) {
                  if (e is Map) return Map<String, dynamic>.from(e);
                  return <String, dynamic>{};
                }).toList()
              : <Map<String, dynamic>>[];

          chapters = list;

          if (kDebugMode) {
            debugPrint('[ChapterDataStore] Loaded ${chapters.length} docs from disk snapshot');
          }
        } catch (readErr, st2) {
          if (kDebugMode) {
            debugPrint('[ChapterDataStore] Failed to read disk snapshot: $readErr');
            debugPrint('$st2');
          }
          // Keep cache empty; rewrite a clean empty file below.
          await _writeEmptyIfEmpty();
        }
      } else {
        // File somehow missing even after ensure → create empty.
        await _writeEmptyIfEmpty();
      }
    }
  }

  static Future<List<Chapter>> loadAllChapters() async{
    List<Chapter> chapterModels = [];
    for (final data in chapters){
      chapterModels.add(
        Chapter(
          number: data['number'],
          title: data['title'],
          difficulty: data['diff'],
        )
      );
    }
    return chapterModels;
  }

  static Future<List<ChapterContent>> loadAllSections({required int chapterNum}) async{
    List<dynamic> relevantSections = chapters[chapterNum-1]['sections'];
    List<ChapterContent> finalSections = [];
    int i = 1;
    for (final sectionData in relevantSections){
      finalSections.add(
        ChapterContent(
          title: sectionData['title'],
          description: sectionData['description'],
          number: i 
        )
      );
      i++;
    }
    finalSections.sort((a, b) => a.number.compareTo(b.number));
    return finalSections;
  }

  static Future<void> loadAllSectionPages({required int chapterNum, required int sectionNum}) async {
    final List<dynamic> relevantPages = chapters[chapterNum - 1]['sections'][sectionNum - 1]['pages'];
    int pageNum = 1;
    for (final page in relevantPages) {
      final components = (page['components'] as List)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
      sectionRoutes['$chapterNum.$sectionNum.$pageNum'] = components;
      pageNum++;
    }
  }

  static int totalSectionPages({required int chapterNum, required int sectionNum}){
    return chapters[chapterNum - 1]['sections'][sectionNum-1]['pages'].length;
  }

  static List<int> sectionsPerChapter(){
    List<int> chapterPages = [];
    for (final chapterData in chapters){
      chapterPages.add(chapterData['sections'].length);
    }
    return chapterPages;
  }


  // -----------------------------
  // Internal helpers
  // -----------------------------

  static Future<File> _ensureLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/$folderName');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final file = File('${folder.path}/$fileName');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  static Future<void> _writeSnapshotToDisk() async {
    final file = await _ensureLocalFile();
    final encoder = const JsonEncoder.withIndent('  ');
    final payload = <String, dynamic>{'chapters': chapters};
    await file.writeAsString(encoder.convert(payload));

    if (kDebugMode) {
      debugPrint('[ChapterDataStore] Wrote snapshot → ${file.path}');
    }
  }

  static Future<void> _writeEmptyIfEmpty() async {
    final file = await _ensureLocalFile();
    if (!await file.exists() || (await file.length()) == 0) {
      await file.writeAsString('{\n  "chapters": []\n}\n');
      if (kDebugMode) {
        debugPrint('[ChapterDataStore] Created empty snapshot at ${file.path}');
      }
    }
  }
}
