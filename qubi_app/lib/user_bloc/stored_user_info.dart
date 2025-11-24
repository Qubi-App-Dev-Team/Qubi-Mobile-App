import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:qubi_app/pages/learn/bloc/chapter_data_store.dart';

class StoredUserInfo {
  static Map<String, dynamic> userData = <String, dynamic>{};
  static List<Map<String, dynamic>> progress = <Map<String, dynamic>>[];
  static DocumentReference? documentReference;
  static File? userFile;

  static String userID = '';
  static String folderName = 'Users';
  static String currentRunRequestId = '';

  /// Chapter -> progress in [0,1]
  static final ValueNotifier<Map<int, double>> chapterProgressVN =
      ValueNotifier(<int, double>{});

  /// "chapter.section" -> progress in [0,1]
  static final ValueNotifier<Map<String, double>> sectionProgressVN =
      ValueNotifier(<String, double>{});

  /// Chapter -> locked?
  static final ValueNotifier<Map<int, bool>> chapterLockedVN =
      ValueNotifier(<int, bool>{});

  /// "chapter.section" -> locked?
  static final ValueNotifier<Map<String, bool>> sectionLockedVN =
      ValueNotifier(<String, bool>{});

  /// Chapter -> skins unlocked count
  static final ValueNotifier<Map<int, int>> chapterSkinsUnlockedVN =
      ValueNotifier(<int, int>{});

  // Helpers
  static String _secKey(int chapterNum, int sectionNum) =>
      '$chapterNum.$sectionNum';

  static Future<void> initializeAccountData({required User? currUser}) async {
    // Reset all in-memory state
    userData.clear();
    progress.clear();
    documentReference = null;
    userID = '';

    chapterProgressVN.value = {};
    sectionProgressVN.value = {};
    chapterLockedVN.value = {};
    sectionLockedVN.value = {};
    chapterSkinsUnlockedVN.value = {};

    if (currUser == null) return;

    userID = currUser.uid;
    await ChapterDataStore.refreshChaptersCache(userID: userID, includeDocId: true);
    documentReference = FirebaseFirestore.instance.collection(folderName).doc(currUser.uid);

    final DocumentSnapshot? docSnap = await documentReference?.get();

    if (docSnap != null && docSnap.exists) {
      final Map<String, dynamic> firebaseDoc = (docSnap.data() as Map<String, dynamic>);
      userFile = await _ensureLocalFile();
      final current = await _readWholeFile(userFile!);

      if (current == null || current.trim().isEmpty) {
        debugPrint('Creating information for user that already exists');
        userData = firebaseDoc;
        userData['email'] = currUser.email;
        progress = (userData['progress'] as List)
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
        userData['progress'] = progress;
        currentRunRequestId = userData['currentRunRequestID'];
        userData.remove('currentRunRequestID');
      }
      else {
        Map<String, dynamic> tempMap = jsonDecode(current)['userInfo'];
        for (int i = 0; i < tempMap['progress'].length; i++){
          tempMap['progress'][i]['locked'] = tempMap['progress'][i]['locked'] && firebaseDoc['progress'][i]['locked'];
          tempMap['progress'][i]['skinsUnlocked'] = tempMap['progress'][i]['skinsUnlocked'].length > firebaseDoc['progress'][i]['skinsUnlocked'].length ? tempMap['progress'][i]['skinsUnlocked'] : firebaseDoc['progress'][i]['skinsUnlocked'];
          for (int j = 0; j < tempMap['progress'][i]['sections'].length; j++){
            tempMap['progress'][i]['sections'][j]['locked'] = tempMap['progress'][i]['sections'][j]['locked'] && firebaseDoc['progress'][i]['sections'][j]['locked'];
            tempMap['progress'][i]['sections'][j]['latestPage'] = max(tempMap['progress'][i]['sections'][j]['latestPage'], firebaseDoc['progress'][i]['sections'][j]['latestPage']);
          }
        }
        userData = tempMap;
        progress = (userData['progress'] as List)
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
        userData['progress'] = progress;
        currentRunRequestId = userData['currentRunRequestID'];
        try {await documentReference?.set(userData);} 
        catch (_) {}
        userData['email'] = currUser.email;
        userData.remove('currentRunRequestID');
        if (kDebugMode) {
            debugPrint('[StoredUserInfo] Loaded user data from existing local file.');
          }
      }
      await _writeSnapshotToDisk();
    } 
    else {
      final chapterSections = ChapterDataStore.sectionsPerChapter();
      int i = 1;
      for (final numSections in chapterSections) {
        final defaultProgress = <String, dynamic>{};
        defaultProgress['locked'] = i != 1; // only chapter 1 unlocked by default
        defaultProgress['skinsUnlocked'] = <dynamic>[];
        final defaultSectionProgress = <Map<String, dynamic>>[];
        for (int j = 1; j <= numSections; j++) {
          defaultSectionProgress.add({
            'latestPage': 0,
            'locked': j != 1, // only first section of first chapter unlocked
          });
        }
        defaultProgress['sections'] = defaultSectionProgress;
        progress.add(defaultProgress);
        i += 1;
      }

      userData['progress'] = progress;
      userData['email'] = currUser.email;
      userData['currentRunRequestID'] = currentRunRequestId;

      try {
        await documentReference?.set(userData);
      } catch (_) {}
      userData.remove('currentRunRequestID');
      userFile = await _ensureLocalFile();
      await _writeSnapshotToDisk();
    }

    _publishAllFromCurrent();
  }

