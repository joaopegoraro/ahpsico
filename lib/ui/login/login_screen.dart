import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/login/login_model.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const route = "/login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AhpsicoColors.light,
      body: ViewModelBuilder(
        provider: loginModelProvider,
        builder: (context, model) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AhpsicoButton.primary(
                    "PRIMARIO",
                    onPressed: () => "SOMETHING",
                  ),
                  AhpsicoSpacing.horizontalSpaceSmall,
                  AhpsicoButton.secondary(
                    "SECUNDARIO",
                    onPressed: () => "SOMETHING",
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
