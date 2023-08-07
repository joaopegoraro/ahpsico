import 'dart:async';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:meta/meta.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum LoginEvent {
  refresh,
  navigateToSignUp,
  navigateToDoctorHome,
  navigateToPatientHome,
  updatePhoneInputField,
  updateCodeInputField,
  startCodeTimer,
  showSnackbarError,
  showSnackbarMessage,
}

final loginModelProvider = ViewModelProviderFactory.create((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return LoginModel(
    authService,
    userRepository,
    preferencesRepository,
  );
});

class LoginModel extends BaseViewModel<LoginEvent> {
  LoginModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
  ) : super(
          errorEvent: LoginEvent.showSnackbarError,
          messageEvent: LoginEvent.showSnackbarMessage,
          navigateToLoginEvent: LoginEvent.refresh,
        );

  /* Utils */

  static const timerDuration = Duration(minutes: 2);

  /* Fields */

  bool _isLoadingAutoSignIn = false;
  bool get isLoadingAutoSignIn => _isLoadingAutoSignIn;

  bool _isLoadingSignIn = false;
  bool get isLoadingSignIn => _isLoadingSignIn;

  bool _isLoadingSendingCode = false;
  bool get isLoadingSendindCode => _isLoadingSendingCode;

  String _phoneNumber = "";
  String get phoneNumber => _phoneNumber;

  bool _isPhoneValid = false;
  bool get isPhoneValid => _isPhoneValid;

  String _verificationCode = "";
  String get verificationCode => _verificationCode;
  bool get isCodeValid => verificationCode.length == 6;

  @visibleForTesting
  String codeVerificationId = "";
  bool get hasCodeBeenSent => codeVerificationId.isNotEmpty;

  /* Methods */

  Future<bool> cancelCodeVerification() async {
    if (hasCodeBeenSent) {
      updateUi(() {
        _verificationCode = "";
        codeVerificationId = "";
      });
      return false;
    }
    return true;
  }

  void updateText(String text) {
    if (!isLoadingSignIn && hasCodeBeenSent) {
      updateCode(verificationCode + text);
    } else if (!isLoadingSendindCode && !hasCodeBeenSent) {
      updatePhone(maskPhone(phoneNumber + text));
    }
  }

  void deleteText() {
    if (!isLoadingSignIn && hasCodeBeenSent && verificationCode.isNotEmpty) {
      updateCode(verificationCode.substring(0, verificationCode.length - 1));
    } else if (!isLoadingSendindCode && !hasCodeBeenSent && phoneNumber.isNotEmpty) {
      updatePhone(phoneNumber.substring(0, phoneNumber.length - 1));
    }
  }

  void confirmText() {
    if (!isLoadingSignIn && hasCodeBeenSent && isCodeValid) {
      _signIn(phoneNumber, verificationCode);
    } else if (!isLoadingSendindCode && !hasCodeBeenSent && isPhoneValid) {
      sendVerificationCode();
    }
  }

  @visibleForTesting
  void updateCode(String code) {
    updateUi(() {
      if (code.length <= 6) {
        _verificationCode = code;
      }
      emitEvent(LoginEvent.updateCodeInputField);
    });
  }

  @visibleForTesting
  void updatePhone(String phoneNumber) {
    updateUi(() {
      _phoneNumber = phoneNumber;
      validatePhone(_phoneNumber);
      emitEvent(LoginEvent.updatePhoneInputField);
    });
  }

  @visibleForTesting
  void validatePhone(String phoneNumber) {
    final regExp = RegExp(AppConstants.phoneRegex);
    _isPhoneValid = regExp.hasMatch(phoneNumber);
  }

  @visibleForTesting
  String maskPhone(String phoneNumber) {
    return MaskFormatters.phoneMaskFormatter.maskText(phoneNumber);
  }

  /* Calls */

  Future<void> sendVerificationCode() async {
    updateUi(() => _isLoadingSendingCode = true);
    final unmaskedPhone = "+55${MaskFormatters.phoneMaskFormatter.unmaskText(phoneNumber)}";

    try {
      await authService.sendVerificationCode(unmaskedPhone);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
      return;
    } on ApiConnectionException catch (_) {
      showConnectionError();
      return;
    }
    // TODO
//      onCodeSent: (verificationId) {
//        updateUi(() {
//          emitEvent(LoginEvent.startCodeTimer);
//          _isLoadingSendingCode = false;
//          codeVerificationId = verificationId;
//        });
//      },
//      onFailed: (err) {
//        updateUi(() => _isLoadingSendingCode = false);
//        if (err is AuthInvalidSignInCodeException) {
//          showSnackbar(
//            "O código digitado não é válido. Certifique-se de que o código informado é o mesmo código de seis dígitos recebido por SMS",
//            LoginEvent.showSnackbarError,
//          );
//        } else {
//          showSnackbar(
//            "Ocorreu um erro ao tentar enviar um SMS para o seu telefone. Tente novamente mais tarde ou entre em contato com o desenvolvedor",
//            LoginEvent.showSnackbarError,
//          );
//          _loggingService?.e(err);
//        }
//      },
//      onAutoRetrievalCompleted: (credential) {
//        updateUi(() => _verificationCode = credential.smsCode);
//        signIn(credential);
//      },
//    );
  }

  Future<void> _signIn(String phoneNumber, String code) async {
    updateUi(() => _isLoadingSignIn = true);
    try {
      final user = await authService.login(phoneNumber, code);
      // TODO
      await userRepository.sync(user.uuid);
      showSnackbar("Login bem sucedido!", LoginEvent.showSnackbarMessage);
      if (user.role.isDoctor) {
        emitEvent(LoginEvent.navigateToDoctorHome);
      } else {
        emitEvent(LoginEvent.navigateToPatientHome);
      }
    } on DatabaseNotFoundException catch (_) {
      emitEvent(LoginEvent.navigateToSignUp);
    } on ApiUserNotRegisteredException catch (_) {
      emitEvent(LoginEvent.navigateToSignUp);
    } on ApiConnectionException catch (_) {
      showSnackbar(
        "Ocorreu um erro ao tentar se conectar ao servidor. Certifique-se de que seu dispositivo esteja conectado corretamente com a internet",
        LoginEvent.showSnackbarError,
      );
    }
    updateUi(() => _isLoadingSignIn = false);
  }

  Future<void> autoSignIn() async {
    updateUi(() => _isLoadingAutoSignIn = true);

    final token = await preferencesRepository.findToken();

    final isUserAuthenticated = token?.isNotEmpty == true;
    if (!isUserAuthenticated) {
      return updateUi(() => _isLoadingAutoSignIn = false);
    }

    await getUserData(sync: true);
    if (user!.role.isDoctor) {
      emitEvent(LoginEvent.navigateToDoctorHome);
    } else {
      emitEvent(LoginEvent.navigateToPatientHome);
    }

    updateUi(() => _isLoadingAutoSignIn = false);
  }
}
