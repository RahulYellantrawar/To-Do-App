import 'package:sqflite/sqflite.dart';
import 'package:to_do/helpers/task.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    final database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute(
              'ALTER TABLE tasks ADD COLUMN completed INTEGER NOT NULL DEFAULT 0');
        }
      },
    );

    return database;
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    final activeTasks = maps
        .where((map) => map['completed'] == 0)
        .map((map) => Task(
              id: map['id'],
              subject: map['subject'],
              date: map['date'],
              time: map['time'],
              completed: false, // Set to false for active tasks
            ))
        .toList();

    return activeTasks;
  }

  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    final List<Task> completedTasks = maps
        .where((map) => map['completed'] == 1)
        .map((map) => Task(
              id: map['id'],
              subject: map['subject'],
              date: map['date'],
              time: map['time'],
              completed: true, // Set to true for completed tasks
            ))
        .toList();

    final List<Task> allTasks = [...completedTasks];

    return allTasks;
  }

  Future<void> updateTask(int taskId, Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMapWithoutId(),
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> updateTaskCompletion(
    int taskId,
    bool completed,
  ) async {
    final db = await database;
    await db.update(
      'tasks',
      {'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> deleteTask(int taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);

  }

  // Other methods for update and delete
}
