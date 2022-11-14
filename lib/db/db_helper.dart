import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter/foundation.dart';

class DBHelper {
  static const int _version = 1;
  static const String _databaseName = "bludo-test";
  static Database? _db;

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
}
