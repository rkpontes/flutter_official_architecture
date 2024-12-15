// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_oficial_architecture/injector.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'routing/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Injector.configureDependencies(flavor: flavor);
  await Injector.getIt.isReady<SharedPreferences>();
  runApp(const MainApp());
}

Flavor get flavor {
  const flavorStr = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  debugPrint('Configuring dependencies for flavor: $flavorStr');
  return flavorStr == 'dev' ? Flavor.development : Flavor.production;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
