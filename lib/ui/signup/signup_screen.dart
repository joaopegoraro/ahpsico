import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/button.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/doctor/home/doctor_home.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/patient/home/patient_home.dart';
import 'package:ahpsico/ui/signup/dialogs/signup_cancelation_dialog.dart';
import 'package:ahpsico/ui/signup/dialogs/signup_confirmation_dialog.dart';
import 'package:ahpsico/ui/signup/signup_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/viewmodel_builder.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const route = "/signup";

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _listenToEvents(BuildContext context, SignUpModel model, SignUpEvent event) {
    switch (event) {
      case SignUpEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case SignUpEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case SignUpEvent.navigateToDoctorHome:
        context.go(DoctorHome.route);
      case SignUpEvent.navigateToPatientHome:
        context.go(PatientHome.route);
      case SignUpEvent.navigateToLogin:
        context.go(LoginScreen.route);
      case SignUpEvent.openCancelationDialog:
        showDialog(
          context: context,
          builder: (context) => SignUpCancelationDialog(
            onConfirm: model.cancelSignUp,
          ),
        );
      case SignUpEvent.openConfirmationDialog:
        showDialog(
          context: context,
          builder: (context) => SignUpConfirmationDialog(
            name: model.name,
            isDoctor: model.isDoctor,
            onConfirm: () {
              context.pop();
              model.completeSignUp();
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AhpsicoColors.light,
      body: ViewModelBuilder(
        provider: signUpModelProvider,
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return WillPopScope(
            onWillPop: () {
              if (!model.isLoadingSignUp) {
                model.openCancelationDialog();
              }
              return Future.value(false);
            },
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    AhpsicoSpacing.verticalSpaceLarge,
                    Text(
                      "Só falta mais um pouco...",
                      style: AhpsicoText.title1Style.copyWith(color: AhpsicoColors.dark50),
                    ),
                    AhpsicoSpacing.verticalSpaceMedium,
                    Text(
                      "Informe seu nome, e escolha se você é um Psicólogo ou um Paciente",
                      style: AhpsicoText.regular3Style.copyWith(color: AhpsicoColors.dark25),
                    ),
                    AhpsicoSpacing.verticalSpaceRegular,
                    AhpsicoInputField(
                      controller: _nameController,
                      hint: "Nome",
                      enabled: !model.isLoadingSignUp,
                      inputType: TextInputType.name,
                      onChanged: model.updateName,
                      errorText: model.isNameValid
                          ? null
                          : "Seu nome é muito grande. Por favor, informe um nome com menos de 150 caracteres",
                    ),
                    const Spacer(),
                    AhpsicoButton.primary(
                      "SOU PSICÓLOGO",
                      width: double.infinity,
                      isLoading: model.isDoctor && model.isLoadingSignUp,
                      onPressed: model.isLoadingSignUp ? null : () => model.openConfirmationDialog(isDoctor: true),
                    ),
                    AhpsicoSpacing.verticalSpaceSmall,
                    AhpsicoButton.secondary(
                      "SOU PACIENTE",
                      width: double.infinity,
                      isLoading: !model.isDoctor && model.isLoadingSignUp,
                      onPressed: model.isLoadingSignUp ? null : () => model.openConfirmationDialog(isDoctor: false),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
