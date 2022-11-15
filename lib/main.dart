import 'package:flutter/material.dart';
import 'package:flutter_todo/models/task_model.dart';
import 'package:provider/provider.dart';
import 'screens/tasks_screen.dart';
import './db/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // In this sample app, CatalogModel never changes, so a simple Provider
          // is sufficient.
          // CartModel is implemented as a ChangeNotifier, which calls for the use
          // of ChangeNotifierProvider. Moreover, CartModel depends
          // on CatalogModel, so a ProxyProvider is needed.
          ChangeNotifierProvider<TaskController>(
            create: (context) => TaskController(),
          ),
          ChangeNotifierProxyProvider<TaskController, TaskModel>(
              create: (context) => TaskModel(),
              update: (context, controller, model) {
                if (model == null) throw ArgumentError.notNull('cart');
                model.controller = controller;
                model.getAllTasks();

                return model;
              })
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData.from(colorScheme: const ColorScheme.light()),
          darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
          initialRoute: '/',
          routes: {'/': (context) => TaskPage()},
        ));
  }
}
