import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SendMessageDialog extends StatelessWidget {
  const SendMessageDialog({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Aviso"),
      content: const Text("Tem certeza que deseja enviar essa mensagem para os pacientes selecionados?"),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
            onConfirm();
          },
          child: Text(
            'Sim, tenho certeza',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(
            'Não, cancelar',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
      ],
    );
  }
}
