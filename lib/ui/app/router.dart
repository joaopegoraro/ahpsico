import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final class AhpsicoRouter {
  AhpsicoRouter._();

  static final router = GoRouter(
    initialLocation: LoginScreen.route,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: LoginScreen.route,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
