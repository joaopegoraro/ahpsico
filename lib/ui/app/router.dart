import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/ui/advices/list/advices_list.dart';
import 'package:ahpsico/ui/assignments/detail/assignment_detail.dart';
import 'package:ahpsico/ui/assignments/list/assignments_list.dart';
import 'package:ahpsico/ui/doctor/detail/doctor_detail.dart';
import 'package:ahpsico/ui/doctor/home/doctor_home.dart';
import 'package:ahpsico/ui/doctor/list/doctor_list.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/detail/patient_detail.dart';
import 'package:ahpsico/ui/patient/home/patient_home.dart';
import 'package:ahpsico/ui/patient/list/patient_list.dart';
import 'package:ahpsico/ui/schedule/schedule_screen.dart';
import 'package:ahpsico/ui/session/detail/session_detail.dart';
import 'package:ahpsico/ui/session/list/session_list.dart';
import 'package:ahpsico/ui/signup/signup_screen.dart';
import 'package:go_router/go_router.dart';

final class AhpsicoRouter {
  AhpsicoRouter._();

  static final router = GoRouter(
    initialLocation: PatientList.route,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),

      // Login and SignUp

      GoRoute(
        path: LoginScreen.route,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SignUpScreen.route,
        builder: (context, state) => const SignUpScreen(),
      ),

      // Doctors

      GoRoute(
        path: DoctorHome.route,
        builder: (context, state) => const DoctorHome(),
      ),
      GoRoute(
        path: DoctorList.route,
        builder: (context, state) => const DoctorList(),
      ),
      GoRoute(
        path: DoctorDetail.route,
        builder: (context, state) {
          final doctor = state.extra as Doctor?;
          return DoctorDetail(doctor);
        },
      ),

      // Patients

      GoRoute(
        path: PatientHome.route,
        builder: (context, state) => const PatientHome(),
      ),
      GoRoute(
        path: PatientList.route,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final bool selectMode = args?['selectMode'] ?? false;
          final bool allSelected = args?['allSelected'] ?? false;
          return PatientList(
            selectModeByDefault: selectMode,
            allSelectedByDefault: allSelected,
          );
        },
      ),
      GoRoute(
        path: PatientDetail.route,
        builder: (context, state) {
          final patient = state.extra as Patient;
          return PatientDetail(patient);
        },
      ),

      // Advices

      GoRoute(
        path: AdvicesList.route,
        builder: (context, state) {
          final patient = state.extra as Patient?;
          return AdvicesList(patient: patient);
        },
      ),

      // Schedule

      GoRoute(
        path: ScheduleScreen.route,
        builder: (context, state) => const ScheduleScreen(),
      ),

      // Sessions

      GoRoute(
        path: SessionList.route,
        builder: (context, state) {
          final patient = state.extra as Patient?;
          return SessionList(patient: patient);
        },
      ),
      GoRoute(
        path: SessionDetail.route,
        builder: (context, state) {
          final session = state.extra as Session;
          return SessionDetail(session);
        },
      ),

      // Assignments

      GoRoute(
        path: AssignmentsList.route,
        builder: (context, state) {
          final patient = state.extra as Patient?;
          return AssignmentsList(patient: patient);
        },
      ),
      GoRoute(
        path: AssignmentDetail.route,
        builder: (context, state) {
          final assignment = state.extra as Assignment;
          return AssignmentDetail(assignment: assignment);
        },
      ),
    ],
  );
}
