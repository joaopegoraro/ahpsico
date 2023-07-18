import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
    this.onPressed,
    this.iconForegroundColor,
    this.iconBackgroundColor = AhpsicoColors.light80,
    this.textColor = AhpsicoColors.light80,
    this.enableFlex = false,
    this.flex = 1,
    this.flexFit = FlexFit.tight,
    this.width,
    this.height,
  });

  final String text;
  final Color color;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color? iconForegroundColor;
  final Color? textColor;
  final VoidCallback? onPressed;
  final bool enableFlex;
  final int flex;
  final FlexFit flexFit;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return [
      SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              padding: const MaterialStatePropertyAll(EdgeInsets.all(16)),
              backgroundColor: MaterialStatePropertyAll(color),
              shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ))),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Icon(
                  icon,
                  color: iconForegroundColor ?? color,
                ),
              ),
              AhpsicoSpacing.horizontalSpaceSmall,
              Flexible(
                child: Text(
                  text,
                  style: AhpsicoText.regular2Style.copyWith(color: textColor),
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      )
    ].map((button) {
      if (enableFlex) {
        return Flexible(
          flex: flex,
          fit: flexFit,
          child: button,
        );
      }
      return button;
    }).first;
  }
}
