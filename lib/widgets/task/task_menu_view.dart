import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';

class TaskMenuView extends ConsumerWidget {
  const TaskMenuView({super.key});

  void _selectPage(BuildContext context, WidgetRef ref, Navi navi) {
    var currentNavi = ref.read(naviSelectProvider);
    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
      Navigator.of(context).pop();
    }

    if (currentNavi != navi) {
      ref.read(naviSelectProvider.notifier).state = navi;
      ref.read(taskListkProvider.notifier).loadState();

      if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListState = ref.read(taskListkProvider.notifier);
    final action = ref.watch(taskActionProvider);
    final navi = ref.watch(naviSelectProvider);

    return Scaffold(
        appBar: AppBar(
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
            )),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              debugPrint("unselect");
              taskListState.unSelectTask();
            },
            child: Container(
              color: (action != TaskAction.none)
                  ? Theme.of(context).disabledColor
                  : null,
              width: double.infinity,
              height: double.infinity,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      _selectPage(context, ref, Navi.inbox);
                    },
                    selected: (navi == Navi.inbox),
                    leading: const Icon(Icons.inbox),
                    title: const Text('inbox'),
                  ),
                  ListTile(
                    onTap: () {
                      _selectPage(context, ref, Navi.today);
                    },
                    selected: (navi == Navi.today),
                    leading: const Icon(Icons.today),
                    title: const Text('Today'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
