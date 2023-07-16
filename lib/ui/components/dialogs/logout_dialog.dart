import 'package:ahpsico/ui/components/dialogs/ahpsico_dialog.dart';
import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({
    super.key,
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AhpsicoDialog(
      content: "Tem certeza que deseja efetuar logout? Você irá voltar para tela de login",
      firstButtonText: "Sim, desejo fazer logout",
      onTapFirstButton: onLogout,
      secondButtonText: "Não, desejo continuar usando o aplicativo",
    );
  }
}
