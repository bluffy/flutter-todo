import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cbl/cbl.dart';
import '../db/db_helper.dart';

enum TaskActionStatus {
  none,
  add,
  save,
}

enum TaskaAge {
  entry,
  tody,
}

class TaskController extends ChangeNotifier {
  String selectedTaskId = "";
  TaskActionStatus action = TaskActionStatus.none;
  int selectedFolder = 0;
  TaskaAge page = TaskaAge.entry;

  void setSelectedID({required String taskID, int? folderIdx}) {
    selectedTaskId = taskID;
    if (folderIdx != null) {
      selectedFolder = folderIdx;
    }
    action = TaskActionStatus.none;
    notifyListeners();
  }

  bool unSelectTask() {
    if (action == TaskActionStatus.none) {
      setSelectedID(taskID: "", folderIdx: 0);
      return true;
    }

    return false;
  }
}

class TaskModel extends ChangeNotifier {
  /// The private field backing [catalog].
  ///  final List<int> _itemIds = [];
  ///
  late TaskController _controller;
  var taskfolders = <TaskFolder>[];

  TaskListResult getTaskFromList() {
    return taskfolders[_controller.selectedFolder].tasks.firstWhere(
        (TaskListResult task) => task.id == _controller.selectedTaskId,
        orElse: () => TaskListResult(id: "", sort: 0, title: ""));
  }

  set controller(TaskController controller) {
    _controller = controller;
    // Notify listeners, in case the new catalog provides information
    // different from the previous one. For example, availability of an item
    // might have changed.
    notifyListeners();
  }

  void openFormular(TaskActionStatus act) {
    if (act != TaskActionStatus.none) {
      _controller.action = act;
    }
    _controller.notifyListeners();
  }

  void closeFormular() {
    _controller.action = TaskActionStatus.none;
    _controller.notifyListeners();
  }

  void getAllTasks({bool? notify}) async {
    var result = await DBHelper.query();
    TaskFolder taskfolder = TaskFolder(tasks: []);
    List<TaskFolder> taskfolders = [];

    for (var task in result) {
      taskfolder.tasks.add(task);
    }
    taskfolders.add(taskfolder);

    this.taskfolders = taskfolders;
    if (notify == null || notify) {
      notifyListeners();
    }
  }

  void doSorting(int oldItemIndex, int oldListIndex, int newItemIndex,
      int newListIndex) async {
    List<TaskListResult> oldTaskList = [];

    var itemid = taskfolders[oldListIndex].tasks[oldItemIndex].id;

    for (var task in taskfolders[oldListIndex].tasks) {
      oldTaskList.add(task);
    }

    if (oldListIndex != newListIndex) {
      List<TaskListResult> newTaskList = [];
      for (var task in taskfolders[newListIndex].tasks) {
        newTaskList.add(task);
      }
      var movedItem = oldTaskList.removeAt(oldItemIndex);

      newTaskList.insert(newItemIndex, movedItem);
      await DBHelper.sortList(newTaskList);
    } else {
      var movedItem = oldTaskList.removeAt(oldItemIndex);

      oldTaskList.insert(newItemIndex, movedItem);
      await DBHelper.sortList(oldTaskList);
    }
    //_controller.setSelectedID(taskID: itemid);

    getAllTasks();
/*
    var movedItem = taskfolders[oldListIndex].tasks.removeAt(oldItemIndex);
    taskfolders[newListIndex].tasks.insert(newItemIndex, movedItem);
    */
  }

  Future<Task?> get(String id) async {
    final document = await DBHelper.selectById(id);

    if (document == null) {
      return null;
    }

    return Task(
      id: document.id,
      title: document.string('title'),
      description: document.string('description'),
      sort: document.integer('sort'),
      date: document.string('date'),
      dateTime: document.integer('dateTime'),
      isDone: document.integer('isDone'),
      status: document.integer('status'),
      time: document.string('string'),
    );
  }

  Future<String> addTask(String title, String description) async {
    var sorting = 0;
    if (_controller.selectedTaskId != "") {
      final task = getTaskFromList();
      if (task.id != "") {
        sorting = task.sort;
      }
    }
    final Task newTask = Task(
        title: title.trim(), description: description.trim(), sort: sorting);
    final id = await DBHelper.insert(newTask);

    _controller.setSelectedID(taskID: id);

    closeFormular();
    getAllTasks();

    return id;
  }

  Future<String> updateTask(String title, String description) async {
    final Task newTask = Task(
      id: _controller.selectedTaskId,
      title: title.trim(),
      description: description.trim(),
    );
    final id = await DBHelper.update(newTask);
    closeFormular();
    getAllTasks();
    return id;
    //_notificationService.scheduleNotification(newTask, id);
  }

  Future<void> removeTask() async {
    int idx = taskfolders[_controller.selectedFolder].tasks.indexWhere(
        (TaskListResult task) => task.id == _controller.selectedTaskId);

    var newid = "";

    if (idx != -1 &&
        idx != taskfolders[_controller.selectedFolder].tasks.length - 1) {
      newid = taskfolders[_controller.selectedFolder].tasks[idx + 1].id;
    }

    await DBHelper.remove(_controller.selectedTaskId);

    _controller.setSelectedID(taskID: newid);
    getAllTasks();

    closeFormular();
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
