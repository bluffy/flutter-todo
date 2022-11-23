import 'package:flutter/cupertino.dart';
import 'package:flutter_todo/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

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

enum TaskAction {
  none,
  add,
  save,
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier(this.ref) : super([]) {
    _fillFromHive();
  }

  final Ref ref;

  //List<Task>
  _reSort(List<Task> list) {
    //var tasks = list.toList();
    var cnt = 0;
    for (var task in list.reversed.toList()) {
      cnt = cnt + 1;
      if (task.sort != cnt) {
        task.sort = cnt;
        task.synSort = true;
        task.save();
      }
    }
    // return tasks;
  }

  _sortList(List<Task> tasks) {
    var list = tasks.toList();
    if (list.length > 1) {
      list.sort((a, b) => -a.sort.compareTo(b.sort));
      return list;
    }
    return list;
  }

  _sortState([List<Task>? ptasks]) {
    List<Task> tasks;
    if (ptasks != null) {
      tasks = ptasks;
    } else {
      tasks = state;
    }
    if (tasks.isNotEmpty) {
      state = _sortList(tasks);
    }
  }

  Future<int> addTask(title, description) async {
    //final selectedTask = getSelectedTask();

    final task = Task(title: title, description: description);
    task.synUpdate = true;

    var box = Hive.box<Task>(boxNameTasks);

    var tasks = state.toList();
    var id = await box.add(task);

    var selectedTask = getSelectedTask();

    if (selectedTask == null) {
      var max = maxBy(tasks, (task) => task.sort);
      task.sort = (max == null) ? 1 : max.sort + 1;
      tasks.add(task);
    } else {
      task.sort = selectedTask.sort;
      tasks.add(task);
      Map<int, Task> saveList = {};
      for (var taskElement in tasks) {
        taskElement.sort = taskElement.sort + 1;
        taskElement.synSort = true;
        saveList[taskElement.key] == taskElement;
        if (taskElement.key == selectedTask.key) {
          break;
        }
      }

      box.putAll(saveList);
    }

    _sortState(tasks);

    ref.read(taskActionProvider.notifier).state = TaskAction.none;
    ref.read(taskSelectProvider.notifier).state = id;
    return id;
  }

  int getSelectedID() {
    return ref.read(taskSelectProvider.notifier).state;
  }

  Future<void> updateTask(String title, String description) async {
    var box = Hive.box<Task>(boxNameTasks);

    var task = getSelectedTask();
    task!.title = title;
    task.description = description;

    box.put(task.key, task);
    //getList();
  }

  Future<void> removeTask() async {
    final selectedID = getSelectedID();

    if (selectedID == -1) {
      return;
    }
    final list = state.toList();

    int idx = list.indexWhere((Task task) => task.key == selectedID);
    var newid = -1;

    if (idx != -1 && idx != list.length - 1) {
      newid = list[idx + 1].key!;
    }

    var box = Hive.box<Task>(boxNameTasks);
    await box.delete(selectedID);

    list.removeAt(idx);
    state = list.toList();

    ref.read(taskSelectProvider.notifier).state = newid;
    closeFormular();
    //getList();

/*
    int idx = list.indexWhere((Task task) => task.id == selectedID);

    var newid = "";



    await DBHelper.removeTask(selectedID);

    ref.read(taskSelectProvider.notifier).state = newid;
    closeFormular();

    getList();
    */
  }

  Task? getSelectedTask() {
    if (getSelectedID() != -1) {
      var box = Hive.box<Task>(boxNameTasks);
      return box.get(getSelectedID());
    }
    return null;
  }

  _fillFromHive() {
    var box = Hive.box<Task>(boxNameTasks);
    var list = box.values.toList();
    _sortState(list);
    debugPrint("_fillFromHive()");
    //state = box.values.toList();

/*
    List<Map<String, dynamic>> tasks = await DBHelper.taskList();

    state = tasks.map((data) => Task.fromJson(data)).toList();
    */
  }

  doListSorting({int? targetID, required int sourceID, bool? last}) async {
    var tasks = state.toList();

    final sourceTask = tasks.singleWhere((task) => task.key == sourceID,
        orElse: () => Task(title: "", description: ""));
    if (sourceTask.key == null) {
      return;
    }
    final targetTask = tasks.singleWhere((task) => task.key == targetID,
        orElse: () => Task(title: "", description: ""));
    if (targetTask.key == null) {
      return;
    }

    int idxSourceTask = tasks.indexWhere((Task task) => task.key == sourceID);

    tasks.removeAt(idxSourceTask);

    int idxTarget = tasks.indexWhere((Task task) => task.key == targetID);

    tasks.insert(idxTarget, sourceTask);

    _reSort(tasks);
    _sortState(tasks);

/*
    Map<int, Task> saveList = {};
    for (var task in tasks) {
      var taskBox = box.get(task.key);
      if (taskBox != null && task.sort != taskBox.sort) {
        task.synSort = true;
        saveList[task.key] = task;
      }
    }

    */
    for (var task in tasks) {
      task.synSort = true;
      task.save();
    }

    state = tasks.toList();
    /*
    final tasks = state.toList();
    final targetTask = tasks.singleWhere((task) => task.key == targetID,
        orElse: () => Task(title: "", description: ""));
    if (targetTask.key == null) {
      return;
    }
    final sourceTask = tasks.singleWhere((task) => task.key == sourceID,
        orElse: () => Task(title: "", description: ""));
    if (sourceTask.key == null) {
      return;
    }

    if (sourceTask.sort == targetTask.sort) {
      return;
    }
    Map<int, Task> saveList = {};
    var inLoop = false;
    if (sourceTask.sort < targetTask.sort) {
      for (var taskEelement in tasks) {
        if (taskEelement.key == targetID) {
          inLoop = true;
        }
        if (taskEelement.key == sourceID) {
          taskEelement.sort = targetTask.sort;
          taskEelement.synSort = true;
          saveList[taskEelement.key] = taskEelement;
          inLoop = false;
          break;
        }
        if (inLoop) {
          taskEelement.sort = taskEelement.sort - 1;
          taskEelement.synSort = true;
          saveList[taskEelement.key] = taskEelement;
        }
      }
      _sortState(tasks);
      var box = Hive.box<Task>(boxNameTasks);
      box.putAll(saveList);
    }
    */

    /*
    if (last != null && last) {
      await DBHelper.doListSorting(null, sourceID, last);
      getList();
      return;
    }

    if (targetID == null) {
      return;
    }

    if (targetID == sourceID) {
      return;
    }
    await DBHelper.doListSorting(targetID, sourceID, false);
    getList();
    */
  }

  selectTask(int taskID) {
    ref.read(taskSelectProvider.notifier).state = taskID;
  }

  unSelectTask() {
    if (ref.read(taskActionProvider.notifier).state == TaskAction.none) {
      ref.read(taskSelectProvider.notifier).state = -1;
    }
  }

  openFormular(TaskAction act) {
    if (act != TaskAction.none) {
      ref.read(taskActionProvider.notifier).state = act;
    }
  }

  closeFormular() {
    ref.read(taskActionProvider.notifier).state = TaskAction.none;
  }
}

final taskActionProvider = StateProvider((ref) => TaskAction.none);
final taskSelectProvider = StateProvider((ref) => -1);

final taskskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref);
});
