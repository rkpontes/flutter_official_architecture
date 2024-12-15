// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'routing/router.dart';
import 'main_production.dart' as production;
import 'main_development.dart' as development;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  switch (flavor) {
    case 'dev':
      development.main();
      break;
    case 'prod':
      production.main();
      break;
  }
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
