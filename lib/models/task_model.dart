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

class TaskRepository {
  void addTask() {
    var fido = Task(
      title: 'Fido',
    );

/*
    Future<Weather> fetchWeather(String cityName) async {
      // Get weather
    }
*/
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
