import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // AsyncValue<List<Task>> tasks = ref.watch(taskskProvider(""));
    ref.read(taskskProvider.notifier).getList();
    List<Task> tasks = ref.watch(taskskProvider);
    TaskAction action = ref.watch(taskActionProvider);
    var selectId = ref.watch(taskSelectProvider);

    double height(candidateData) {
      if (candidateData.isNotEmpty) {
        return 40.0;
      }
      return 1;
    }

    // final taskfolders = taskmodel.taskfolders;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /*
          tasks.when(
              data: (list) {
                return Text(list.length.toString());
              },
              error: (err, stack) => Text('Error: $err'),
              loading: () => const CircularProgressIndicator())

         */

        ListView.builder(
            itemCount: tasks.length,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int idxTask) {
              return Column(
                children: [
                  DragTarget(
                    onMove: (details) {
                      debugPrint("move");
                    },
                    onAcceptWithDetails: (details) {},
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        color: (candidateData.isNotEmpty) ? Colors.grey : null,
                        height: height(candidateData),
                      );
                    },
                    onAccept: (data) {},
                  ),
                  Draggable(
                    maxSimultaneousDrags: (action == TaskAction.none &&
                            selectId == tasks[idxTask].id)
                        ? 1
                        : 0,
                    data: idxTask,
                    feedback: Text(tasks[idxTask].title),
                    child: Row(children: [
                      Checkbox(
                          value: false,
                          onChanged: (action == TaskAction.none)
                              ? (bool? value) {}
                              : null),
                      Expanded(
                        child: GestureDetector(
                            onTap: (action == TaskAction.none)
                                ? () {
                                    if (action == TaskAction.none) {
                                      if (selectId == tasks[idxTask].id) {
                                        /*
                                            taskmodel.openFormular(
                                                TaskActionStatus.save);
                                                */
                                      } else {
                                        ref
                                            .read(taskSelectProvider.notifier)
                                            .state = tasks[idxTask].id!;
                                        /*
                                            taskcontroller.setSelectedID(
                                                taskID: tasks[taskIdx].id,
                                                folderIdx: folderIdx);
                                                */
                                      }
                                    }
                                  }
                                : null,
                            child: Container(
                                color: (selectId == tasks[idxTask].id)
                                    ? Theme.of(context).focusColor
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(tasks[idxTask].title),
                                ))),
                      ),
                    ]),
                  ),
                ],
              );
            })
      ],
    );
  }
}
