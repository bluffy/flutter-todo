import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todo/screens/task_screen.dart';
import 'package:flutter_todo/screens/initialization_screen.dart';
import 'package:flutter_todo/initialization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(
    child: MyApp(initializer: DefaultAppInitializer()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initializer});

  final AppInitializer initializer;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ToDo',
        theme: ThemeData.from(colorScheme: const ColorScheme.light()),
        darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
        builder: (context, child) => InitializationPage(
              initialize: initializer.ensureInitialized,
              builder: (context) => ProvideRootDependencies(
                dependencies: initializer.rootDependencies,
                child: child!,
              ),
            ),
        initialRoute: '/',
        routes: {'/': (context) => const TaskScreen()});
    //home: const TaskScreen());
  }
}
