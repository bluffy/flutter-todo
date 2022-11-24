import 'package:hive_flutter/hive_flutter.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int sort;

  @HiveField(100)
  bool synSort;

  @HiveField(101)
  bool synUpdate;

  Task(
      {required this.title,
      required this.description,
      this.sort = 0,
      this.synSort = true,
      this.synUpdate = true});
}

@HiveType(typeId: 2)
class Folder {
  @HiveField(0)
  String title;

  Folder(this.title);
}
