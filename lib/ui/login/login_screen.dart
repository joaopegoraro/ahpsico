import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/doctor/doctor_home.dart';
import 'package:ahpsico/ui/login/login_model.dart';
import 'package:ahpsico/ui/login/widgets/countdown.dart';
import 'package:ahpsico/ui/login/widgets/numeric_keyboard.dart';
import 'package:ahpsico/ui/patient/patient_home.dart';
import 'package:ahpsico/ui/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = "/login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late final TextEditingController _phoneController;
  late final TextEditingController _codeController;
  late final AnimationController _codeTimercontroller;

  late final Function(AnimationStatus) _codeTimerStatusListener;

  @override
  void initState() {
    super.initState();
    _codeTimerStatusListener = (_) => setState(() {});
    _phoneController = TextEditingController();
    _codeController = TextEditingController();
    _codeTimercontroller = AnimationController(
      vsync: this,
      duration: LoginModel.timerDuration,
    )..addStatusListener(_codeTimerStatusListener);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _codeTimercontroller
      ..removeStatusListener(_codeTimerStatusListener)
      ..dispose();
    super.dispose();
  }

  void _listenToEvents(BuildContext context, LoginModel model, LoginEvent event) {
    switch (event) {
      case LoginEvent.updateCodeInputField:
        setState(() => _codeController.text = model.verificationCode);
      case LoginEvent.updatePhoneInputField:
        setState(() => _phoneController.text = model.phoneNumber);
      case LoginEvent.startCodeTimer:
        _codeTimercontroller
          ..reset()
          ..forward();
      case LoginEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case LoginEvent.showSnackbarMessage:
        AhpsicoSnackbar.showSuccess(context, model.snackbarMessage);
      case LoginEvent.navigateToDoctorHome:
        context.go(DoctorHome.route);
      case LoginEvent.navigateToPatientHome:
        context.go(PatientHome.route);
      case LoginEvent.navigateToSignUp:
        context.go(SignUpScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AhpsicoColors.violet,
      extendBody: true,
      body: ViewModelBuilder(
        provider: loginModelProvider,
        onEventEmitted: _listenToEvents,
        builder: (context, model) {
          return FutureBuilder(
            future: model.autoSignIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SafeArea(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AhpsicoColors.light80,
                    ),
                  ),
                );
              }

              return WillPopScope(
                onWillPop: model.cancelCodeVerification,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(46),
                    child: Column(
                      children: [
                        Text(
                          model.hasCodeBeenSent
                              ? "Digite o código que foi enviado por SMS para ${model.phoneNumber}"
                              : "Digite seu telefone para entrar ou criar uma conta no aplicativo",
                          textAlign: TextAlign.center,
                          style: AhpsicoText.title3Style.copyWith(color: AhpsicoColors.light80),
                        ),
                        const Spacer(),
                        model.hasCodeBeenSent
                            ? AhpsicoInputField(
                                controller: _codeController,
                                textAlign: TextAlign.center,
                                hint: "Código de seis dígitos",
                                readOnly: true,
                                errorText: _codeController.text.isNotEmpty && !model.isCodeValid ? "" : null,
                                borderColor: model.isCodeValid ? AhpsicoColors.green : null,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                inputType: TextInputType.number,
                                maxLenght: 6,
                                borderWidth: _codeController.text.isEmpty ? null : 2.0,
                                canRequestFocus: false,
                              )
                            : AhpsicoInputField(
                                controller: _phoneController,
                                textAlign: TextAlign.center,
                                hint: "Telefone",
                                readOnly: true,
                                inputType: TextInputType.phone,
                                errorText: _phoneController.text.isNotEmpty && !model.isPhoneValid
                                    ? "Por favor, digite um número de telefone válido"
                                    : null,
                                borderColor: model.isPhoneValid ? AhpsicoColors.green : null,
                                borderWidth: _phoneController.text.isEmpty ? null : 2.0,
                                canRequestFocus: false,
                              ),
                        if (model.hasCodeBeenSent) ...[
                          AhpsicoSpacing.verticalSpaceRegular,
                          Row(
                            children: [
                              Countdown(
                                animation: StepTween(
                                  begin: LoginModel.timerDuration.inSeconds,
                                  end: 0,
                                ).animate(_codeTimercontroller),
                              ),
                              const Spacer(),
                              if (_codeTimercontroller.isCompleted) ...[
                                AhpsicoSpacing.horizontalSpaceRegular,
                                TextButton(
                                  onPressed: model.isLoadingSignIn ? null : () => model.sendVerificationCode(),
                                  child: Text(
                                    "Reenviar código",
                                    style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.blue20),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        const Spacer(),
                        NumericKeyboard(
                          textStyle: AhpsicoText.title1Style.copyWith(color: AhpsicoColors.light80),
                          leftIcon: const Icon(Icons.backspace, color: AhpsicoColors.light80),
                          allowLeftLongPress: true,
                          onTapLeftButton: model.deleteText,
                          rightIcon: (model.isLoadingSendindCode || model.isLoadingSignIn)
                              ? const CircularProgressIndicator(color: AhpsicoColors.green80)
                              : Icon(
                                  Icons.arrow_forward_ios,
                                  color: (!model.hasCodeBeenSent && model.isPhoneValid) ||
                                          (model.hasCodeBeenSent && model.isCodeValid)
                                      ? AhpsicoColors.green80
                                      : AhpsicoColors.light60,
                                ),
                          onTapRightButton: model.confirmText,
                          onKeyboardTap: model.updateText,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
