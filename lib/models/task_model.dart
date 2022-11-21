import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/db_helper.dart';

class Task {
  String? id;
  String title;
  String? syncID;
  String? description;
  int? sort;
  int? isDone;
  String? date;
  String? time;
  int? dateTime;
  int? status;

  Task(
      {this.id,
      required this.title,
      this.sort,
      this.syncID,
      this.description,
      this.isDone,
      this.date,
      this.time,
      this.dateTime,
      this.status});

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
        id: json['id'],
        sort: json['sort'],
        syncID: json['sync_id'],
        title: json['title'],
        description: json['description'],
        isDone: json['isDone'],
        date: json['date'],
        time: json['time'],
        dateTime: json['date_time'],
        status: json['status']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'sort': sort,
      'description': description,
      'is_done': isDone,
      'date': date,
      'time': time,
      'date_time': dateTime,
      'status': status,
      'sync_id': syncID,
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

  Future<String> addTask(title, description) {
    final task = Task(title: title, description: description);

    var id = DBHelper.insertTask(task);
    getList();
    ref.read(taskActionProvider.notifier).state = TaskAction.none;

    return id;
  }

  getSelectedID() {
    return ref.read(taskSelectProvider.notifier).state;
  }

  updateTask(title, description) async {
    final task = await getSelectedTask();
    task!.title = title;
    task.description = description;
    await DBHelper.updateTask(task);
    closeFormular();
    getList();
  }

  Future<Task?> getSelectedTask() async {
    final data = await DBHelper.getTaskByID(getSelectedID());
    return Task.fromJson(data);
  }

  getList() async {
    List<Map<String, dynamic>> tasks = await DBHelper.taskList();

    state = tasks.map((data) => Task.fromJson(data)).toList();
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