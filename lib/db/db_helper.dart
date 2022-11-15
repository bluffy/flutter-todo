import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class DBHelper {
  //static const int _version = 1;
  static const String _databaseName = "bludo-test";
  static Database? _db;
  static const maxsorting = 100000000000;

  static Future<void> initDatabase() async {
    try {
      await CouchbaseLiteFlutter.init();

      _db = await Database.openAsync(
        _databaseName,
        //'notes-${Random().nextInt(0xFFFFFF)}',
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error to open DB: ${error.toString()}');
      }
    }
  }

  static Future<void> sortList(List<TaskListResult> tasks) async {
    var maxsort = DBHelper.maxsorting;
    for (var task in tasks) {
      maxsort = maxsort - 2;
      var document = await _db!.document(task.id);
      var mutableDoc = document!.toMutable();
      mutableDoc['sort'].integer = maxsort;

      await _db!.saveDocument(mutableDoc);
    }
  }

  static Future<String> insert(Task task) async {
    //final mutableDoc = MutableDocument(task.toJson());

    final mutableDoc = MutableDocument();
    task.fillMutable(mutableDoc);
    if (task.sort == 0 || task.sort == null) {
      mutableDoc["sort"].integer = maxsorting;
    } else {
      mutableDoc["sort"].integer = task.sort! - 1;
    }

    mutableDoc["type"].string = Task.type;
    mutableDoc["insertTimeStamp"].integer =
        DateTime.now().microsecondsSinceEpoch;
    // Now save the new note in the database.
    await _db!.saveDocument(mutableDoc);

    var list = await query();
    await sortList(list);

    return mutableDoc.id;
  }

  static Future<Document?> selectById(String id) async {
    final document = await _db!.document(id);
    return document;
  }

  static Future<String> update(Task task) async {
    final document = await _db!.document(task.id!);
    final mutableDoc = document!.toMutable();
    task.fillMutable(mutableDoc);

    // Now save the new note in the database.
    await _db!.saveDocument(mutableDoc);

    return mutableDoc.id;
  }

  static Future<void> remove(String id) async {
    final document = await _db!.document(id);
    // Now save the new note in the database.
    await _db!.deleteDocument(document!);
    return;
  }

/*
  static Future<List<Map<String, dynamic>>?> query() async {
    final query = await Query.fromN1ql(
      _db!,
      r'''
    SELECT META().id AS id, title, sort
    FROM _ 
     WHERE  type = 'note'
    ORDER BY sort desc  
    LIMIT 1000
    ''',
    );
    final result = await query.execute();
    final results2 = await result.asStream().map((data) => TaskModel.fromJson(data));
    final results3 = await result.allResults();
    //final results = await result.allResults() as List<Map<String, dynamic>>;
    final result1 = result as List<Map<String, dynamic>>;
    return result1;
  }
  */

  static Future<List<TaskListResult>> query(/*Query queryString*/) async {
    final query = await Query.fromN1ql(
      _db!,
      r'''
    SELECT META().id AS id, title, sort, insertTimeStamp
    FROM _ 
     WHERE  type = 'task'
    ORDER BY sort desc, insertTimeStamp desc
    LIMIT 1000
    ''',
    );
    final resultSet = await query.execute();

    final list =
        await resultSet.asStream().map(TaskListResult.fromResult).toList();

    return list;
  }

/*

  static Future<int> insert(TaskModel task) async {
    return await _db?.insert(_tableName, task.toJson()) ?? 1;
  }

  static Future<List<Map<String, dynamic>>?> query() async {
    return await _db?.query(_tableName);
  }

  static Future<void> delete(TaskModel task) async {
    await _db!.delete(_tableName, where: 'id=?', whereArgs: [task.id]);
  }

  static Future<void> update(int id) async {
    await _db!.rawUpdate('''
    UPDATE $_tableName
    SET $_columnIsDone = ?
    WHERE id =?
    ''', [1, id]);
  }

  static Future<void> updateFav(int id) async {
    await _db!.rawUpdate('''
    UPDATE $_tableName
    SET $_columnIsFavorite = ?
    WHERE id =?
    ''', [1, id]);
  }

  static Future<void> removeFav(int id) async {
    await _db!.rawUpdate(
      '''
    UPDATE $_tableName 
    SET $_columnIsFavorite = ? WHERE id =?''',
      [0, id],
    );
  }

  static Future<void> updateTaskStatus(int id, String status) async {
    await _db!.rawUpdate('''
    UPDATE $_tableName
    SET $_columnStatus = ?
    WHERE id =?
    ''', [status, id]);
  }

  static Future<List<Map<String, dynamic>>> queryTaskById(int id) async {
    return await _db!.query(_tableName, where: '$_columnId=?', whereArgs: [id]);
  }
  */

}