  static double getChapterProgress({required int chapterNum}) {
    final secList =
        (progress[chapterNum - 1]['sections'] as List).cast<Map<String, dynamic>>();
    double sum = 0.0;
    for (int s = 0; s < secList.length; s++) {
      sum += getSectionProgress(chapterNum: chapterNum, sectionNum: s + 1);
    }
    return secList.isEmpty ? 0.0 : (sum / secList.length);
  }

  static double getSectionProgress(
      {required int sectionNum, required int chapterNum}) {
    final latestPage =
        (progress[chapterNum - 1]['sections'][sectionNum - 1]['latestPage'] as num)
            .toInt();
    final total =
        ChapterDataStore.totalSectionPages(chapterNum: chapterNum, sectionNum: sectionNum);
    if (total <= 0) return 0.0;
    return latestPage.clamp(0, total) / total;
  }

  static bool isChapterLocked({required int chapterNum}) {
    return (progress[chapterNum - 1]['locked'] as bool);
  }

  static bool isSectionLocked({required int chapterNum, required int sectionNum}) {
    return (progress[chapterNum - 1]['sections'][sectionNum - 1]['locked'] as bool);
  }

  static int skinsUnlocked({required int chapterNum}) {
    final list = (progress[chapterNum - 1]['skinsUnlocked'] as List);
    return list.length;
  }

  static int getLatestPage({required int chapterNum, required int sectionNum}){
    return progress[chapterNum - 1]['sections'][sectionNum - 1]['latestPage'];
  }

  // --------------------------
  // WRITE APIs (mutate + notify)
  // --------------------------


  static Future<void> writeCurrentRunRequest({required String currentID}) async {
    currentRunRequestId = currentID;
    userData['currentRunRequestID'] = currentRunRequestId;
    try {documentReference?.set(userData);}
    catch(e){
      if (kDebugMode) {
            debugPrint('Firestore write failed, persisting locally. $e');
          }
      }
    userData.remove('currentRunRequestID');
   }

