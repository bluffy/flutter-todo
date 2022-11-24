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

enum Navi {
  inbox,
  today,
  folder,
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier(this.ref) : super([]) {
    _fillFromHive();
  }

  final Ref ref;

  //List<Task>
  int _getTaskIndex(List<Task> tasks, int key) {
    return tasks.indexWhere((Task task) => task.key == key);
  }

  _reSort(List<Task> list) {
    //var tasks = list.toList();
    var cnt = 0;
    for (var task in list.reversed.toList()) {
      cnt = cnt + 2;
      if (task.sort != cnt) {
        task.sort = cnt;
        task.synSort = true;
        task.save();
      }
    }
    // return tasks;
  }

  _sortState([List<Task>? ptasks]) {
    List<Task> tasks;
    if (ptasks != null) {
      tasks = ptasks;
    } else {
      tasks = state;
    }

    if (tasks.isNotEmpty) {
      if (tasks.length > 1) {
        tasks.sort((a, b) => -a.sort.compareTo(b.sort));
      }

      state = tasks;
      return;
    }

    state = [];
  }

  Future<int> addTask(title, description) async {
    final selectedId = getSelectedID();
    final tasks = state.toList();

    final task = Task(title: title, description: description);
    task.synUpdate = true;

    final id = await Hive.box<Task>(boxNameTasks).add(task);

    if (selectedId == -1) {
      tasks.insert(0, task);
    } else {
      final idx = _getTaskIndex(tasks, selectedId);
      tasks.insert(idx + 1, task);
    }
    _reSort(tasks);
    _sortState(tasks);

    ref.read(taskActionProvider.notifier).state = TaskAction.none;
    ref.read(taskSelectProvider.notifier).state = id;
    return id;
  }

  int getSelectedID() {
    return ref.read(taskSelectProvider.notifier).state;
  }

  Future<void> updateTask(String title, String description) async {
    var task = getSelectedTask();
    task!.title = title;
    task.description = description;

    Hive.box<Task>(boxNameTasks).put(task.key, task);
    //getList();
  }

  Future<void> removeTask() async {
    final selectedID = getSelectedID();

    if (selectedID == -1) {
      return;
    }
    final list = state.toList();

    int idx = _getTaskIndex(list, selectedID);
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
  }

  doListSorting({int? targetID, required int sourceID, bool? last}) async {
    var tasks = state.toList();

    final sourceTask = tasks.singleWhere((task) => task.key == sourceID,
        orElse: () => Task(title: "", description: ""));
    if (sourceTask.key == null) {
      return;
    }

    int idxSourceTask = _getTaskIndex(tasks, sourceID);
    if (idxSourceTask == -1) return;

    tasks.removeAt(idxSourceTask);

    if (last != null && last == true) {
      tasks.add(sourceTask);
    } else {
      int idxTarget = _getTaskIndex(tasks, targetID!);
      if (idxTarget == -1) return;
      tasks.insert(idxTarget, sourceTask);
    }

    _reSort(tasks);
    _sortState(tasks);

    state = tasks.toList();
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
final naviSelectProvider = StateProvider((ref) => Navi.inbox);

final taskskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref);
});
