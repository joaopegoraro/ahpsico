import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

class AhpsicoButton extends StatelessWidget {
  const AhpsicoButton(
    this.text, {
    super.key,
    this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.enableFlex = false,
    this.flex = 1,
    this.flexFit = FlexFit.tight,
    this.color = AhpsicoColors.violet,
    this.textColor = AhpsicoColors.light80,
  });

  final String text;
  final double? width;
  final double? height;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final bool enableFlex;
  final int flex;
  final FlexFit flexFit;

  const AhpsicoButton.primary(
    this.text, {
    super.key,
    this.width,
    this.height,
    this.onPressed,
    this.enableFlex = false,
    this.isLoading = false,
    this.flex = 1,
    this.flexFit = FlexFit.tight,
  })  : color = AhpsicoColors.violet,
        textColor = AhpsicoColors.light80;

  const AhpsicoButton.secondary(
    this.text, {
    super.key,
    this.width,
    this.height,
    this.enableFlex = false,
    this.isLoading = false,
    this.onPressed,
    this.flex = 1,
    this.flexFit = FlexFit.tight,
  })  : color = AhpsicoColors.violet20,
        textColor = AhpsicoColors.violet;

  @override
  Widget build(BuildContext context) {
    return [
      SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
            backgroundColor: MaterialStateProperty.all(color),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          onPressed: onPressed,
          child: FittedBox(
            fit: BoxFit.contain,
            child: isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 3.5,
                    ),
                  )
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: AhpsicoText.title3Style.copyWith(
                      color: textColor,
                    ),
                  ),
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
