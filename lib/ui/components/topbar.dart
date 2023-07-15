import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

class AhpsicoTopbar extends StatelessWidget implements PreferredSizeWidget {
  const AhpsicoTopbar({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  final String title;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AhpsicoColors.light,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed,
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_back),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: AhpsicoText.title3Style.copyWith(
          color: AhpsicoColors.dark75,
        ),
      ),
    );
  }
}
