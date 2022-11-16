import 'package:flutter/material.dart';
import 'package:flutter_todo/utils/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo/models/task_model.dart';

class TaskFormular extends StatelessWidget {
  TaskFormular({Key? key}) : super(key: key);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final FocusNode titleFocus = FocusNode();

  Widget formularFooter(context, taskmodel, taskcontroller) {
    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                taskFormularsave(context, taskmodel, taskcontroller);
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
                      taskmodel.closeFormular();
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
  Widget build(BuildContext context) {
    var taskmodel = context.watch<TaskModel>();
    var taskcontroller = context.watch<TaskController>();

    taskFormularfill(context, taskmodel, taskcontroller);

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
                      formularFooter(context, taskmodel, taskcontroller),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  void taskFormularfill(
      context, TaskModel taskmodel, TaskController taskcontroller) async {
    if (taskcontroller.action == TaskActionStatus.add) {
      titleController.text = "";
      titleFocus.requestFocus();
      descController.text = "";
      return;
    }

    if (taskcontroller.action == TaskActionStatus.save) {
      final task = await taskmodel.get(taskcontroller.selectedTaskId);
      if (task == null) {
        CustomDialog.showAlertDialog(
            context: context, text: "Task nicht vorhanden!");
        taskmodel.closeFormular();
        return;
      }
      titleController.text = task.title!;
      titleFocus.requestFocus();

      descController.text = task.description!;
      return;
    }
  }

  void taskFormularsave(
      context, TaskModel taskmodel, TaskController taskcontroller) async {
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

    if (taskcontroller.action == TaskActionStatus.add) {
      await taskmodel.addTask(title, description);
      taskmodel.closeFormular();

      return;
    }

    if (taskcontroller.action == TaskActionStatus.save) {
      await taskmodel.updateTask(title, description);
      taskmodel.closeFormular();
    }
    return;
  }
}
