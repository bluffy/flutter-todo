import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';

class TaskMenuView extends ConsumerWidget {
  const TaskMenuView({super.key});

  void _selectPage(BuildContext context, WidgetRef ref, Navi navi) {
    ref.read(taskListkProvider.notifier).loadState(navi);

    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
      Navigator.of(context).pop();
    }
  }

/*
   Widget dragTarget(BuildContext context, WidgetRef ref, Navi nai) {
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

          ref
              .read(taskListkProvider.notifier)
              .doListSortingFromMenu(sourceID: data);
 
        // taskListState.doListSorting( targetID, targetSort, sourceID)
      },
    );
    */

  Widget dragTargetMenuItem(BuildContext context, WidgetRef ref, Navi navi) {
    final selectedNavi = ref.watch(naviSelectProvider);
    String title;
    late Icon icon;
    switch (navi) {
      case Navi.inbox:
        title = 'Eingang';
        icon = const Icon(Icons.inbox);
        break;
      case Navi.today:
        title = 'Heute';
        icon = const Icon(Icons.today);
        break;
      default:
        title = '<<Unknown>>';
    }
    return DragTarget(
        builder: (ctxDragTarget, candidateData, rejectedData) {
          return ListTile(
            onTap: (ref.read(naviSelectProvider) != navi)
                ? () {
                    _selectPage(context, ref, navi);
                  }
                : null,
            selected: navi == selectedNavi,
            leading: icon,
            title: Text(title),
          );
        },
        onWillAccept: (data) => navi != selectedNavi,
        onAccept: (int data) {
          ref
              .read(taskListkProvider.notifier)
              .doListSortingFromMenu(data, navi);

          /*ref
          .read(taskListkProvider.notifier)
          .doListSortingFromMenu(sourceID: data);
*/
          // taskListState.doListSorting( targetID, targetSort, sourceID)
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: GestureDetector(
              onTap: () {
                ProviderAction.unSelectTask(ref);
              },
              child: const SizedBox(height: double.infinity, child: Text("")),
            ),
            title: GestureDetector(
              child: const Text('Notes'),
              onTap: () {
                ProviderAction.unSelectTask(ref);
              },
            )),
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              debugPrint("unselect");
              ProviderAction.unSelectTask(ref);
            },
            child: Container(
              color: (ref.watch(taskActionProvider) != TaskAction.none)
                  ? Theme.of(context).disabledColor
                  : null,
              width: double.infinity,
              height: double.infinity,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  dragTargetMenuItem(context, ref, Navi.inbox),
                  dragTargetMenuItem(context, ref, Navi.today),
                  /*
                  ListTile(
                    onTap: () {
                      _selectPage(context, ref, Navi.inbox);
                    },
                    selected: (ref.watch(naviSelectProvider) == Navi.inbox),
                    leading: const Icon(Icons.inbox),
                    title: const Text('inbox'),
                  ),*/
                ],
              ),
            ),
          ),
        ));
  }
}
