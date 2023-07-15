import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:flutter/material.dart';

class HomeTopbar extends StatelessWidget {
  const HomeTopbar({super.key, required this.userName, this.goToProfile, this.logout});

  final String userName;
  final VoidCallback? goToProfile;
  final VoidCallback? logout;

  @override
  Widget build(BuildContext context) {
    return Topbar(
      title: "Olá, $userName",
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: PopupMenuButton(
            child: const Icon(
              Icons.more_vert,
              color: AhpsicoColors.light80,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: goToProfile,
                child: const Text('Editar perfil'),
              ),
              PopupMenuItem(
                onTap: logout,
                child: const Text('Sair do aplicativo'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
