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
    _listEntryLoaded = false;
    _listTodyLoaded = false;
    _lisToday = [];
    _cacheLists(ref.read(naviSelectProvider));
  }

  late List<Task> _listentry;
  late bool _listEntryLoaded;
  late List<Task> _lisToday;
  late bool _listTodyLoaded;
  //List<Task> _listToday;

  final Ref ref;
  _cacheLists(navi) {
    if (navi == Navi.inbox) {
      if (!_listEntryLoaded) {
        var box = Hive.box<Task>(Constants.boxNameTasks);
        _listentry = box.values
            .where((element) => element.itemLocation == ItemLocation.inbox)
            .toList();

        _listEntryLoaded = true;
      }
      state = _listentry.toList();
    } else {
      if (!_listTodyLoaded) {
        var box = Hive.box<Task>(Constants.boxNameTasks);
        _lisToday = box.values
            .where((element) => element.itemLocation == ItemLocation.today)
            .toList();

        _listTodyLoaded = true;
      }
      state = _lisToday.toList();
    }
    _sortState();
    debugPrint("_cacheLists()");
  }

  _saveCacheList() {
    final selectedNavi = getSelectedNavi();
    switch (selectedNavi) {
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

  _sortState([List<Task>? ptasks]) {
    List<Task> tasks;
    if (ptasks != null) {
      tasks = ptasks;
    } else {
      tasks = state;
    }

    if (tasks.isNotEmpty) {
      _sortList(tasks);

      state = tasks;
      return;
    }

    state = [];
  }

  loadState([Navi? navi]) {
    Navi lNavi;
    if (navi != null) {
      lNavi = navi;
    } else {
      lNavi = ref.read(naviSelectProvider);
    }

    _cacheLists(lNavi);
  }

  Future<int> addTask(title, description) async {
    final selectedId = getSelectedID();
    final tasks = state.toList();
    final selectedNavi = getSelectedNavi();
    //late ItemLocation location;

    final task = Task(title: title, description: description);

    switch (selectedNavi) {
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
    _sortState(tasks);

    _saveCacheList();

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

    if (selectedID == -1) {
      return;
    }
    final list = state.toList();

    int idx = _getTaskIndex(list, selectedID);
    var newid = -1;

    if (idx != -1 && idx != list.length - 1) {
      newid = list[idx + 1].key!;
    }

    var box = Hive.box<Task>(Constants.boxNameTasks);
    await box.delete(selectedID);

    list.removeAt(idx);
    state = list.toList();

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

    _setSortInTaskItems(tasks);
    _sortState(tasks);

    state = tasks.toList();
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

  static TaskAction watchAction(WidgetRef ref) {
    return ref.watch(taskActionProvider);
  }

  static TaskAction readAction(WidgetRef ref) {
    return ref.read(taskActionProvider);
  }

  static int watchSeletedID(WidgetRef ref) {
    return ref.watch(taskSelectProvider);
  }

  static closeFormular(WidgetRef ref) {
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
