import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

import '../models/task.dart';

class DatabaseService {

  static Database? _db;
  
  static final DatabaseService instance = DatabaseService._constructor();
  
  final String _taskTableName = "task";
  final String _taskIdColumnName = "id";
  final String _taskContentColumnName = "content";
  final String _taskStatusColumnName = "status"; 
  
  DatabaseService._constructor();

  Future<Database> get database async{
    if(_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

 Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath,"master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
      db.execute('''
      CREATE TABLE $_taskTableName (
        $_taskIdColumnName INTEGER PRIMARY KEY,
        $_taskContentColumnName TEXT NOT NULL,
        $_taskStatusColumnName INTEGER NOT NULL
      )
      ''');
      }
    );
    return database;
 }


  void addTask(
    String content,
    ) async {
      final db = await database;
      await db.insert(_taskTableName,
        {
          _taskContentColumnName: content,
          _taskStatusColumnName: 0,
        } 
      );
    }


  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_taskTableName,);
    List<Task> tasks = data
    .map((e) => 
      Task(id: e["id"] as int, status: e["status"] as int , content: e["content"] as String))
    .toList();
    return tasks;
  }

  void updateTaskStatus (int id, int status) async {
    final db = await database;
    await db.update(
      _taskTableName,
      {_taskStatusColumnName: status},
      where: 'id = ?',
      whereArgs: [id,],
    );
  }

  void deleteTask(int id) async {
    final db = await database;
    await db.delete(
      _taskTableName,
      where: 'id = ?',
      whereArgs: [id,],
    );
  }
}