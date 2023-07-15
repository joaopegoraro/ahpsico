import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.isPhoneValid,
    this.readOnly = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool isPhoneValid;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) {
    return AhpsicoInputField(
      controller: controller,
      textAlign: TextAlign.center,
      hint: "Telefone",
      readOnly: readOnly,
      inputType: TextInputType.phone,
      errorText: controller.text.isNotEmpty && !isPhoneValid ? "Por favor, digite um número de telefone válido" : null,
      borderColor: isPhoneValid ? AhpsicoColors.green : null,
      borderWidth: controller.text.isEmpty ? null : 2.0,
      canRequestFocus: !readOnly,
    );
  }
}
