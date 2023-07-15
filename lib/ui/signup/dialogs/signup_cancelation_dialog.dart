import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

class SignUpCancelationDialog extends StatelessWidget {
  const SignUpCancelationDialog({
    super.key,
    required this.cancelSignUp,
    required this.abortCancelation,
  });

  final VoidCallback cancelSignUp;
  final VoidCallback abortCancelation;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Aviso"),
      content: const Text("Tem certeza que deseja cancelar o seu cadastro? Você irá voltar para tela de login"),
      actions: [
        TextButton(
          onPressed: cancelSignUp,
          child: Text(
            'Sim, desejo cancelar meu cadastro',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        TextButton(
          onPressed: abortCancelation,
          child: Text(
            'Não, desejo continuar meu cadastro',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
      ],
    );
  }
}
