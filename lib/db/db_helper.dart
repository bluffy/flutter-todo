import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/task_model.dart';
import 'dart:io' show Platform;

class DBHelper {
  static Database? _db;
  static const int version = 1;
  static const String _databaseName = "todo-1.sqlite";

  static Future<void> initDatabase() async {
    try {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      var test = await getDatabasesPath();

      debugPrint("DB PAtj: $test");

      _db = await openDatabase(
        version: version,
        join(await getDatabasesPath(), _databaseName),
        onCreate: (db, version) {
          // Run the CREATE TABLE statement on the database.
          debugPrint("DB Version: ${version.toString()}");
          db.execute("""
             CREATE TABLE settings(
                  max_id   INTEGER  default 0
            )""");
          db.execute("""
            insert INTO settings(max_id) values (0);
            """);
          db.execute("""
             CREATE TABLE tasks(
                  id             VARCHAR(100)   PRIMARY KEY
                , sync_id        VARCHAR(1000)  DEFAULT NULL
                , title          VARCHAR(1000)  DEFAULT NULL
                , description    VARCHAR(4000)  DEFAULT NULL
                , sort           INTEGER        DEFAULT NULL
                , is_done        INTEGER        DEFAULT NULL
                , date           VARCHAR(100)   DEFAULT NULL
                , time           INTEGER        DEFAULT NULL
                , date_time      INTEGER        DEFAULT NULL
                , status         INTEGER        DEFAULT NULL
            )""");

          return null;
        },
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error to open DB: ${error.toString()}');
      }
    }
  }

  static Future<String> nextID() async {
    await _db!.rawUpdate("""
        UPDATE settings set max_id = max_id + 1;
        """);
    var result = await _db!.rawQuery("SELECT max_id FROM settings");
    return result[0]["max_id"].toString();
  }

  static Future<String> insertTask(Task task) async {
    task.id = await nextID();
    await _db!.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return task.id!;
  }

  static Future<List<Map<String, Object?>>> taskList() async {
    return await _db!.query('tasks', orderBy: "sort desc");
  }
}
