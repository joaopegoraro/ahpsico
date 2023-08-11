import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

class FabAction extends StatelessWidget {
  const FabAction({
    super.key,
    required this.onTap,
    this.backgroundColor = AhpsicoColors.violet,
    this.foregroundColor = AhpsicoColors.light80,
    this.label,
    this.icon,
    this.borderRadius = 30,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final String? label;
  final IconData? icon;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      onTap: onTap,
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        color: backgroundColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            children: [
              if (icon != null)
                Icon(
                  icon!,
                  color: foregroundColor,
                ),
              if (icon != null && label != null) AhpsicoSpacing.horizontalSpaceSmall,
              if (label != null)
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    label!,
                    style: AhpsicoText.smallStyle.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ),
              AhpsicoSpacing.horizontalSpaceSmall,
            ],
          ),
        ),
      ),
    );
  }
}
