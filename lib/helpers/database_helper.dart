import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        height REAL,
        target_weight REAL,
        is_gain_weight INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE,
        weight REAL
      )
    ''');
  }

  Future<int> insertUserProfile(
      double height, double targetWeight, bool isGainWeight) async {
    Database db = await database;
    return await db.insert('user_profile', {
      'height': height,
      'target_weight': targetWeight,
      'is_gain_weight': isGainWeight ? 1 : 0,
    });
  }

  Future<int> updateUserProfile(
      double height, double targetWeight, bool isGainWeight) async {
    Database db = await database;
    return await db.update(
      'user_profile',
      {
        'height': height,
        'target_weight': targetWeight,
        'is_gain_weight': isGainWeight ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [1], // Assuming there's only one profile record
    );
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    Database db = await database;
    List<Map<String, dynamic>> results =
        await db.query('user_profile', limit: 1);
    if (results.isNotEmpty) {
      return results.first;
    }
    return {};
  }

  Future<bool> hasUserProfile() async {
    Database db = await database;
    List<Map<String, dynamic>> results =
        await db.query('user_profile', limit: 1);
    return results.isNotEmpty;
  }

  // Daily Log methods
  Future<int> insertOrUpdateDailyLog(String date, double weight) async {
    Database db = await database;
    return await db.insert(
      'daily_logs',
      {'date': date, 'weight': weight},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getDailyLogs() async {
    Database db = await database;
    return await db.query('daily_logs', orderBy: 'date ASC');
  }

  Future<int> deleteWeightLog(int id) async {
    Database db = await database;
    return await db.delete(
      'daily_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
