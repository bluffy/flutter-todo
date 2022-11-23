import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import './task_formular.dart';
//import '../../utils/date.dart';

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
    debugPrint("build DispayTasks");
    //    final tasks = taskskProvider.notifier;
    //var taskmodel = context.watch<TaskModel>();
    //var taskcontroller = context.watch<TaskController>();
    //TasksNotifier().getList();

    // AsyncValue<List<Task>> tasks = ref.watch(taskskProvider(""));
    final taskNotifier = ref.watch(taskskProvider.notifier);

    List<Task> tasks = ref.watch(taskskProvider);
    TaskAction action = ref.watch(taskActionProvider);
    var selectId = ref.watch(taskSelectProvider);

    double height(candidateData) {
      if (candidateData.isNotEmpty) {
        return 40.0;
      }
      return 20;
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
        Visibility(
            visible: action == TaskAction.add && selectId == -1,
            child: TaskFormular()),
        ListView.builder(
            itemCount: tasks.length,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int idxTask) {
              return Column(
                children: [
                  Visibility(
                      visible: selectId == tasks[idxTask].key &&
                          action == TaskAction.save,
                      child: TaskFormular()),
                  DragTarget(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        color: (candidateData.isNotEmpty) ? Colors.grey : null,
                        height: height(candidateData),
                      );
                    },
                    onAccept: (String data) {
                      taskNotifier.doListSorting(
                          targetID: tasks[idxTask].key, sourceID: data);
                      // taskNotifier.doListSorting( targetID, targetSort, sourceID)
                    },
                  ),
                  Visibility(
                    visible: (action == TaskAction.save &&
                            selectId != tasks[idxTask].key) ||
                        action != TaskAction.save,
                    child: Draggable(
                      maxSimultaneousDrags: (action == TaskAction.none &&
                              selectId == tasks[idxTask].key)
                          ? 1
                          : 0,
                      data: tasks[idxTask].key,
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
                                        if (selectId == tasks[idxTask].key) {
                                          taskNotifier
                                              .openFormular(TaskAction.save);
                                        } else {
                                          /*
                                          ref
                                              .read(taskSelectProvider.notifier)
                                              .state = tasks[idxTask].id!;*/
                                          taskNotifier
                                              .selectTask(tasks[idxTask].key!);
                                        }
                                      }
                                    }
                                  : null,
                              child: Container(
                                  color: (selectId == tasks[idxTask].key)
                                      ? Theme.of(context).focusColor
                                      : null,
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(tasks[idxTask].title +
                                          ' ' +
                                          tasks[idxTask].key.toString())))),
                        ),
                        Visibility(
                          visible: idxTask >= tasks.length - 1,
                          child: DragTarget(
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                color: (candidateData.isNotEmpty)
                                    ? Colors.grey
                                    : null,
                                height: height(candidateData),
                              );
                            },
                            onAccept: (String data) {
                              taskNotifier.doListSorting(
                                  sourceID: data, last: true);
                              // taskNotifier.doListSorting( targetID, targetSort, sourceID)
                            },
                          ),
                        ),
                      ]),
                    ),
                  ),
                  Visibility(
                      visible: selectId == tasks[idxTask].key &&
                          action == TaskAction.add,
                      child: TaskFormular())
                ],
              );
            })
      ],
    );
  }
}
