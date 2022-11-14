import 'package:flutter/material.dart';
import 'package:flutter_todo/models/task_model.dart';
import 'package:flutter_todo/utils/dialogs.dart';
import 'package:provider/provider.dart';
import '../widgets/task/display_tasks.dart';

class TaskPage extends StatelessWidget {
  TaskPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var taskmodel = context.watch<TaskModel>();
    var taskcontroller = context.watch<TaskController>();

    taskcontroller.addListener(() => print("listen controller"));
    taskmodel.addListener(() => print("listen taskmodel"));

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: const Text('Notes'), actions: <Widget>[
          Visibility(
            visible: taskcontroller.selectedTaskId != "",
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: const Icon(Icons.delete),
                tooltip: "Aufgabe Löschen",
                onPressed: () {
                  CustomDialog.showConfirmDialog(
                      context: context,
                      text: "Wirklich löschen?",
                      onPressedOk: () {
                        taskmodel
                            .removeTask()
                            .then((value) => Navigator.pop(context));
                      });
                },
              ),
            ),
          ),
          Visibility(
            visible: taskcontroller.action == TaskActionStatus.none,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: const Icon(Icons.add),
                tooltip: "Neue Aufgabe",
                onPressed: () {
                  taskmodel.openFormular(TaskActionStatus.add);
                },
              ),
            ),
          ),
        ]),
        /*
        body: GetX<TaskController>(builder: (controller) {
          //final tasks = controller.todayTasksList;
          return SafeArea(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            color: (_taskController.isFormOpen.value) ? null : null,
            // (_taskController.isFormOpen.value)
            //     ? Theme.of(context).disabledColor
            //    : null,
            //color: Theme.of(context).backgroundColor =
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [DisplayTasks()])),
          ));
        })
        */

        body: SafeArea(
          child: Container(
              color: (taskcontroller.isFormOpen)
                  ? Theme.of(context).disabledColor
                  : null,
              width: double.infinity,
              height: double.infinity,

              // (_taskController.isFormOpen.value)
              //     ? Theme.of(context).disabledColor
              //    : null,
              //color: Theme.of(context).backgroundColor =
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  DispayTasks(),
                ],
              ))
              /*
          child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Tasks()])),
        */
              ),
        ));
  }
}
