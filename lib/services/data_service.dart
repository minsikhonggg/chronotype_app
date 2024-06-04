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
            email TEXT, 
            password TEXT, 
            phone TEXT, 
            imagePath TEXT
          )
          '''
        );
        await db.execute(
            '''
          CREATE TABLE sleep_diary(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            diary TEXT
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

  static Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: "id = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  static Future<void> updateUser(String id, String name, String phone, String password, [String? imagePath]) async {
    final db = _database!;
    await db.update(
      'users',
      {'name': name, 'phone': phone, 'password': password, 'imagePath': imagePath},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  static Future<void> saveSleepDiary(DateTime date, String diary) async {
    final db = _database!;
    await db.insert(
      'sleep_diary',
      {'date': date.toIso8601String(), 'diary': diary},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getSleepDiaries() async {
    final db = _database!;
    return await db.query('sleep_diary');
  }

  static Future<Map<String, dynamic>?> getDiaryByDate(DateTime date) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_diary',
      where: "date = ?",
      whereArgs: [date.toIso8601String()],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  static Future<void> updateSleepDiary(DateTime date, String diary) async {
    final db = _database!;
    await db.update(
      'sleep_diary',
      {'diary': diary},
      where: "date = ?",
      whereArgs: [date.toIso8601String()],
    );
  }

  static Future<void> deleteSleepDiary(DateTime date) async {
    final db = _database!;
    await db.delete(
      'sleep_diary',
      where: "date = ?",
      whereArgs: [date.toIso8601String()],
    );
  }
}
