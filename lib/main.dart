import 'package:flutter/material.dart';
import 'package:flutter_todo/screens/task_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './db/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDatabase();
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
      title: 'Flutter Demo',
      theme: ThemeData.from(colorScheme: const ColorScheme.light()),
      darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
      initialRoute: '/',
      routes: {'/': (context) => const TaskPage()},
    );
  }
}
