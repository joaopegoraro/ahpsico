import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:flutter/material.dart';

@immutable
class DoctorFabAction extends StatelessWidget {
  const DoctorFabAction({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: AhpsicoColors.violet,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: AhpsicoColors.light80,
      ),
    );
  }
}
