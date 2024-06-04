import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataService {
  static Database? _database;

  static Future<void> init() async {
    if (_database != null) return;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, password TEXT, phone TEXT, imagePath TEXT)",
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

  static Future<void> saveSurveyAnswer(int index, String answer) async {
    // 설문 답변 저장 로직 추가
    print('Saved answer for question $index: $answer');
  }



}
