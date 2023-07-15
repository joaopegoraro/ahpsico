import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({
    super.key,
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Aviso"),
      content: const Text("Tem certeza que deseja efetuar logout? Você irá voltar para tela de login"),
      actions: [
        TextButton(
          onPressed: onLogout,
          child: Text(
            'Sim, desejo fazer logout',
            textAlign: TextAlign.end,
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(
            'Não, desejo continuar usando o aplicativo',
            textAlign: TextAlign.end,
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
      ],
    );
  }
}
