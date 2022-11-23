import 'package:flutter/material.dart';
//import 'package:flutter_todo/screens/task_screen.dart.old';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './models/task_model.dart';
import './screens/task_screen.dart';

const String boxNameTasks = "t";
const String boxNameFolders = "f";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter<Folder>(FolderAdapter());
  await Hive.openBox<Task>(boxNameTasks);
  await Hive.openBox<Folder>(boxNameFolders);

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      theme: ThemeData.from(colorScheme: const ColorScheme.light()),
      darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
      initialRoute: '/',
      routes: {'/': (context) => const TaskPage()},
    );
  }
}
