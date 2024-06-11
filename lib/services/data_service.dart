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
            imagePath TEXT
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
        await db.execute(
            '''
          CREATE TABLE chronotype_results(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT,
            resultType TEXT,
            score INTEGER,
            date TEXT,
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
    // Check if a diary entry for the same date and email already exists
    final existingDiary = await getDiaryByDate(date, email);
    if (existingDiary != null) {
      // Update the existing diary
      await updateSleepDiary(date, diary, email);
    } else {
      // Insert a new diary
      await db.insert(
        'sleep_diary',
        {'date': date.toIso8601String(), 'diary': diary, 'email': email},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
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

  static Future<void> deleteAllSleepDiaries(String email) async {
    final db = _database!;
    await db.delete(
      'sleep_diary',
      where: "email = ?",
      whereArgs: [email],
    );
  }

  static Future<void> deleteSleepDiariesByMonth(String email, String month) async {
    final db = _database!;
    await db.delete(
      'sleep_diary',
      where: "email = ? AND date LIKE ?",
      whereArgs: [email, '$month%'],
    );
  }

  static Future<void> saveChronotypeResult(String email, String resultType, int score, String date) async {
    final db = _database!;
    await db.insert(
      'chronotype_results',
      {
        'email': email,
        'resultType': resultType,
        'score': score,
        'date': date,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getLatestChronotypeResult(String email) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'chronotype_results',
      where: "email = ?",
      whereArgs: [email],
      orderBy: "date DESC",
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getChronotypeResults(String email) async {
    final db = _database!;
    return await db.query(
      'chronotype_results',
      where: "email = ?",
      whereArgs: [email],
      orderBy: "date DESC",
    );
  }

  static Future<void> deleteChronotypeResult(int id) async {
    final db = _database!;
    await db.delete(
      'chronotype_results',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  static Future<void> deleteAllChronotypeResults(String email) async {
    final db = _database!;
    await db.delete(
      'chronotype_results',
      where: "email = ?",
      whereArgs: [email],
    );
  }
}
