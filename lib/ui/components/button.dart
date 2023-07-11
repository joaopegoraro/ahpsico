import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

class AhpsicoButton extends StatelessWidget {
  const AhpsicoButton(
    this.text, {
    super.key,
    this.onPressed,
    this.disableFlex = false,
    this.flex = 1,
    this.flexFit = FlexFit.tight,
    this.color = AhpsicoColors.violet,
    this.textColor = AhpsicoColors.light80,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final bool disableFlex;
  final int flex;
  final FlexFit flexFit;

  const AhpsicoButton.primary(
    this.text, {
    super.key,
    this.onPressed,
    this.disableFlex = false,
    this.flex = 1,
    this.flexFit = FlexFit.tight,
  })  : color = AhpsicoColors.violet,
        textColor = AhpsicoColors.light80;

  const AhpsicoButton.secondary(
    this.text, {
    super.key,
    this.disableFlex = false,
    this.onPressed,
    this.flex = 1,
    this.flexFit = FlexFit.tight,
  })  : color = AhpsicoColors.violet20,
        textColor = AhpsicoColors.violet;

  @override
  Widget build(BuildContext context) {
    return [
      ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
          backgroundColor: MaterialStateProperty.all(color),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: AhpsicoText.title3Style.copyWith(
              color: textColor,
            ),
          ),
        ),
      )
    ].map((button) {
      if (disableFlex) {
        return button;
      }
      return Flexible(
        flex: flex,
        fit: flexFit,
        child: button,
      );
    }).first;
  }
}
