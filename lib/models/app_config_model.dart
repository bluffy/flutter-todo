import 'package:hive_flutter/hive_flutter.dart';

part 'app_config_model.g.dart';

@HiveType(typeId: 3)
class AppConfig extends HiveObject {
  @HiveField(0, defaultValue: 0)
  int version;
  AppConfig({required this.version});
}
