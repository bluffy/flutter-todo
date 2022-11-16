import 'package:flutter/material.dart';
import 'package:flutter_todo/models/task_model.dart';
import 'package:flutter_todo/utils/dialogs.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../widgets/task/display_tasks.dart';

class TaskPage extends StatelessWidget {
  TaskPage({Key? key}) : super(key: key);

  final breakpoint = 600.0;
  final menuWidth = 240.0;

  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //taskcontroller.addListener(() => print("listen controller"));
    //taskmodel.addListener(() => print("listen taskmodel"));
    if (screenWidth >= breakpoint) {
      return Row(
        children: [
          SizedBox(
            width: 300,
            child: MenuView(),
          ),
          Container(width: 0.5, color: Colors.black),
          Expanded(child: TasksView()),
        ],
      );
    } else {
      // narrow screen: show content, menu inside drawer
      return Scaffold(
        body: TasksView(),
        drawer: SizedBox(
          width: menuWidth,
          child: Drawer(
            child: MenuView(),
          ),
        ),
      );
    }
  }
}

class TasksView extends StatelessWidget {
  TasksView({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var taskmodel = context.watch<TaskModel>();
    var taskcontroller = context.watch<TaskController>();

    unSelectTask() {
      if (taskcontroller.action == TaskActionStatus.none) {
        taskcontroller.setSelectedID(taskID: "", folderIdx: 0);
      } else {
        //FlutterRingtonePlayer.playAlarm(asAlarm: false);
      }
    }

    //taskcontroller.addListener(() => print("listen controller"));
    //taskmodel.addListener(() => print("listen taskmodel"));

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            flexibleSpace: GestureDetector(
              onTap: () {
                //unSelectTask();
                unSelectTask();
              },
              child: const SizedBox(height: double.infinity, child: Text("")),
            ),
            title: GestureDetector(
              child: const Text('Notes'),
              onTap: () {
                unSelectTask();
              },
            ),
            actions: <Widget>[
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
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              unSelectTask();
            },
            child: Container(
                color: (taskcontroller.action != TaskActionStatus.none)
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
                  children: const [
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
          ),
        ));
  }
}

class MenuView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Menu')));
  }
}

class SplitView extends StatelessWidget {
  const SplitView({
    Key? key,
    required this.menu,
    required this.content,
    this.breakpoint = 600,
    this.menuWidth = 240,
  }) : super(key: key);
  final Widget menu;
  final Widget content;
  final double breakpoint;
  final double menuWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= breakpoint) {
      // wide screen: menu on the left, content on the right
      return Row(
        children: [
          SizedBox(
            width: menuWidth,
            child: menu,
          ),
          Container(width: 0.5, color: Colors.black),
          Expanded(child: content),
        ],
      );
    } else {
      // narrow screen: show content, menu inside drawer
      return Scaffold(
        body: content,
        drawer: SizedBox(
          width: menuWidth,
          child: Drawer(
            child: menu,
          ),
        ),
      );
    }
  }
}
