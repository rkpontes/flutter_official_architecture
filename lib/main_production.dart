// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

// Project imports:
import 'injector.dart';
import 'main.dart';

final getIt = GetIt.instance;

void main() {
  Logger.root.level = Level.ALL;
  Injector.configureDependencies(flavor: Flavor.production);
  runApp(const MainApp());
}
