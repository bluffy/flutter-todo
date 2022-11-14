import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TaskModel extends ChangeNotifier {
  /// The private field backing [catalog].
  ///  final List<int> _itemIds = [];
  ///
  final List<int> _itemIds = [];

  Task getById(int id) => Task(id);
}

@immutable
class Task {
  final String? id;
  final String? title;
  final String? description;
  final int? sort;
  final int? isDone;
  final String? date;
  final String? time;
  final int? dateTime;
  final int? status;
  final int? insertTimeStamp;
  static const type = "task";

  const Task(this.id, this.title, this.description, this.sort, this.isDone,
      this.date, this.time, this.dateTime, this.status, this.insertTimeStamp);
}
