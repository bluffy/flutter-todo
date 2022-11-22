import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todo/utils/dialogs.dart';
import '../../models/task_model.dart';

class TaskFormular extends ConsumerWidget {
  TaskFormular({Key? key}) : super(key: key);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final FocusNode titleFocus = FocusNode();

  Widget formularFooter(context, taskNotifier, action) {
    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                taskFormularsave(context, taskNotifier, action);
              },
              icon: const Icon(Icons.save),
              label: const Text('Speichern'),
            )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                CustomDialog.showConfirmDialog(
                    context: context,
                    text: "Wirklich Abreche",
                    onPressedOk: () {
                      taskNotifier.closeFormular();
                      Navigator.pop(context);
                    });
              },
              icon: const Icon(Icons.save),
              label: const Text('Abbrechen'),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("build Taskformular");
    final taskNotifier = ref.watch(taskskProvider.notifier);
    final action = ref.watch(taskActionProvider.notifier).state;

    taskFormularfill(context, ref);

    return GestureDetector(
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Checkbox(
                overlayColor: null,
                onChanged: null,
                value: false,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            focusNode: titleFocus,
                            controller: titleController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: "Aufgabe",
                            ),
                          )),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: descController,
                            minLines: 2,
                            maxLines: 100,
                            decoration: const InputDecoration(
                              hintText: "Beschreibung",
                              border: UnderlineInputBorder(),
                            ),
                          )),
                      formularFooter(context, taskNotifier, action),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  void taskFormularfill(BuildContext context, WidgetRef ref) async {
    final taskNotifier = ref.read(taskskProvider.notifier);
    final action = ref.read(taskActionProvider.notifier).state;

    if (action == TaskAction.add) {
      titleController.text = "";
      titleFocus.requestFocus();
      descController.text = "";
      return;
    }

    if (action == TaskAction.save) {
      final task = await taskNotifier.getSelectedTask();
      if (task == null) {
        CustomDialog.showAlertDialog(
            context: context, text: "Task nicht vorhanden!");
        taskNotifier.closeFormular();
        return;
      }
      titleController.text = task.title;

      titleFocus.requestFocus();
      if (task.description != null) {
        descController.text = task.description!;
      }

      return;
    }
  }

  void taskFormularsave(
      context, TaskNotifier taskNotifier, TaskAction action) async {
    bool checkFields() {
      if (titleController.text.isNotEmpty) {
        //  _createTask();
        return true;
      } else {
        CustomDialog.showAlertDialog(
            context: context, text: "Task title \ncannot be empty!");
        return false;
      }
    }

    if (!checkFields()) {
      return;
    }

    final String title = titleController.text;
    final String description = descController.text;

    if (action == TaskAction.add) {
      try {
        await taskNotifier.addTask(title, description);
        taskNotifier.closeFormular();
      } catch (e, stacktrace) {
        debugPrint(e.toString());
        debugPrintStack(stackTrace: stacktrace);
        CustomDialog.showAlertDialog(
            context: context, text: "Konnte nicht angelgt werden");
      }

      return;
    }

    if (action == TaskAction.save) {
      try {
        await taskNotifier.updateTask(title, description);
        taskNotifier.closeFormular();
      } catch (e, stacktrace) {
        debugPrint(e.toString());
        debugPrintStack(stackTrace: stacktrace);

        CustomDialog.showAlertDialog(
            context: context, text: "Fehler beim Speichern");
        return;
      }
    }
    return;
  }
}
