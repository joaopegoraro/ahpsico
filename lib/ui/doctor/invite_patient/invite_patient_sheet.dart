import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/components/phone_input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/doctor/invite_patient/invite_patient_model.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class InvitePatientSheet extends StatefulWidget {
  const InvitePatientSheet({super.key});

  @override
  State<InvitePatientSheet> createState() => _InvitePatientSheetState();
}

class _InvitePatientSheetState extends State<InvitePatientSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listenToEvents(
    BuildContext context,
    InvitePatientModel model,
    InvitePatientEvent event,
  ) {
    switch (event) {
      case InvitePatientEvent.updatePhoneInputText:
        setState(() => _controller.text = model.phoneNumber);
      case InvitePatientEvent.navigateToLoginScreen:
        context.go(LoginScreen.route);
      case InvitePatientEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case InvitePatientEvent.openPatientNotRegisteredDialog:
      // TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewModelBuilder(
          provider: invitePatientModelProvider,
          onEventEmitted: _listenToEvents,
          builder: (context, model) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Digite o número de telefone do paciente",
                    style: AhpsicoText.title3Style.copyWith(color: AhpsicoColors.dark75),
                  ),
                  AhpsicoSpacing.verticalSpaceRegular,
                  PhoneInputField(
                    onChanged: model.updatePhone,
                    controller: _controller,
                    isPhoneValid: model.isPhoneValid,
                  ),
                  AhpsicoSpacing.verticalSpaceRegular,
                  AhpsicoButton(
                    "ENVIAR CONVITE PARA TERAPIA",
                    onPressed: model.invitePatient,
                    isLoading: model.isLoading,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
