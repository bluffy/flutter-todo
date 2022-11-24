import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import './task_formular.dart';
import '../../providers/task_provider.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({Key? key}) : super(key: key);

  Widget listItem(BuildContext context, WidgetRef ref, bool feedback,
      List<Task> tasks, int idxTask) {
    return Row(children: [
      Checkbox(
          value: false,
          onChanged: (ProviderAction.watchAction(ref) == TaskAction.none)
              ? (bool? value) {}
              : null),
      Expanded(
        child: GestureDetector(
            onTap: (!feedback &&
                    ProviderAction.watchAction(ref) == TaskAction.none)
                ? () {
                    if (ProviderAction.watchAction(ref) == TaskAction.none) {
                      if (ProviderAction.watchSeletedID(ref) ==
                          tasks[idxTask].key) {
                        ProviderAction.openFormular(ref, TaskAction.save);
                      } else {
                        ProviderAction.selectTask(ref, tasks[idxTask].key!);
                      }
                    }
                  }
                : null,
            child: Container(
                color:
                    (ProviderAction.watchSeletedID(ref) == tasks[idxTask].key)
                        ? Theme.of(context).focusColor
                        : null,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(tasks[idxTask].title)))),
      ),
    ]);
  }

  Widget dragTarget(BuildContext context, WidgetRef ref, bool last,
      List<Task> tasks, int idxTask) {
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
          ref
              .read(taskListkProvider.notifier)
              .doListSorting(sourceID: data, last: true);
        } else {
          ref
              .read(taskListkProvider.notifier)
              .doListSorting(targetID: tasks[idxTask].key, sourceID: data);
        }
        // taskListState.doListSorting( targetID, targetSort, sourceID)
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("build DispayTasks");

    List<Task> tasks = ref.watch(taskListkProvider);

    // final taskfolders = taskmodel.taskfolders;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
            visible: ProviderAction.watchAction(ref) == TaskAction.add &&
                ProviderAction.watchSeletedID(ref) == -1,
            child: TaskFormular()),
        ListView.builder(
            itemCount: tasks.length,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int idxTask) {
              return Column(
                children: [
                  Visibility(
                      visible: ProviderAction.watchSeletedID(ref) ==
                              tasks[idxTask].key &&
                          ProviderAction.watchAction(ref) == TaskAction.save,
                      child: TaskFormular()),
                  dragTarget(context, ref, false, tasks, idxTask),
                  Visibility(
                    visible:
                        (ProviderAction.watchAction(ref) == TaskAction.save &&
                                ProviderAction.watchSeletedID(ref) !=
                                    tasks[idxTask].key) ||
                            ProviderAction.watchAction(ref) != TaskAction.save,
                    child: LayoutBuilder(
                      builder: (context, constraints) => Draggable(
                        maxSimultaneousDrags:
                            (ProviderAction.watchAction(ref) ==
                                        TaskAction.none &&
                                    ProviderAction.watchSeletedID(ref) ==
                                        tasks[idxTask].key)
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
                              child:
                                  listItem(context, ref, true, tasks, idxTask),
                            ),
                          ),
                        ),
                        child: listItem(
                          context,
                          ref,
                          false,
                          tasks,
                          idxTask,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: tasks.last.key == tasks[idxTask].key,
                    child: dragTarget(
                      context,
                      ref,
                      true,
                      tasks,
                      idxTask,
                    ),
                  ),
                  Visibility(
                      visible: ProviderAction.watchSeletedID(ref) ==
                              tasks[idxTask].key &&
                          ProviderAction.watchAction(ref) == TaskAction.add,
                      child: TaskFormular())
                ],
              );
            })
      ],
    );
  }
}
