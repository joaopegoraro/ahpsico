import 'package:ahpsico/models/advice.dart';
import 'package:flutter/material.dart';

class AdviceDetailSheet extends StatelessWidget {
  const AdviceDetailSheet({
    super.key,
    required this.advice,
    required this.isUserDoctor,
  });

  final Advice advice;
  final bool isUserDoctor;

  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Text("ADVICE DETAIL"),
    );
  }
}
