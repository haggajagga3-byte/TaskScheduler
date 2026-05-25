import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'taskscheduler.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT 'Other',
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        day TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // INSERT
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // INSERT BATCH (for AI-generated timetable)
  Future<void> insertTasks(List<TaskModel> tasks) async {
    final db = await database;
    final batch = db.batch();
    for (final task in tasks) {
      batch.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // GET ALL
  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map(TaskModel.fromMap).toList();
  }

  // GET TODAY'S TASKS
  Future<List<TaskModel>> getTodayTasks() async {
    final db = await database;
    final today = _getDayName(DateTime.now().weekday);
    final todayDate = DateTime.now();
    final todayStr =
        '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

    // Match by day name OR by today's date in createdAt
    final maps = await db.query(
      'tasks',
      where: 'day = ? OR createdAt LIKE ?',
      whereArgs: [today, '$todayStr%'],
      orderBy: 'startTime ASC',
    );
    return maps.map(TaskModel.fromMap).toList();
  }

  // UPDATE
  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE
  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // MARK COMPLETE
  Future<int> markTaskCompleted(int id, bool completed) async {
    final db = await database;
    return db.update(
      'tasks',
      {'isCompleted': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[(weekday - 1) % 7];
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
