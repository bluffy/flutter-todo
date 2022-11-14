import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cbl/cbl.dart';

enum TaskActionStatus {
  none,
  add,
  save,
}

class TaskController extends ChangeNotifier {
  String? selectedTaskId;
  TaskActionStatus action = TaskActionStatus.none;
}

class TaskModel extends ChangeNotifier {
  /// The private field backing [catalog].
  ///  final List<int> _itemIds = [];
  ///
  late TaskController _controller;
  final List<int> _itemIds = [];
  set controller(TaskController controller) {
    _controller = controller;
    // Notify listeners, in case the new catalog provides information
    // different from the previous one. For example, availability of an item
    // might have changed.
    //notifyListeners();
  }

  void openFormular(TaskActionStatus act) {
    _controller.action = act;
    _controller.notifyListeners();

    //isFormOpen.value = true;
  }

  get test {
    return _controller.action.toString();
  }
}

class TaskFolder {
  TaskFolder({this.catID, this.catTitle, required this.tasks});

  final String? catTitle;
  final String? catID;
  final List<TaskListResult> tasks;
}

class Task {
  String? id;
  String? title;
  String? description;
  int? sort;
  int? isDone;
  String? date;
  String? time;
  int? dateTime;
  int? status;
  static const type = "task";

  Task(
      {this.id,
      this.title,
      this.description,
      this.sort,
      this.isDone,
      this.date,
      this.time,
      this.dateTime,
      this.status});

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    isDone = json['isDone'];
    date = json['date'];
    time = json['time'];
    status = json['status'];
  }
  void fillMutable(MutableDocument mutableDoc) {
    //mutableDoc['type'].string = type;
    if (sort != null) {
      mutableDoc['sort'].integer = sort!;
    }
    if (title != null) {
      mutableDoc['title'].string = title;
    }
    if (description != null) {
      mutableDoc['description'].string = description;
    }
    if (description != null) {
      mutableDoc['description'].string = description;
    }
    if (time != null) {
      mutableDoc['time'].string = time;
    }
    if (dateTime != null) {
      mutableDoc['dateTime'].integer = dateTime!;
    }
    if (status != null) {
      mutableDoc['status'].integer = status!;
    }
    if (sort != null) {
      mutableDoc['sort'].integer = sort!;
    }
  }
}

class TaskListResult {
  TaskListResult({required this.id, required this.title, required this.sort});

  /// This method creates a NoteSearchResult from a query result.
  static TaskListResult fromResult(Result result) => TaskListResult(
        // The Result type has typed getters, to extract values from a result.
        id: result.string('id')!,
        title: result.string('title')!,
        sort: result.integer('sort'),
      );

  final String id;
  final String title;
  final int sort;
}
