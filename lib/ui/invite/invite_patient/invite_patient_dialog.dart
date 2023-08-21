import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class InvitePatientDialog extends StatelessWidget {
  const InvitePatientDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Aviso"),
      content: const Text(
        "Ainda não existe nenhum paciente com o número informado. "
        "Que tal convidá-lo a usar o app? Clique no botão abaixo para enviar um convite "
        "ao seu paciente!",
      ),
      actions: [
        TextButton(
          onPressed: () {
            const invite = """
Venha fazer terapia comigo no Ahpsico!
Clique no link da sua plataforma para baixar o aplicativo:

Android: TODO

iOS: TODO
            """;
            Share.share(invite, subject: "Venha fazer terapia comigo no Ahpsico!");
          },
          child: Text(
            'Convidar paciente para o aplicativo',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(
            'Fechar',
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
      ],
    );
  }
}
