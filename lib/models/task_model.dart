import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/db_helper.dart';

class Task {
  String? id;
  String? dateCreated;
  String? dateUpdated;
  int? status;
  String title;
  String? description;
  String? date;

  int? sort;

  Task(
      {this.id,
      required this.title,
      this.sort,
      this.date,
      this.status,
      this.description,
      this.dateCreated,
      this.dateUpdated});

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
        id: json['id'],
        sort: json['sort'],
        title: json['title'],
        description: json['description'],
        date: json['date'],
        dateCreated: json['date_created'],
        dateUpdated: json['date_updated'],
        status: json['status']);
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'date': date,
      'id': id,
      'status': status,
      'sort': sort,
      'date_created': dateCreated,
      'date_updated': dateUpdated,
      'title': title,
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title}';
  }
}

enum TaskAction {
  none,
  add,
  save,
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier(this.ref) : super([]);
  final Ref ref;

  Future<String> addTask(title, description) async {
    final selectedTask = await getSelectedTask();

    final task = Task(title: title, description: description);

    var id = await DBHelper.insertTask(task,
        sort: (selectedTask != null) ? selectedTask.sort : null);
    ref.read(taskActionProvider.notifier).state = TaskAction.none;

    getList();

    ref.read(taskSelectProvider.notifier).state = id;
    return id;
  }

  getSelectedID() {
    return ref.read(taskSelectProvider.notifier).state;
  }

  Future<void> updateTask(title, description) async {
    final task = await getSelectedTask();
    task!.title = title;
    task.description = description;

    await DBHelper.updateTask(task);
    getList();
  }

  Future<void> removeTask() async {
    final selectedID = getSelectedID();
    final list = state;

    if (selectedID == "") {
      return;
    }

    int idx = list.indexWhere((Task task) => task.id == selectedID);

    var newid = "";

    if (idx != -1 && idx != list.length - 1) {
      newid = list[idx + 1].id!;
    }

    await DBHelper.removeTask(selectedID);

    ref.read(taskSelectProvider.notifier).state = newid;
    closeFormular();

    getList();
  }

  Future<Task?> getSelectedTask() async {
    if (getSelectedID() != "") {
      final data = await DBHelper.getTaskByID(getSelectedID());
      return Task.fromJson(data);
    }
    return null;
  }

  getList() async {
    List<Map<String, dynamic>> tasks = await DBHelper.taskList();

    state = tasks.map((data) => Task.fromJson(data)).toList();
  }

  doListSorting(
      {String? targetID, required String sourceID, bool? last}) async {
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
  }

  selectTask(String taskID) {
    ref.read(taskSelectProvider.notifier).state = taskID;
  }

  unSelectTask() {
    if (ref.read(taskActionProvider.notifier).state == TaskAction.none) {
      ref.read(taskSelectProvider.notifier).state = "";
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
final taskSelectProvider = StateProvider((ref) => "");

final taskskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref);
});



/*
class TaskRepository {
  void addTask() {
    var fido = Task(
      title: 'Fido',
    );
    DBHelper.insertTask(fido);
    getList();
  }

  Future<List<Task>> getList() async {
    List<Map<String, dynamic>> tasks = await DBHelper.taskList();
    var list = tasks.map((data) => Task.fromJson(data)).toList();
    return list;
  }

  static final provider = Provider<TaskRepository>((_) => TaskRepository());
}

final taskskProvider = FutureProvider.family((ref, arg) {
  final repo = ref.watch(TaskRepository.provider);
  return repo.getList();
});
*/

/*
class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super([]);

  void addTask() {
    var fido = Task(
      title: 'Fido',
    );

    DBHelper.insertTask(fido);
    getList();
  }

  void getList() async {
    List<Map<String, dynamic>> tasks = await DBHelper.taskList();
    state = tasks.map((data) => Task.fromJson(data)).toList();
  }
}

final taskskProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});
*/


  // Let's allow the UI to add todos.
  /*
  void addTodo(Todo todo) {
    todos.add(todo);
    notifyListeners();
  }

  // Let's allow removing todos
  void removeTodo(String todoId) {
    todos.remove(todos.firstWhere((element) => element.id == todoId));
    notifyListeners();
  }

  // Let's mark a todo as completed
  void toggle(String todoId) {
    for (final todo in todos) {
      if (todo.id == todoId) {
        todo.completed = !todo.completed;
        notifyListeners();
      }
    }
  }

  /*
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sort'] = sort;
    data['sync_id'] = syncID;
    data['title'] = title;
    data['description'] = description;
    data['is_done'] = isDone;
    data['date'] = date;
    data['time'] = time;
    data['date_time'] = dateTime;
    data['status'] = status;
    return data;
  }
  */
  */