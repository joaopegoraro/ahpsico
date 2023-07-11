import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/login/login_model.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const route = "/login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AhpsicoColors.violet,
      body: ViewModelBuilder.nonReactive(
        provider: loginModelProvider,
        builder: (context, model) {
          return const Placeholder(
            color: AhpsicoColors.light,
          );
        },
      ),
    );
  }
}
