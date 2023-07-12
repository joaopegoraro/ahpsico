import 'package:flutter/material.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  static const route = "/doctor/home";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(
        child: Center(
          child: Text("DOCTOR HOME"),
        ),
      ),
    );
  }
}
