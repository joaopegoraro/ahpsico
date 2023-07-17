import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:flutter/material.dart';

class AssignmentDetail extends StatelessWidget {
  const AssignmentDetail({
    super.key,
    required this.assignment,
  });

  static const route = "/assignment/detail";

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Center(child: Text("ASSIGNMENT DETAIL")),
    );
  }
}
