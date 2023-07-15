import 'package:ahpsico/models/patient.dart';
import 'package:flutter/material.dart';

class PatientDetail extends StatelessWidget {
  const PatientDetail(
    this.patient, {
    super.key,
  });

  static const route = "/patient/detail";

  final Patient? patient;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
