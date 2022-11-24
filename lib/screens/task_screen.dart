import 'package:flutter/material.dart';
import '../widgets/task/task_menu_view.dart';
import '../widgets/task/task_page.dart';

class TaskScreen extends StatelessWidget {
  static const breakpoint = 600.0;
  static const menuWidth = 340.0;

  const TaskScreen({super.key});

  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    debugPrint("build TaskPage");

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
          Expanded(child: TaskPage()),
        ],
      );
    } else {
      // narrow screen: show content, menu inside drawer
      return Scaffold(
        body: TaskPage(),
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
