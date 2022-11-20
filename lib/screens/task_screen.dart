import 'package:flutter/material.dart';
import 'package:flutter_todo/db/db_helper.dart';
import 'package:flutter_todo/models/task_model.dart';
import '../utils/dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/task/display_tasks.dart';
import '../models/task_model.dart';

enum TaskAction {
  none,
  add,
  save,
}

final taskActionProvider = StateProvider((ref) => TaskAction.none);

class TaskPage extends StatelessWidget {
  static const breakpoint = 600.0;
  static const menuWidth = 240.0;

  const TaskPage({super.key});

  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //taskcontroller.addListener(() => print("listen controller"));
    //taskmodel.addListener(() => print("listen taskmodel"));
    if (screenWidth >= breakpoint) {
      return Row(
        children: [
          const SizedBox(
            width: menuWidth,
            child: TaskMenuView(),
          ),
          Container(width: 0.5, color: Colors.black),
          Expanded(child: TasksView()),
        ],
      );
    } else {
      // narrow screen: show content, menu inside drawer
      return Scaffold(
        body: TasksView(),
        drawer: const SizedBox(
          width: menuWidth,
          child: Drawer(
            child: TaskMenuView(),
          ),
        ),
      );
    }
  }
}

class TasksView extends ConsumerWidget {
  TasksView({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(taskActionProvider);

    final repo = ref.watch(TaskRepository.provider);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            flexibleSpace: GestureDetector(
              onTap: () {},
              child: const SizedBox(height: double.infinity, child: Text("")),
            ),
            title: GestureDetector(
              child: const Text('Notes'),
              onTap: () {},
            ),
            actions: <Widget>[
              Visibility(
                visible: (action != TaskAction.none),
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
                            DBHelper.nextID();
                            Navigator.of(context).pop();
                          });
                    },
                  ),
                ),
              ),
              Visibility(
                visible: (action == TaskAction.none),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: "Neue Aufgabe",
                    onPressed: () {
                      repo.addTask();
                      //  TasksNotifier().addTask();
                      /*
                      var fido = Task(
                        title: 'Fido',
                      );
                      //unSelectTask();

                      DBHelper.insertTask(fido);
                      */
                    },
                  ),
                ),
              ),
            ]),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              // taskcontroller.unSelectTask();
            },
            child: Container(
                color: (0 != 0) ? Theme.of(context).disabledColor : null,
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

class TaskMenuView extends StatelessWidget {
  const TaskMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: GestureDetector(
              onTap: () {
                //unSelectTask();
                // taskcontroller.unSelectTask();
              },
              child: const SizedBox(height: double.infinity, child: Text("")),
            ),
            title: GestureDetector(
              child: const Text('Notes'),
              onTap: () {
                // taskcontroller.unSelectTask();
              },
            )),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              print("unselect");
              //taskcontroller.unSelectTask();
            },
            child: Container(
              color: (0 != 0) ? Theme.of(context).disabledColor : null,
              width: double.infinity,
              height: double.infinity,
              child: const Text(""),
            ),
          ),
        ));
  }
}
