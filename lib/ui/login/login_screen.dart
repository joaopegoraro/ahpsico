import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/ui/login/login_model.dart';
import 'package:ahpsico/ui/login/widgets/numeric_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = "/login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController controller;

  final maskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  bool isValid = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AhpsicoColors.violet,
      body: ViewModelBuilder(
        provider: loginModelProvider,
        builder: (context, model) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(46),
              child: Column(
                children: [
                  Text(
                    "Digite seu telefone para entrar ou criar uma conta no aplicativo",
                    textAlign: TextAlign.center,
                    style: AhpsicoText.title3Style.copyWith(color: AhpsicoColors.light80),
                  ),
                  const Spacer(),
                  AhpsicoInputField(
                    controller: controller,
                    hint: "Telefone",
                    readOnly: true,
                    errorText: controller.text.isNotEmpty && !isValid
                        ? "Por favor, digite um número de telefone válido"
                        : null,
                    borderColor: isValid ? AhpsicoColors.green : null,
                    borderWidth: controller.text.isEmpty ? null : 2.0,
                    canRequestFocus: false,
                  ),
                  const Spacer(),
                  NumericKeyboard(
                    textStyle: AhpsicoText.title1Style.copyWith(color: AhpsicoColors.light80),
                    leftIcon: const Icon(Icons.backspace, color: AhpsicoColors.light80),
                    leftButtonLongPressFn: () {
                      final text = controller.text;
                      controller.text = text.substring(0, text.length - 1);
                      setState(() {
                        isValid = isPhoneValid(controller.text);
                      });
                    },
                    leftButtonFn: () {
                      final text = controller.text;
                      controller.text = text.substring(0, text.length - 1);
                      setState(() {
                        isValid = isPhoneValid(controller.text);
                      });
                    },
                    rightIcon: Icon(
                      Icons.arrow_forward_ios,
                      color: isValid ? AhpsicoColors.green80 : AhpsicoColors.light60,
                    ),
                    onKeyboardTap: (number) {
                      final newUnmaskedPhone = controller.text + number;
                      final newMaskedPhone = maskFormatter.maskText(newUnmaskedPhone);
                      controller.text = newMaskedPhone;
                      setState(() {
                        isValid = isPhoneValid(controller.text);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

bool isPhoneValid(String phoneNumber) {
  final regExp = RegExp(r'^\(?[1-9]{2}\)? ?(?:[2-8]|9[1-9])[0-9]{3}\-?[0-9]{4}$');
  return regExp.hasMatch(phoneNumber);
}
