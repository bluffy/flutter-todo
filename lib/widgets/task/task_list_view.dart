import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import './task_formular.dart';
import '../../providers/task_provider.dart';
//import '../../utils/date.dart';

/*
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  List<Map<String, dynamic>> tasks = await DBHelper.taskList();

  return tasks.map((data) => Task.fromJson(data)).toList();
});
*/

class TaskListView extends ConsumerWidget {
  const TaskListView({Key? key}) : super(key: key);

  Widget listItem(
      BuildContext context,
      WidgetRef ref,
      bool feedback,
      List<Task> tasks,
      int idxTask,
      int selectId,
      TaskAction action,
      TaskListState taskListState) {
    return Row(children: [
      Checkbox(
          value: false,
          onChanged: (action == TaskAction.none) ? (bool? value) {} : null),
      Expanded(
        child: GestureDetector(
            onTap: (!feedback && action == TaskAction.none)
                ? () {
                    if (action == TaskAction.none) {
                      if (selectId == tasks[idxTask].key) {
                        taskListState.openFormular(TaskAction.save);
                      } else {
                        taskListState.selectTask(tasks[idxTask].key!);
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
                    child: Text(tasks[idxTask].title)))),
      ),
    ]);
  }

  Widget dragTarget(
      BuildContext context,
      WidgetRef ref,
      bool last,
      List<Task> tasks,
      int idxTask,
      int selectId,
      TaskListState taskListState) {
    double height(candidateData) {
      if (candidateData.isNotEmpty) {
        return 30.0;
      }
      return 10;
    }

    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: (candidateData.isNotEmpty) ? Colors.grey[200] : null,
          height: height(candidateData),
        );
      },
      onAccept: (int data) {
        if (last) {
          taskListState.doListSorting(sourceID: data, last: true);
        } else {
          taskListState.doListSorting(
              targetID: tasks[idxTask].key, sourceID: data);
        }
        // taskListState.doListSorting( targetID, targetSort, sourceID)
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("build DispayTasks");

    final taskListState = ref.watch(taskListkProvider.notifier);

    List<Task> tasks = ref.watch(taskListkProvider);
    TaskAction action = ref.watch(taskActionProvider);
    final selectId = ref.watch(taskSelectProvider);

    // final taskfolders = taskmodel.taskfolders;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  dragTarget(context, ref, false, tasks, idxTask, selectId,
                      taskListState),
                  Visibility(
                    visible: (action == TaskAction.save &&
                            selectId != tasks[idxTask].key) ||
                        action != TaskAction.save,
                    child: LayoutBuilder(
                      builder: (context, constraints) => Draggable(
                        maxSimultaneousDrags: (action == TaskAction.none &&
                                selectId == tasks[idxTask].key)
                            ? 1
                            : 0,
                        data: tasks[idxTask].key,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Opacity(
                            opacity: 0.9,
                            child: Container(
                              color: Colors.transparent,
                              width: constraints.maxWidth,
                              height: 40.0,
                              child: listItem(context, ref, true, tasks,
                                  idxTask, selectId, action, taskListState),
                            ),
                          ),
                        ),
                        child: listItem(context, ref, false, tasks, idxTask,
                            selectId, action, taskListState),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: tasks.last.key == tasks[idxTask].key,
                    child: dragTarget(context, ref, true, tasks, idxTask,
                        selectId, taskListState),
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
