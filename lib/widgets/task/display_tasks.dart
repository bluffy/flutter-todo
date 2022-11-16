import 'package:flutter/material.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import './task_formular.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo/models/task_model.dart';

class DispayTasks extends StatelessWidget {
  const DispayTasks({Key? key}) : super(key: key);
  final breakpoint = 600.0;
  final menuWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var taskmodel = context.watch<TaskModel>();
    var taskcontroller = context.watch<TaskController>();

    double height(candidateData) {
      if (candidateData.isNotEmpty) {
        return 20.0;
      }
      return 10;
    }

    final taskfolders = taskmodel.taskfolders;
    return Container(
      //  color: Colors.amber,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: taskfolders.length,
              itemBuilder: (BuildContext context, int idxFolder) {
                return Column(
                  children: [
                    Text("Header1"),
                    ListView.builder(
                        itemCount: taskfolders[idxFolder].tasks.length,
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
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Container(
                                    color: (candidateData.isNotEmpty)
                                        ? Colors.grey
                                        : null,
                                    height: height(candidateData),
                                  );
                                },
                                onAccept: (data) {
                                  print(data);
                                },
                              ),
                              Draggable(
                                data: idxTask,
                                feedback: Text(taskfolders[idxFolder]
                                    .tasks[idxTask]
                                    .title),
                                child: Container(
                                  color: Colors.black12,
                                  child: Text(taskfolders[idxFolder]
                                      .tasks[idxTask]
                                      .title),
                                ),
                              ),
                            ],
                          );
                        })
                  ],
                );
                /*

                            ListView.builder(
                        itemCount: taskfolders[idxFolder].tasks.length,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int idxTask) {
                          return Text(
                              taskfolders[idxFolder].tasks[idxTask].title);
                        })


                return ListView.builder(
                    itemCount: taskfolders.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text('Child');
                    });
                    */
              }),
        ],
      ),
    );
    /*
    final contents = List.generate(taskfolders.length, (folderIdx) {



      final tasks = taskfolders[folderIdx].tasks;
      final children = List.generate(tasks.length, (taskIdx) {
        return DragAndDropItem(
            canDrag: taskcontroller.selectedTaskId == tasks[taskIdx].id &&
                taskcontroller.action == TaskActionStatus.none,
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
                    Checkbox(
                        value: false,
                        onChanged:
                            (taskcontroller.action == TaskActionStatus.none)
                                ? (bool? value) {}
                                : null),
                    Expanded(
                        child: GestureDetector(
                            onTap:
                                (taskcontroller.action == TaskActionStatus.none)
                                    ? () {
                                        if (taskcontroller.action ==
                                            TaskActionStatus.none) {
                                          if (taskcontroller.selectedTaskId ==
                                              tasks[taskIdx].id) {
                                            taskmodel.openFormular(
                                                TaskActionStatus.save);
                                          } else {
                                            taskcontroller.setSelectedID(
                                                taskID: tasks[taskIdx].id,
                                                folderIdx: folderIdx);
                                          }
                                        }
                                      }
                                    : null,
                            child: Container(
                                color: (taskcontroller.selectedTaskId ==
                                        tasks[taskIdx].id)
                                    ? Theme.of(context).focusColor
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(tasks[taskIdx].title),
                                ))
                            /*        
                            child: InkWell(
                              child: Ink(
                                  color: (taskcontroller.selectedTaskId ==
                                          tasks[taskIdx].id)
                                      ? Theme.of(context).focusColor
                                      : null,
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(tasks[taskIdx].title))),
                            )*/
                            ))

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
              visible: taskcontroller.action == TaskActionStatus.add &&
                  taskcontroller.selectedTaskId == "",
              child: TaskFormular()),
          GestureDetector(
            onTap: (() {}),
            child: DragAndDropLists(
              disableScrolling: true,
              itemDragOnLongPress: false,
              listDragOnLongPress: false,
              itemDragHandle: (screenWidth < breakpoint)
                  ? const DragHandle(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.menu,
                          color: Colors.blueGrey,
                        ),
                      ),
                    )
                  : null,
              children: contents,
              onItemReorder:
                  (oldItemIndex, oldListIndex, newItemIndex, newListIndex) {
                taskmodel.doSorting(
                    oldItemIndex, oldListIndex, newItemIndex, newListIndex);
              },
              onListReorder: (oldListIndex, newListIndex) {},
            ),
          ),
        ],
      ),
    );
      */
  }
}
