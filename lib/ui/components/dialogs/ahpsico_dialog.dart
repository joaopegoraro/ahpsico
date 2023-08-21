import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AhpsicoDialog extends StatelessWidget {
  const AhpsicoDialog({
    super.key,
    required this.content,
    required this.firstButtonText,
    this.title,
    this.onTapFirstButton,
    this.secondButtonText,
    this.onTapSecondButton,
  });

  static void show({
    required BuildContext context,
    required String content,
    required String firstButtonText,
    String? title,
    VoidCallback? onTapFirstButton,
    String? secondButtonText,
    VoidCallback? onTapSecondButton,
  }) {
    showDialog(
        context: context,
        builder: (context) {
          return AhpsicoDialog(
            content: content,
            firstButtonText: firstButtonText,
            title: title,
            onTapFirstButton: onTapFirstButton,
            secondButtonText: secondButtonText,
            onTapSecondButton: onTapSecondButton,
          );
        });
  }

  final String? title;
  final String content;

  final String firstButtonText;
  final VoidCallback? onTapFirstButton;

  final String? secondButtonText;
  final VoidCallback? onTapSecondButton;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? "Aviso"),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onTapFirstButton ?? context.pop,
          child: Text(
            firstButtonText,
            textAlign: TextAlign.end,
            style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        if (secondButtonText != null)
          TextButton(
            onPressed: onTapSecondButton ?? context.pop,
            child: Text(
              secondButtonText!,
              textAlign: TextAlign.end,
              style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
            ),
          ),
      ],
    );
  }
}
