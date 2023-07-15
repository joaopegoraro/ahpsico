import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpCancelationDialog extends StatelessWidget {
  const SignUpCancelationDialog({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Aviso"),
      content: const Text("Tem certeza que deseja cancelar o seu cadastro? Você irá voltar para tela de login"),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: Text(
            'Sim, desejo cancelar meu cadastro',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(
            'Não, desejo continuar meu cadastro',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
      ],
    );
  }
}
