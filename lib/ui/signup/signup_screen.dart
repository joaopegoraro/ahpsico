import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static const route = "/signup";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(
        child: Center(
          child: Text("SIGN UP SCREEN"),
        ),
      ),
    );
  }
}
