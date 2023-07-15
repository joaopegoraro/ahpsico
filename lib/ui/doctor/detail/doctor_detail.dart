import 'package:ahpsico/models/doctor.dart';
import 'package:flutter/material.dart';

class DoctorDetail extends StatelessWidget {
  const DoctorDetail(
    this.doctor, {
    super.key,
  });

  static const route = "/doctor/detail";

  final Doctor? doctor;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
