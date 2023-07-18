import 'package:ahpsico/models/patient.dart';
import 'package:flutter/widgets.dart';

class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.patient,
  });

  static const route = "/sessions";

  final Patient? patient;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
