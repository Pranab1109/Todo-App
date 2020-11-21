import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/models/todo_model.dart';

class DatabaseHelper {
  final String taskdatabaseName = 'Tasks';
  final String tododatabaseName = 'Todo';

  Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $taskdatabaseName (id INTEGER PRIMARY KEY, title TEXT, description TEXT, isDone INT)",
        );
        await db.execute(
          "CREATE TABLE $tododatabaseName (id INTEGER PRIMARY KEY,taskId INTEGER, title TEXT, isDone INT)",
        );
        return db;
      },
      version: 1,
    );
  }

  Future<void> insertTask(Task task) async {
    Database _db = await database();
    await _db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertTodo(Todo todo) async {
    Database _db = await database();
    await _db.insert('todo', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTask() async {
    Database _db = await database();
    List<Map<String, dynamic>> taskMap = await _db.query('Tasks');
    return List.generate(taskMap.length, (index) {
      return Task(
          id: taskMap[index]['id'],
          title: taskMap[index]['title'],
          description: taskMap[index]['description'],
          isDone: taskMap[index]['isDone']);
    });
  }

  Future<List<Todo>> getTodo(int taskId) async {
    Database _db = await database();
    List<Map<String, dynamic>> todoMap =
        await _db.rawQuery("SELECT * FROM Todo WHERE taskId = $taskId");
    return List.generate(todoMap.length, (index) {
      return Todo(
          id: todoMap[index]['id'],
          title: todoMap[index]['title'],
          isDone: todoMap[index]['isDone'],
          taskId: todoMap[index]['taskId']);
    });
  }

  Future<void> updateTodoDone(int id, int isDone) async {
    Database _db = await database();
    await _db
        .rawUpdate(("UPDATE Todo SET isDone = '$isDone' WHERE id= '$id' "));
  }

  Future<void> updateTaskDone(int id, int isDone) async {
    Database _db = await database();
    await _db
        .rawUpdate(("UPDATE Tasks SET isDone = '$isDone' WHERE id= '$id' "));
  }

  Future<void> deleteTask(int id) async {
    Database _db = await database();
    await _db.rawDelete(("DELETE FROM Tasks WHERE id='$id' "));
    await _db.rawDelete(("DELETE FROM Todo WHERE taskId='$id' "));
  }

  // readTask() async {
  //   Database _db = await database();
  //   return await _db.query('Tasks');
  // }

  Future<int> totalTodo(int id) async {
    Database _db = await database();
    final result =
        await _db.rawQuery(("SELECT COUNT(*) FROM Todo WHERE taskId= '$id' "));
    return Sqflite.firstIntValue(result);
  }

  Future<int> totalTodoDone(int id) async {
    Database _db = await database();
    final result = await _db.rawQuery(
        "SELECT COUNT(*) FROM Todo WHERE taskId= ? AND isDone= ? ", [id, 1]);
    return Sqflite.firstIntValue(result);
  }

  Future<int> totalTodoRem(int id) async {
    Database _db = await database();
    final result = await _db.rawQuery(
        "SELECT COUNT(*) FROM Todo WHERE taskId= ? AND isDone= ? ", [id, 0]);
    return Sqflite.firstIntValue(result);
  }
}