  static Future<void> updateProgress({
    required int pageNum,
    required int sectionNum,
    required int chapterNum,
  }) async {
    final section = progress[chapterNum - 1]['sections'][sectionNum - 1];
    final latestPage = (section['latestPage'] as num).toInt();

    if (pageNum > latestPage) {
      section['latestPage'] = pageNum;

      // Auto-unlock next section/chapter when finishing a section
      if (pageNum ==
          ChapterDataStore.totalSectionPages(
              chapterNum: chapterNum, sectionNum: sectionNum)) {
        if (sectionNum == progress[chapterNum - 1]['sections'].length) {
          await setChapterLocked(chapterNum: chapterNum + 1, locked: false);
        } else {
          await setSectionLocked(
              chapterNum: chapterNum, sectionNum: sectionNum + 1, locked: false);
        }
      }

      // Persist (best-effort)
      try {
        await documentReference?.set(userData);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore write failed, persisting locally. $e');
        }
      }
      await _writeSnapshotToDisk();

      // Publish reactive updates
      _publishSectionProgress(chapterNum: chapterNum, sectionNum: sectionNum);
      _publishChapterProgress(chapterNum: chapterNum);
    }
  }

  static Future<void> setChapterLocked({
    required int chapterNum,
    required bool locked,
  }) async {
    // Guard: ignore invalid chapter numbers
    if (chapterNum <= 0 || chapterNum > progress.length) return;

    progress[chapterNum - 1]['locked'] = locked;
    try {await documentReference?.set(userData);} 
    catch (_) {}
    await _writeSnapshotToDisk();
    _publishChapterLocked(chapterNum: chapterNum);
  }

  static Future<void> setSectionLocked({
    required int chapterNum,
    required int sectionNum,
    required bool locked,
  }) async {
    if (chapterNum <= 0 ||
        chapterNum > progress.length ||
        sectionNum <= 0 ||
        sectionNum > (progress[chapterNum - 1]['sections'] as List).length) {
      return;
    }

    progress[chapterNum - 1]['sections'][sectionNum - 1]['locked'] = locked;
    try {
      await documentReference?.set(userData);
    } catch (_) {}
    await _writeSnapshotToDisk();
    _publishSectionLocked(chapterNum: chapterNum, sectionNum: sectionNum);
  }

  static Future<void> setSkinsUnlockedCount({
    required int chapterNum,
    required int count,
  }) async {
    final list = (progress[chapterNum - 1]['skinsUnlocked'] as List);
    if (count >= 0) {
      if (count > list.length) {
        list.addAll(List.filled(count - list.length, 'placeholder'));
      } else if (count < list.length) {
        list.removeRange(count, list.length);
      }
    }
    try {
      await documentReference?.set(userData);
    } catch (_) {}
    await _writeSnapshotToDisk();
    _publishChapterSkins(chapterNum: chapterNum);
  }

  static void _publishAllFromCurrent() {
    final chapterProgress = <int, double>{};
    final sectionProgress = <String, double>{};
    final chapterLocked = <int, bool>{};
    final sectionLocked = <String, bool>{};
    final chapterSkins = <int, int>{};

    for (int c = 0; c < progress.length; c++) {
      final chapterNum = c + 1;
      final chapterMap = progress[c];

      // Chapter locked
      chapterLocked[chapterNum] = (chapterMap['locked'] as bool);

      // Skins count
      final skins = (chapterMap['skinsUnlocked'] as List).length;
      chapterSkins[chapterNum] = skins;

      // Sections
      final sections =
          (chapterMap['sections'] as List).cast<Map<String, dynamic>>();
      double sum = 0.0;
      for (int s = 0; s < sections.length; s++) {
        final sectionNum = s + 1;
        final key = _secKey(chapterNum, sectionNum);

        // Section locked
        sectionLocked[key] = (sections[s]['locked'] as bool);

        // Section progress
        final secP =
            getSectionProgress(chapterNum: chapterNum, sectionNum: sectionNum);
        sectionProgress[key] = secP;
        sum += secP;
      }

      // Chapter progress as mean of section progress
      chapterProgress[chapterNum] =
          sections.isEmpty ? 0.0 : (sum / sections.length);
    }

    chapterProgressVN.value = chapterProgress;
    sectionProgressVN.value = sectionProgress;
    chapterLockedVN.value = chapterLocked;
    sectionLockedVN.value = sectionLocked;
    chapterSkinsUnlockedVN.value = chapterSkins;
  }

  static void _publishChapterProgress({required int chapterNum}) {
    final next = Map<int, double>.from(chapterProgressVN.value);
    next[chapterNum] = getChapterProgress(chapterNum: chapterNum);
    chapterProgressVN.value = next;
  }

  static void _publishSectionProgress({
    required int chapterNum,
    required int sectionNum,
  }) {
    final next = Map<String, double>.from(sectionProgressVN.value);
    next[_secKey(chapterNum, sectionNum)] =
        getSectionProgress(chapterNum: chapterNum, sectionNum: sectionNum);
    sectionProgressVN.value = next;
  }

  static void _publishChapterLocked({required int chapterNum}) {
    final next = Map<int, bool>.from(chapterLockedVN.value);
    next[chapterNum] = isChapterLocked(chapterNum: chapterNum);
    chapterLockedVN.value = next;
  }

  static void _publishSectionLocked({
    required int chapterNum,
    required int sectionNum,
  }) {
    final next = Map<String, bool>.from(sectionLockedVN.value);
    next[_secKey(chapterNum, sectionNum)] =
        isSectionLocked(chapterNum: chapterNum, sectionNum: sectionNum);
    sectionLockedVN.value = next;
  }

  static void _publishChapterSkins({required int chapterNum}) {
    final next = Map<int, int>.from(chapterSkinsUnlockedVN.value);
    next[chapterNum] = skinsUnlocked(chapterNum: chapterNum);
    chapterSkinsUnlockedVN.value = next;
  }

  static Future<File> _ensureLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/$folderName');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final file = File('${folder.path}/$userID');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  static Future<void> _writeSnapshotToDisk() async {
    final encoder = const JsonEncoder.withIndent('  ');
    final payload = <String, dynamic>{'userInfo': userData};
    await userFile?.writeAsString(encoder.convert(payload));

    if (kDebugMode) {
      debugPrint('[StoredUserInfo] Wrote snapshot → ${userFile?.path}');
    }
  }

  static Future<String?> _readWholeFile(File file) async {
    try {return await file.readAsString();} 
    catch (_) {return null;}
  }
}
