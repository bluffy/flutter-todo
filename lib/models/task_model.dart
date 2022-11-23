import 'package:flutter/cupertino.dart';
import 'package:flutter_todo/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
part 'task_model.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int? sort;

  Task({required this.title, required this.description, this.sort});
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
    getList();
  }

  final Ref ref;

  Future<int> addTask(title, description) async {
    //final selectedTask = getSelectedTask();

    final task = Task(title: title, description: description);

    var box = Hive.box<Task>(boxNameTasks);
    task.sort = box.values.length + 1;

    var id = await box.add(task);

    ref.read(taskActionProvider.notifier).state = TaskAction.none;

    getList();

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
    getList();
  }

  Future<void> removeTask() async {
    final selectedID = getSelectedID();

    if (selectedID == -1) {
      return;
    }
    final list = state;

    int idx = list.indexWhere((Task task) => task.key == selectedID);
    var newid = -1;

    if (idx != -1 && idx != list.length - 1) {
      newid = list[idx + 1].key!;
    }

    var box = Hive.box<Task>(boxNameTasks);
    await box.delete(selectedID);

    ref.read(taskSelectProvider.notifier).state = newid;
    closeFormular();
    getList();

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

  getList() {
    var box = Hive.box<Task>(boxNameTasks);
    var list = box.values.toList();
    state = list;
    debugPrint("getList()");
    //state = box.values.toList();

/*
    List<Map<String, dynamic>> tasks = await DBHelper.taskList();

    state = tasks.map((data) => Task.fromJson(data)).toList();
    */
  }

  doListSorting(
      {String? targetID, required String sourceID, bool? last}) async {
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
