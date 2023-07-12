import 'dart:async';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/services/auth/credentials.dart';
import 'package:ahpsico/services/auth/exceptions.dart';
import 'package:logger/logger.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum LoginEvent {
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
  final logger = Logger();
  return LoginModel(userRepository, authService, logger);
});

class LoginModel extends ViewModel<LoginEvent> {
  LoginModel(
    this._userRepository,
    this._authService,
    this._logger,
  ) {
    _autoSignIn();
  }

  /* Services */

  final UserRepository _userRepository;
  final AuthService _authService;
  final Logger _logger;

  /* Utils */

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.eager,
  );

  static const int timerDuration = 2;

  /* Fields */

  bool _isLoadingSignIn = false;
  bool get isLoadingSignIn => _isLoadingSignIn;

  bool _isLoadingSendingCode = false;
  bool get isLoadingSendindCode => _isLoadingSendingCode;

  bool _isLoadingAutoSignIn = true;
  bool get isLoadingAutoSignIn => _isLoadingAutoSignIn;

  String _phoneNumber = "";
  String get phoneNumber => _phoneNumber;

  bool _isPhoneValid = false;
  bool get isPhoneValid => _isPhoneValid;

  String _verificationCode = "";
  String get verificationCode => _verificationCode;
  bool get isCodeValid => verificationCode.length == 6;

  String _codeVerificationId = "";
  bool get hasCodeBeenSent => _codeVerificationId.isNotEmpty;

  /* Methods */

  Future<bool> cancelCodeVerification() async {
    if (hasCodeBeenSent) {
      updateUi(() {
        _verificationCode = "";
        _codeVerificationId = "";
      });
      return false;
    }
    return true;
  }

  void updateText(String text) {
    if (!isLoadingSignIn && hasCodeBeenSent) {
      _updateCode(verificationCode + text);
    } else if (!isLoadingSendindCode && !hasCodeBeenSent) {
      _updatePhone(_maskPhone(phoneNumber + text));
    }
  }

  void deleteText() {
    if (!isLoadingSignIn && hasCodeBeenSent) {
      _updateCode(verificationCode.substring(0, verificationCode.length - 1));
    } else if (!isLoadingSendindCode && !hasCodeBeenSent) {
      _updatePhone(phoneNumber.substring(0, phoneNumber.length - 1));
    }
  }

  void confirmText() {
    if (!isLoadingSignIn && hasCodeBeenSent && isCodeValid) {
      final phoneCredential = AuthPhoneCredential(
        phoneNumber: phoneNumber,
        verificationId: _codeVerificationId,
        smsCode: _verificationCode,
      );
      signIn(phoneCredential);
    } else if (!isLoadingSendindCode && !hasCodeBeenSent) {
      sendVerificationCode();
    }
  }

  void _updateCode(String code) {
    updateUi(() {
      _verificationCode = verificationCode;
      emitEvent(LoginEvent.updateCodeInputField);
    });
  }

  void _updatePhone(String phoneNumber) {
    updateUi(() {
      _phoneNumber = phoneNumber;
      _validatePhone(_phoneNumber);
      emitEvent(LoginEvent.updatePhoneInputField);
    });
  }

  void _validatePhone(String phoneNumber) {
    final regExp = RegExp(AppConstants.phoneRegex);
    _isPhoneValid = regExp.hasMatch(phoneNumber);
  }

  String _maskPhone(String phoneNumber) {
    return _phoneMaskFormatter.maskText(phoneNumber);
  }

  /* Calls */

  Future<void> sendVerificationCode() async {
    updateUi(() => _isLoadingSendingCode = true);

    await _authService.sendPhoneVerificationCode(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        updateUi(() {
          emitEvent(LoginEvent.startCodeTimer);
          _isLoadingSendingCode = false;
          _codeVerificationId = verificationId;
        });
      },
      onFailed: (err) {
        if (err is! AuthAutoRetrievalFailedException) {
          updateUi(() => _isLoadingSendingCode = false);
          showSnackbar(
            "Ocorreu um erro desconhecido ao tentar enviar um SMS para o seu telefone. Tente novamente mais tarde ou entre em contato com o desenvolvedor",
            LoginEvent.showSnackbarError,
          );
          _logger.e("An error ocurred while trying to send a verification code to $phoneNumber", err);
        }
      },
      onAutoRetrievalCompleted: (credential) {
        updateUi(() => _verificationCode = credential.smsCode);
        signIn(credential);
      },
    );
  }

  Future<void> signIn(AuthPhoneCredential phoneCredential) async {
    updateUi(() => _isLoadingSignIn = true);
    try {
      await _authService.signInWithCredential(phoneCredential);
      await _userRepository.sync();
      final user = await _userRepository.get();
      showSnackbar("Login bem sucedido!", LoginEvent.showSnackbarMessage);
      if (user.isDoctor) {
        emitEvent(LoginEvent.navigateToDoctorHome);
      } else {
        emitEvent(LoginEvent.navigateToPatientHome);
      }
    } on DatabaseNotFoundException catch (_) {
      emitEvent(LoginEvent.navigateToSignUp);
    } on ApiUserNotRegisteredException catch (_) {
      emitEvent(LoginEvent.navigateToSignUp);
    } on AuthInvalidSignInCodeException catch (_) {
      showSnackbar(
        "O código digitado não é válido. Certifique-se de que o código informado é o mesmo código de seis dígitos recebido por SMS",
        LoginEvent.showSnackbarError,
      );
    } on AuthException catch (err) {
      showSnackbar(
        "Ocorreu um erro desconhecido ao tentar validar o código por SMS. Por favor, tente novamente mais tarde ou entre em contato com o desenvolvedor.",
        LoginEvent.showSnackbarError,
      );
      _logger.e(
        "An error ocurred while trying to validate a verification code to $phoneNumber (validation code: $verificationCode)",
        err,
      );
    } on ApiTimeoutException catch (_) {
      showSnackbar(
        "Ocorreu um erro ao tentar se conectar ao servidor. Por favor, tente novamente mais tarde ou entre em contato com o desenvolvedor.",
        LoginEvent.showSnackbarError,
      );
    } on ApiConnectionException catch (_) {
      showSnackbar(
        "Ocorreu um erro ao tentar se conectar ao servidor. Certifique-se de que seu dispositivo esteja conectado corretamente com a internet",
        LoginEvent.showSnackbarError,
      );
    } on ApiException catch (err) {
      showSnackbar(
        "Ocorreu um erro desconhecido ao tentar fazer login. Tente novamente mais tarde ou entre em contato com o desenvolvedor",
        LoginEvent.showSnackbarError,
      );
      _logger.e("An error ocurred while trying to login with the following phone credential $phoneCredential", err);
    }
    updateUi(() => _isLoadingSignIn = true);
  }

  Future<void> _autoSignIn() async {
    updateUi(() => _isLoadingAutoSignIn = true);

    final token = await _authService.getUserToken();

    final isUserAuthenticated = token?.idToken.isNotEmpty == true;
    if (!isUserAuthenticated) return updateUi(() => _isLoadingAutoSignIn = false);

    try {
      final user = await _userRepository.get();
      if (user.isDoctor) {
        emitEvent(LoginEvent.navigateToDoctorHome);
      } else {
        emitEvent(LoginEvent.navigateToPatientHome);
      }
    } on DatabaseNotFoundException catch (_) {
      emitEvent(LoginEvent.navigateToSignUp);
    }

    updateUi(() => _isLoadingAutoSignIn = false);
  }
}