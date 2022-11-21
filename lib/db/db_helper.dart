import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/task_model.dart';
import 'dart:io' show Platform;

class DBHelper {
  static Database? _db;
  static const int version = 1;
  static const String _databaseName = "todo-2.sqlite";

  static String formatISOTime({DateTime? iDate}) {
    DateTime date;
    if (iDate == null) {
      date = DateTime.now();
    } else {
      date = iDate;
    }

    return date.toIso8601String();

/*
    if (duration.isNegative) {
      date.subtract(duration);
      /*
      return (date.toIso8601String() +
          "-${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
          */
    } else
      return (date.toIso8601String() +
          "+${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");  */
  }

  /*
  static String formatISOTime({DateTime? date}) {
    if (date == null) {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());
    } else {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(date);
    }
    //converts date into the following format:
// or 2019-06-04T12:08:56.235-0700
/*
    var duration = date.timeZoneOffset;
    if (duration.isNegative) {
      return (DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(date) + "-${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    } else {
      return (DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(date) + "+${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    }
    */
  }
  */

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
                , date           VARCHAR(25)    DEFAULT NULL
                , date_created   VARCHAR(25)    DEFAULT NULL
                , date_updated   VARCHAR(25)    DEFAULT NULL
                , sync_updated   INTEGER        DEFAULT NULL
                , sync_sort_update   INTEGER        DEFAULT NULL
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

  static Future<String> insertTask(Task task, {int? sort}) async {
    task.id = await nextID();
    var map = task.toMap();
    map["sync_updated"] = 1;
    map["date_created"] = formatISOTime();
    map["date_updated"] = map["date_inserted"];

    if (sort == 0 || sort == null) {
      map["sort"] = 0;
    } else {
      map["sort"] = sort + 1;
    }

    await _db!.insert(
      'tasks',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await sortList();
    return task.id!;
  }

  static Future<List<Map<String, Object?>>> taskList() async {
    return await _db!
        .query('tasks', orderBy: "sort,date_created desc", limit: 1000);
  }

  static Future<Map<String, Object?>> getTaskByID(String id) async {
    var result = await _db!.query('tasks', where: 'id = $id');
    return result.first;
  }

  static Future<void> updateTask(Task task) async {
    var map = task.toMap();

    map["sync_updated"] = 1;
    map["date_updated"] = formatISOTime();

    await _db!.update(
      'tasks',
      map,
      where: "id = ${task.id}",
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return;
  }

  static Future<void> sortList() async {
    var maxsort = 0;
    var tasks = await _db!
        .query('tasks', orderBy: "sort, date_created desc", limit: 1000);

    for (var task in tasks) {
      maxsort = maxsort + 2;
      // task["sync_sort_update"] = 1;
      await _db!.rawUpdate("""
          update tasks set sort = $maxsort, sync_sort_update = 1 where id = ${task["id"]}
      """);
    }

    /*
    for (var task in tasks) {
      maxsort = maxsort - 2;
      var document = await _db!.document(task.id);
      var mutableDoc = document!.toMutable();
      mutableDoc['sort'].integer = maxsort;

      await _db!.saveDocument(mutableDoc);
    }
    */
  }
}
