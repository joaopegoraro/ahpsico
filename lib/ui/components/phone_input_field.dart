import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.isPhoneValid,
    this.textAlign = TextAlign.center,
    this.readOnly = false,
    this.onChanged,
    this.errorColor,
  });

  final TextEditingController controller;
  final bool isPhoneValid;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final Color? errorColor;

  @override
  Widget build(BuildContext context) {
    return AhpsicoInputField(
      controller: controller,
      errorColor: errorColor,
      onChanged: onChanged,
      textAlign: textAlign,
      hint: "Telefone",
      readOnly: readOnly,
      inputFormatters: [
        MaskFormatters.phoneMaskFormatter,
      ],
      inputType: TextInputType.number,
      errorText: controller.text.isNotEmpty && !isPhoneValid ? "Por favor, digite um número de telefone válido" : null,
      borderColor: isPhoneValid ? AhpsicoColors.green : null,
      borderWidth: controller.text.isEmpty ? null : 2.0,
      canRequestFocus: !readOnly,
    );
  }
}
