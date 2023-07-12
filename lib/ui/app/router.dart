import 'package:ahpsico/ui/doctor/doctor_home.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/patient_home.dart';
import 'package:ahpsico/ui/signup/signup_screen.dart';
import 'package:go_router/go_router.dart';

final class AhpsicoRouter {
  AhpsicoRouter._();

  static final router = GoRouter(
    initialLocation: LoginScreen.route,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: LoginScreen.route,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SignUpScreen.route,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: DoctorHome.route,
        builder: (context, state) => const DoctorHome(),
      ),
      GoRoute(
        path: PatientHome.route,
        builder: (context, state) => const PatientHome(),
      ),
    ],
  );
}