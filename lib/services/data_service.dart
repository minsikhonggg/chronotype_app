import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataService {
  static Database? _database;

  static Future<void> init() async {
    if (_database != null) return;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) async {
        await db.execute(
            '''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT, 
            email TEXT UNIQUE, 
            password TEXT, 
            phone TEXT, 
            imagePath TEXT,
            chronotypeResult TEXT
          )
          '''
        );
        await db.execute(
            '''
          CREATE TABLE sleep_diary(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            diary TEXT,
            email TEXT,
            FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
          )
          '''
        );
      },
      version: 1,
    );
  }

  static Future<void> saveUser(String name, String email, String password, [String? imagePath]) async {
    final db = _database!;
    await db.insert(
      'users',
      {'name': name, 'email': email, 'password': password, 'imagePath': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: "email = ?",
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  static Future<void> updateUser(String email, String name, String phone, String password, [String? imagePath]) async {
    final db = _database!;
    await db.update(
      'users',
      {'name': name, 'phone': phone, 'password': password, 'imagePath': imagePath},
      where: "email = ?",
      whereArgs: [email],
    );
  }

  static Future<void> saveSleepDiary(DateTime date, String diary, String email) async {
    final db = _database!;
    await db.insert(
      'sleep_diary',
      {'date': date.toIso8601String(), 'diary': diary, 'email': email},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getSleepDiaries(String email) async {
    final db = _database!;
    return await db.query(
      'sleep_diary',
      where: "email = ?",
      whereArgs: [email],
    );
  }

  static Future<Map<String, dynamic>?> getDiaryByDate(DateTime date, String email) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_diary',
      where: "date = ? AND email = ?",
      whereArgs: [date.toIso8601String(), email],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  static Future<void> updateSleepDiary(DateTime date, String diary, String email) async {
    final db = _database!;
    await db.update(
      'sleep_diary',
      {'diary': diary},
      where: "date = ? AND email = ?",
      whereArgs: [date.toIso8601String(), email],
    );
  }

  static Future<void> deleteSleepDiary(DateTime date, String email) async {
    final db = _database!;
    await db.delete(
      'sleep_diary',
      where: "date = ? AND email = ?",
      whereArgs: [date.toIso8601String(), email],
    );
  }

  static Future<void> saveChronotypeResult(String email, String chronotypeResult) async {
    final db = _database!;
    await db.update(
      'users',
      {'chronotypeResult': chronotypeResult},
      where: "email = ?",
      whereArgs: [email],
    );
  }

  static Future<String?> getChronotypeResult(String email) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      columns: ['chronotypeResult'],
      where: "email = ?",
      whereArgs: [email],
    );

    if (maps.isNotEmpty && maps.first['chronotypeResult'] != null) {
      return maps.first['chronotypeResult'] as String?;
    } else {
      return null;
    }
  }
}
