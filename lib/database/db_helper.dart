import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';

class DBHelper {
  static Database? _db;

  // Untuk Web: simpan data di memory (sementara buat testing di Chrome)
  static final List<MoodEntry> _webStorage = [];
  static int _webIdCounter = 1;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moodIndex INTEGER NOT NULL,
        date TEXT NOT NULL,
        activities TEXT DEFAULT '',
        notes TEXT DEFAULT ''
      )
    ''');
  }

  static Future<Database> _initDb() async {
    // Desktop (Windows/Linux) butuh FFI
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Android/iOS/macOS pakai sqflite bawaan, nggak perlu setup apa-apa

    String path = join(await getDatabasesPath(), 'mood_diary_v3.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // ==================== CREATE ====================
  static Future<int> insertMood(MoodEntry entry) async {
    if (kIsWeb) {
      final newEntry = MoodEntry(
        id: _webIdCounter++,
        moodIndex: entry.moodIndex,
        date: entry.date,
        activities: entry.activities,
        notes: entry.notes,
      );
      _webStorage.add(newEntry);
      return newEntry.id!;
    }
    final Database dbClient = await db;
    return await dbClient.insert('moods', entry.toMap());
  }

  // ==================== READ ====================
  static Future<List<MoodEntry>> getMoods() async {
    if (kIsWeb) {
      // Hapus data lebih dari 30 hari
      DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      String threshold = thirtyDaysAgo.toIso8601String().substring(0, 10);
      _webStorage.removeWhere((e) => e.date.compareTo(threshold) < 0);
      _webStorage.sort((a, b) {
        int cmp = b.date.compareTo(a.date);
        if (cmp != 0) return cmp;
        return (b.id ?? 0).compareTo(a.id ?? 0);
      });
      return List.from(_webStorage);
    }

    final Database dbClient = await db;

    // Hapus data yang usianya lebih dari 30 hari secara otomatis
    DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    String dateThreshold = thirtyDaysAgo.toIso8601String().substring(0, 10);
    await dbClient.delete('moods', where: 'date < ?', whereArgs: [dateThreshold]);

    final List<Map<String, dynamic>> maps =
        await dbClient.query('moods', orderBy: 'date DESC, id DESC');
    return List.generate(maps.length, (i) => MoodEntry.fromMap(maps[i]));
  }

  // ==================== UPDATE ====================
  static Future<int> updateMood(MoodEntry entry) async {
    if (kIsWeb) {
      int idx = _webStorage.indexWhere((e) => e.id == entry.id);
      if (idx != -1) {
        _webStorage[idx] = entry;
        return 1;
      }
      return 0;
    }
    final Database dbClient = await db;
    return await dbClient.update(
      'moods',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // ==================== DELETE ====================
  static Future<int> deleteMood(int id) async {
    if (kIsWeb) {
      _webStorage.removeWhere((e) => e.id == id);
      return 1;
    }
    final Database dbClient = await db;
    return await dbClient.delete('moods', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== DELETE ALL ====================
  static Future<int> deleteAllMoods() async {
    if (kIsWeb) {
      _webStorage.clear();
      return 1;
    }
    final Database dbClient = await db;
    return await dbClient.delete('moods');
  }
}
