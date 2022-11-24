import 'package:flutter/material.dart';
import '../../providers/task_provider.dart';
import '../../utils/dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/task/display_tasks.dart';

class TaskPage extends ConsumerWidget {
  TaskPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ancestorScaffold = Scaffold.maybeOf(context);
    final hasDrawer = ancestorScaffold != null && ancestorScaffold.hasDrawer;
    final action = ref.watch(taskActionProvider);
    final taskListState = ref.read(taskListkProvider.notifier);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            leading: hasDrawer
                ? IconButton(
                    icon: Icon(Icons.menu),
                    // 4. open the drawer if we have one
                    onPressed:
                        hasDrawer ? () => ancestorScaffold.openDrawer() : null,
                  )
                : null,
            flexibleSpace: GestureDetector(
              onTap: () {
                taskListState.unSelectTask();
              },
              child: const SizedBox(height: double.infinity, child: Text("")),
            ),
            title: GestureDetector(
              child: const Text('Notes'),
              onTap: () {
                taskListState.unSelectTask();
              },
            ),
            actions: <Widget>[
              Visibility(
                visible: (action != TaskAction.add),
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
                            taskListState.removeTask().whenComplete(() {
                              taskListState.closeFormular();
                              Navigator.of(context).pop();
                            });
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
                      ref.read(taskActionProvider.notifier).state =
                          TaskAction.add;
                    },
                  ),
                ),
              ),
            ]),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              taskListState.unSelectTask();
            },
            child: Container(
                color: (action != TaskAction.none)
                    ? Theme.of(context).disabledColor
                    : null,
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                    child: Column(
                  children: const [
                    DispayTasks(),
                  ],
                ))),
          ),
        ));
  }
}
