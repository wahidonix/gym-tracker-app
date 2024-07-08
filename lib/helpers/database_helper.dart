import 'package:gym_tracker/models/exercise_model.dart';
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
      version: 4,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
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

    await db.execute('''
      CREATE TABLE exercise_sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        date TEXT,
        order_index INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        set_id INTEGER,
        name TEXT,
        weight REAL,
        reps INTEGER,
        negative_reps INTEGER,
        FOREIGN KEY (set_id) REFERENCES exercise_sets(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER,
        date TEXT,
        weight REAL,
        reps INTEGER,
        negative_reps INTEGER,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id)
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE exercise_progress(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          exercise_id INTEGER,
          date TEXT,
          weight REAL,
          reps INTEGER,
          negative_reps INTEGER,
          FOREIGN KEY (exercise_id) REFERENCES exercises(id)
        )
      ''');
    }
    if (oldVersion < 4) {
      await db
          .execute('ALTER TABLE exercise_sets ADD COLUMN order_index INTEGER');

      // Initialize order_index for existing rows
      var sets = await db.query('exercise_sets', orderBy: 'id ASC');
      for (int i = 0; i < sets.length; i++) {
        await db.update('exercise_sets', {'order_index': i},
            where: 'id = ?', whereArgs: [sets[i]['id']]);
      }
    }
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

  Future<Map<String, dynamic>?> getLastWeightLog() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'daily_logs',
      orderBy: 'date DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getRecentWeightLogs(int days) async {
    Database db = await database;
    return await db.query(
      'daily_logs',
      orderBy: 'date DESC',
      limit: days,
    );
  }

  Future<int> insertExerciseSet(String name, String date) async {
    Database db = await database;
    int maxOrder = Sqflite.firstIntValue(
            await db.rawQuery('SELECT MAX(order_index) FROM exercise_sets')) ??
        -1;
    return await db.insert('exercise_sets', {
      'name': name,
      'date': date,
      'order_index': maxOrder + 1,
    });
  }

  Future<int> insertExercise(
      int setId, String name, double weight, int reps, int negativeReps) async {
    Database db = await database;
    return await db.insert('exercises', {
      'set_id': setId,
      'name': name,
      'weight': weight,
      'reps': reps,
      'negative_reps': negativeReps,
    });
  }

  Future<List<Map<String, dynamic>>> getExerciseSets() async {
    Database db = await database;
    return await db.query('exercise_sets', orderBy: 'order_index ASC');
  }

  Future<List<Map<String, dynamic>>> getExercisesForSet(int setId) async {
    Database db = await database;
    return await db.query('exercises', where: 'set_id = ?', whereArgs: [setId]);
  }

  Future<int> updateExercise(
      int id, String name, double weight, int reps, int negativeReps) async {
    Database db = await database;
    return await db.update(
      'exercises',
      {
        'name': name,
        'weight': weight,
        'reps': reps,
        'negative_reps': negativeReps,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExercise(int id) async {
    Database db = await database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteExerciseSet(int id) async {
    Database db = await database;
    await db.delete('exercises', where: 'set_id = ?', whereArgs: [id]);
    return await db.delete('exercise_sets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
    Database db = await database;
    return await db.query('exercises');
  }

  Future<void> logExerciseProgress(int exerciseId, String date, double weight,
      int reps, int negativeReps) async {
    Database db = await database;

    // Check if an entry already exists for this exercise on this date
    List<Map<String, dynamic>> existing = await db.query(
      'exercise_progress',
      where: 'exercise_id = ? AND date = ?',
      whereArgs: [exerciseId, date],
    );

    if (existing.isNotEmpty) {
      // If an entry exists, update it
      await db.update(
        'exercise_progress',
        {
          'weight': weight,
          'reps': reps,
          'negative_reps': negativeReps,
        },
        where: 'exercise_id = ? AND date = ?',
        whereArgs: [exerciseId, date],
      );
    } else {
      // If no entry exists, insert a new one
      await db.insert(
        'exercise_progress',
        {
          'exercise_id': exerciseId,
          'date': date,
          'weight': weight,
          'reps': reps,
          'negative_reps': negativeReps,
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> getDailyExercises(String date) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT e.id, e.name, ep.weight, ep.reps, ep.negative_reps
      FROM exercises e
      LEFT JOIN exercise_progress ep ON e.id = ep.exercise_id AND ep.date = ?
      WHERE ep.id IS NOT NULL
    ''', [date]);
  }

  Future<List<Map<String, dynamic>>> getExerciseProgress(int exerciseId) async {
    Database db = await database;
    return await db.query(
      'exercise_progress',
      columns: ['date', 'weight', 'reps', 'negative_reps'],
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'date ASC',
    );
  }

  Future<void> updateExerciseSetOrder(List<ExerciseSet> sets) async {
    final db = await database;
    await db.transaction((txn) async {
      for (int i = 0; i < sets.length; i++) {
        await txn.update(
          'exercise_sets',
          {'order_index': i},
          where: 'id = ?',
          whereArgs: [sets[i].id],
        );
      }
    });
  }

  Future<int> renameExerciseSet(int id, String newName) async {
    Database db = await database;
    return await db.update(
      'exercise_sets',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
