import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpConfirmationDialog extends StatelessWidget {
  const SignUpConfirmationDialog({
    super.key,
    required this.name,
    required this.isDoctor,
    required this.onConfirm,
  });

  final String name;
  final bool isDoctor;
  final VoidCallback onConfirm;

  String get accountType => isDoctor ? "Psicólogo" : "Paciente";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Aviso"),
      content: Text(
        "$name, tem certeza que deseja criar uma conta de $accountType? Não será possível mudar sua conta no futuro",
      ),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: Text(
            'Sim, sou um $accountType',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(
            'Não, acho que cliquei sem querer...',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
      ],
    );
  }
}
