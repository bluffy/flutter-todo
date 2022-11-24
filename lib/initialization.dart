import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_todo/models/task_model.dart';
import 'package:flutter_todo/models/app_config_model.dart';
import 'core/constants.dart';

/// Initializer, which prepares the app for execution.
///
/// Tests can use an alternative implementation, instead of the
/// [DefaultAppInitializer].
abstract class AppInitializer {
  static Future<void>? _initialized;

  /// Ensures that the app is initialized. Can be called multiple times.
  Future<void> ensureInitialized() => _initialized ??= initialize();

  /// Performs the actual initialization.
  Future<void> initialize();

  /// Returns the root dependencies of the app.
  RootDependencies get rootDependencies;
}

/// The dependencies which are provided at the root of the app.
class RootDependencies {
  RootDependencies(/*{required this.counterRepository}*/);

  /*final CounterRepository counterRepository;*/
}

/// Provides the [RootDependencies] to the widget tree below.
class ProvideRootDependencies extends StatelessWidget {
  const ProvideRootDependencies({
    Key? key,
    required this.dependencies,
    required this.child,
  }) : super(key: key);

  final RootDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
  /*
        Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider.value(value: dependencies.counterRepository),
        ],
        child: child,
      );
      */
}

/*
/// Provides the [RootDependencies] to the widget tree below.
class ProvideRootDependencies extends StatelessWidget {
  const ProvideRootDependencies({
    Key? key,
    required this.dependencies,
    required this.child,
  }) : super(key: key);

  final RootDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider.value(value: dependencies.counterRepository),
        ],
        child: child,
      );
}
*/
/// The default [AppInitializer], which fully initializes the app for production
/// or live development.
class DefaultAppInitializer extends AppInitializer {
  @override

  //await TracingDelegate.install(DevToolsTracing());

  Future<void> initialize() async {
    await Future.wait([
      //AppEnvironment.init(),
      Hive.initFlutter(),
    ]);

    await _setupHiveDB();
  }

  Future<void> _setupHiveDB() async {
    Hive.registerAdapter<AppConfig>(AppConfigAdapter());
    Hive.registerAdapter<Task>(TaskAdapter());
    Hive.registerAdapter<ItemLocation>(ItemLocationAdapter());
    Hive.registerAdapter<Folder>(FolderAdapter());
    await Hive.openBox<AppConfig>(Constants.boxNameAppConfig);
    await Hive.openBox<Task>(Constants.boxNameTasks);
    await Hive.openBox<Folder>(Constants.boxNameFolders);

/*
    var box = await Hive.openBox<AppConfig>(Constants.boxNameAppConfig);

    if (box.isEmpty) {
      box.add(AppConfig(version: 0));
    }
    var appConfig = box.get(0);

      if (appConfig!.version < appVersion) {
    if (appConfig.version < 1) {
      var box = await Hive.openBox<Task>(boxNameTasks);
      for (var task in box.values.toList()) {
        task.itemLocation = ItemLocation.inbox;
        task.save();

        //if task.version == null
      }
    }
  }
  */
  }

  @override
  RootDependencies get rootDependencies => RootDependencies();
/*
  @override
  RootDependencies get rootDependencies => RootDependencies(
        counterRepository: CounterRepository(database: _database),
      );
      */
}
