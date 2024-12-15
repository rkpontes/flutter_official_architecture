// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:flutter_oficial_architecture/ui/home/view_models/home_view_model.dart';
import '../ui/home/widgets/home_screen.dart';
import 'routes.dart';

GoRouter get router {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    redirect: _redirect,
    // refreshListenable: authRepository,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (_, state) => HomeScreen(viewModel: GetIt.I<HomeViewModel>()),
      ),
    ],
  );
}

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // if the user is not logged in, they need to login
  // final bool loggedIn = await context.read<AuthRepository>().isAuthenticated;
  // final bool loggingIn = state.matchedLocation == Routes.login;
  // if (!loggedIn) {
  //   return Routes.login;
  // }

  // if the user is logged in but still on the login page, send them to
  // the home page
  // if (loggingIn) {
  //   return Routes.home;
  // }

  // no need to redirect at all
  return null;
}
