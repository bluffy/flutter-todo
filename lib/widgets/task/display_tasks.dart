import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todo/db/db_helper.dart';
import '../../models/task_model.dart';

/*
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  List<Map<String, dynamic>> tasks = await DBHelper.taskList();

  return tasks.map((data) => Task.fromJson(data)).toList();
});
*/

class DispayTasks extends ConsumerWidget {
  const DispayTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //var taskmodel = context.watch<TaskModel>();
    //var taskcontroller = context.watch<TaskController>();
    //TasksNotifier().getList();

    AsyncValue<List<Task>> tasks = ref.watch(taskskProvider(""));

    double height(candidateData) {
      if (candidateData.isNotEmpty) {
        return 20.0;
      }
      return 10;
    }

    // final taskfolders = taskmodel.taskfolders;
    return Container(
      //  color: Colors.amber,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tasks.when(
              data: (list) {
                return Text(list.length.toString());
              },
              error: (err, stack) => Text('Error: $err'),
              loading: () => const CircularProgressIndicator())

          /*

          ListView.builder(
              itemCount: tasks.length,
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int idxTask) {
                return Column(
                  children: [
                    DragTarget(
                      onMove: (details) {
                        print("move");
                        print(details);
                      },
                      onAcceptWithDetails: (details) {
                        print(details);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          color:
                              (candidateData.isNotEmpty) ? Colors.grey : null,
                          height: height(candidateData),
                        );
                      },
                      onAccept: (data) {
                        print(data);
                      },
                    ),
                    Draggable(
                      data: idxTask,
                      feedback: Text(tasks[idxTask].title),
                      child: Container(
                        color: Colors.black12,
                        child: Text(tasks[idxTask].title),
                      ),
                    ),
                  ],
                );
              })
              */
        ],
      ),
    );
  }
}
