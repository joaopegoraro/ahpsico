import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

class AhpsicoTopbar extends StatelessWidget implements PreferredSizeWidget {
  const AhpsicoTopbar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AhpsicoColors.light,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: IconButton(
          onPressed: () {/* TODO */},
          padding: EdgeInsets.zero,
          splashRadius: 24,
          constraints: BoxConstraints(),
          icon: CircleAvatar(
            backgroundColor: AhpsicoColors.violet,
            radius: 32,
            child: Text(
              "A",
              style: AhpsicoText.title3Style.copyWith(
                color: AhpsicoColors.light,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: AhpsicoText.title3Style.copyWith(
          color: AhpsicoColors.dark75,
        ),
      ),
    );
  }
}
