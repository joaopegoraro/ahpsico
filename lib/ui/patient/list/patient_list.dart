import 'package:flutter/material.dart';

class PatientList extends StatelessWidget {
  const PatientList({
    super.key,
    required this.selectMode,
  });

  static const route = "/patients";

  static Map<String, dynamic> buildArgs({bool selectMode = false}) {
    return {"selectMode": selectMode};
  }

  final bool selectMode;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
