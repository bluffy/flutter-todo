import 'package:flutter/material.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import './task_formular.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo/models/task_model.dart';

class DispayTasks extends StatelessWidget {
  const DispayTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var taskmodel = context.watch<TaskModel>();
    var taskcontroller = context.watch<TaskController>();

    final taskfolders = taskmodel.taskfolders;
    final contents = List.generate(taskfolders.length, (folderIdx) {
      final tasks = taskfolders[folderIdx].tasks;
      final children = List.generate(tasks.length, (taskIdx) {
        return DragAndDropItem(
            canDrag: taskcontroller.action == TaskActionStatus.none,
            child: Column(
              children: [
                Visibility(
                    visible:
                        taskcontroller.selectedTaskId == tasks[taskIdx].id &&
                            taskcontroller.action == TaskActionStatus.save,
                    child: TaskFormular()),
                Visibility(
                  visible:
                      !(taskcontroller.selectedTaskId == tasks[taskIdx].id &&
                          taskcontroller.action == TaskActionStatus.save),
                  child: Row(children: [
                    Checkbox(value: false, onChanged: (bool? value) {}),
                    Expanded(
                        child: InkWell(
                            onTap: () {
                              if (!taskcontroller.isFormOpen) {
                                if (taskcontroller.selectedTaskId ==
                                    tasks[taskIdx].id) {
                                  taskmodel.openFormular(TaskActionStatus.save);
                                }
                                taskcontroller.setSelectedID(
                                    taskID: tasks[taskIdx].id,
                                    folderIdx: folderIdx);
                              }
                            },
                            child: Ink(
                                color: (taskcontroller.selectedTaskId ==
                                        tasks[taskIdx].id)
                                    ? Theme.of(context).focusColor
                                    : null,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(tasks[taskIdx].title)))))
                  ]),
                ),
                Visibility(
                    visible:
                        taskcontroller.selectedTaskId == tasks[taskIdx].id &&
                            taskcontroller.action == TaskActionStatus.add,
                    child: TaskFormular())
              ],
            ));
      });

      return DragAndDropList(children: children, canDrag: false);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Visibility(
              visible: taskcontroller.isFormOpen &&
                  taskcontroller.action == TaskActionStatus.add &&
                  taskcontroller.selectedTaskId == "",
              child: TaskFormular()),
          DragAndDropLists(
            disableScrolling: true,
            itemDragOnLongPress: true,

            /*
              itemDragHandle: const DragHandle(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.menu,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              */
            children: contents,
            onItemReorder:
                (oldItemIndex, oldListIndex, newItemIndex, newListIndex) {
              taskmodel.doSorting(
                  oldItemIndex, oldListIndex, newItemIndex, newListIndex);
            },
            onListReorder: (oldListIndex, newListIndex) {},
          ),
        ],
      ),
    );
  }
}
