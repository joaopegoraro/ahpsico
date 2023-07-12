import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AhpsicoInputField extends StatelessWidget {
  const AhpsicoInputField({
    super.key,
    this.controller,
    this.hint,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.errorColor,
    this.borderColor,
    this.errorBorderColor,
    this.borderWidth,
    this.inputType,
    this.maxLenght,
    this.maxLines,
    this.canRequestFocus = true,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? hint;
  final bool readOnly;
  final bool enabled;
  final bool canRequestFocus;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final Color? errorColor;
  final Color? borderColor;
  final Color? errorBorderColor;
  final double? borderWidth;
  final TextInputType? inputType;
  final int? maxLenght;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      keyboardType: inputType,
      canRequestFocus: canRequestFocus,
      maxLength: maxLenght,
      maxLines: maxLines,
      style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.dark75),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        enabled: enabled,
        errorText: errorText,
        errorStyle: AhpsicoText.smallStyle.copyWith(color: AhpsicoColors.red40),
        errorMaxLines: 10,
        hintText: hint,
        hintStyle: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.dark25),
        filled: true,
        fillColor: AhpsicoColors.light,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorBorderColor ?? AhpsicoColors.red,
            width: borderWidth ?? 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? AhpsicoColors.light20,
            width: borderWidth ?? 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? AhpsicoColors.light20,
            width: borderWidth ?? 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? AhpsicoColors.light20,
            width: borderWidth ?? 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
