import 'package:flutter/cupertino.dart';
import 'package:flutter_todo/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';

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

class TaskListState extends StateNotifier<List<Task>> {
  TaskListState(this.ref) : super([]) {
    _listentry = [];
    _lisToday = [];
    _fillCache(ref.read(naviSelectProvider));
  }

  late List<Task> _listentry;
  late List<Task> _lisToday;
  //List<Task> _listToday;

  final Ref ref;
  List<Task> _getNaviList(navi) {
    switch (navi) {
      case Navi.today:
        return _lisToday.toList();
      default:
        return _listentry.toList();
    }
  }

  _fillCache(Navi navi) {
    var box = Hive.box<Task>(Constants.boxNameTasks);
    for (var task in box.values) {
      if (task.itemLocation == ItemLocation.inbox) {
        _listentry.add(task);
      } else if (task.itemLocation == ItemLocation.today) {
        _lisToday.add(task);
      }
    }
    _sortList(_listentry);
    _setSortInTaskItems(_listentry);

    _sortList(_lisToday);
    _setSortInTaskItems(_lisToday);

    state = _getNaviList(navi);
  }

  _saveCache(List<Task> tasks, Navi navi) {
    state = tasks.toList();

    switch (navi) {
      case Navi.inbox:
        _listentry = state.toList();
        break;
      case Navi.today:
        _lisToday = state.toList();
        break;
      default:
        break;
    }
  }

  int _getTaskIndex(List<Task> tasks, int key) {
    return tasks.indexWhere((Task task) => task.key == key);
  }

  _setSortInTaskItems(List<Task> list) {
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
  }

  _sortList(List<Task> tasks) {
    if (tasks.length > 1) {
      tasks.sort((a, b) => -a.sort.compareTo(b.sort));
    }
  }

  loadState([Navi? navi]) {
    Navi lNavi;
    if (navi != null) {
      lNavi = navi;
    } else {
      lNavi = ref.read(naviSelectProvider);
    }

    ref.read(taskSelectProvider.notifier).state = -1;
    state = _getNaviList(navi);
    ref.read(naviSelectProvider.notifier).state = lNavi;
  }

  Future<int> addTask(title, description) async {
    final selectedId = getSelectedID();
    final tasks = state.toList();
    final navi = getSelectedNavi();
    //late ItemLocation location;

    final task = Task(title: title, description: description);

    switch (navi) {
      case Navi.inbox:
        task.itemLocation = ItemLocation.inbox;
        break;
      case Navi.today:
        task.itemLocation = ItemLocation.today;
        break;
      default:
        task.itemLocation = ItemLocation.inbox;
    }

    task.synUpdate = true;

    final id = await Hive.box<Task>(Constants.boxNameTasks).add(task);

    if (selectedId == -1) {
      tasks.insert(0, task);
    } else {
      final idx = _getTaskIndex(tasks, selectedId);
      tasks.insert(idx + 1, task);
    }

    _setSortInTaskItems(tasks);

    _saveCache(tasks, navi);

    ref.read(taskActionProvider.notifier).state = TaskAction.none;
    ref.read(taskSelectProvider.notifier).state = id;
    return id;
  }

  int getSelectedID() {
    return ref.read(taskSelectProvider.notifier).state;
  }

  Navi getSelectedNavi() {
    return ref.read(naviSelectProvider.notifier).state;
  }

  Future<void> updateTask(String title, String description) async {
    var task = getSelectedTask();
    task!.title = title;
    task.description = description;

    Hive.box<Task>(Constants.boxNameTasks).put(task.key, task);
    //getList();
  }

  Future<void> removeTask() async {
    final selectedID = getSelectedID();
    final navi = ref.read(naviSelectProvider);

    if (selectedID == -1) {
      return;
    }
    final tasks = state.toList();

    int idx = _getTaskIndex(tasks, selectedID);
    var newid = -1;

    if (idx != -1 && idx != tasks.length - 1) {
      newid = tasks[idx + 1].key!;
    }

    var box = Hive.box<Task>(Constants.boxNameTasks);
    await box.delete(selectedID);

    tasks.removeAt(idx);

    _saveCache(tasks, navi);
    ref.read(taskSelectProvider.notifier).state = newid;
  }

