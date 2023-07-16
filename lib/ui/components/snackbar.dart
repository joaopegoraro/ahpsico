import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:flutter/material.dart';

class AhpsicoSnackbar extends SnackBar {
  AhpsicoSnackbar({
    super.key,
    String? text,
    Widget? content,
    Color? backgroundColor,
  }) : super(
            content: content ?? Text(text ?? ""),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))));

  static showSuccess(BuildContext context, String? text) {
    final snackBar = AhpsicoSnackbar(
      text: text,
      backgroundColor: AhpsicoColors.green,
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static showError(BuildContext context, String? text) {
    final snackBar = AhpsicoSnackbar(
      text: text,
      backgroundColor: AhpsicoColors.red,
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static showWarning(BuildContext context, String? text) {
    final snackBar = AhpsicoSnackbar(
      text: text,
      backgroundColor: AhpsicoColors.yellow,
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