  Task? getSelectedTask() {
    if (getSelectedID() != -1) {
      var box = Hive.box<Task>(Constants.boxNameTasks);
      return box.get(getSelectedID());
    }
    return null;
  }

  doListSorting({int? targetID, required int sourceID, bool? last}) async {
    final navi = ref.read(naviSelectProvider);
    var tasks = state.toList();

    int idxSourceTask = _getTaskIndex(tasks, sourceID);
    if (idxSourceTask == -1) return;

    var sourceTask = tasks[idxSourceTask];

    tasks.removeAt(idxSourceTask);

    if (last != null && last == true) {
      tasks.add(sourceTask);
    } else {
      int idxTarget = _getTaskIndex(tasks, targetID!);
      if (idxTarget == -1) return;
      tasks.insert(idxTarget, sourceTask);
    }

    _setSortInTaskItems(tasks);
    _saveCache(tasks, navi);
  }

  doListSortingFromMenu(int sourceID, Navi targetNavi) async {
    final navi = ref.read(naviSelectProvider);

    if (targetNavi == ref.read(naviSelectProvider)) {
      return;
    }
    var tasks = state.toList();

    int idxSourceTask = _getTaskIndex(tasks, sourceID);
    var sourceTask = tasks[idxSourceTask];

    if (idxSourceTask == -1) return;
    tasks.removeAt(idxSourceTask);

    switch (targetNavi) {
      case Navi.inbox:
        sourceTask.itemLocation = ItemLocation.inbox;
        _listentry.insert(0, sourceTask);
        _setSortInTaskItems(_listentry);
        break;
      case Navi.today:
        sourceTask.itemLocation = ItemLocation.today;
        _lisToday.insert(0, sourceTask);
        _setSortInTaskItems(_lisToday);
        break;
      default:
        sourceTask.itemLocation = ItemLocation.inbox;
        _listentry.insert(0, sourceTask);
        _setSortInTaskItems(_listentry);
    }

    _setSortInTaskItems(tasks);
    _saveCache(tasks, navi);

    ref.read(taskSelectProvider.notifier).state = -1;

    //_sortList(tasks);
  }
}

final taskActionProvider = StateProvider((ref) => TaskAction.none);
final taskSelectProvider = StateProvider((ref) => -1);
final naviSelectProvider = StateProvider((ref) => Navi.inbox);

final taskListkProvider =
    StateNotifierProvider<TaskListState, List<Task>>((ref) {
  return TaskListState(ref);
});

class ProviderAction {
  static openFormular(WidgetRef ref, TaskAction act) {
    if (act != TaskAction.none) {
      ref.read(taskActionProvider.notifier).state = act;
    }
  }

  static int readSelectedID(WidgetRef ref) {
    return ref.read(taskSelectProvider);
  }

  static int watchSelectedID(WidgetRef ref) {
    return ref.watch(taskSelectProvider);
  }

  static TaskAction watchAction(WidgetRef ref) {
    return ref.watch(taskActionProvider);
  }

  static TaskAction readAction(WidgetRef ref) {
    return ref.read(taskActionProvider);
  }

  static int watchSeletedID(WidgetRef ref) {
    return ref.watch(taskSelectProvider);
  }

  static Navi readSelectedNavi(WidgetRef ref) {
    return ref.read(naviSelectProvider);
  }

  static Navi watchSelectedNavi(WidgetRef ref) {
    return ref.watch(naviSelectProvider);
  }

  static Task? readSelectedTask(WidgetRef ref) {
    return Hive.box<Task>(Constants.boxNameTasks)
        .get(ProviderAction.readSelectedID(ref));
  }

  static closeFormular(WidgetRef ref) {
    ref.read(taskSelectProvider.notifier).state = -1;
    ref.read(taskActionProvider.notifier).state = TaskAction.none;
  }

  static unSelectTask(WidgetRef ref) {
    if (ref.read(taskActionProvider.notifier).state == TaskAction.none) {
      ref.read(taskSelectProvider.notifier).state = -1;
    }
  }

  static selectTask(WidgetRef ref, int key) {
    ref.read(taskSelectProvider.notifier).state = key;
  }
}
