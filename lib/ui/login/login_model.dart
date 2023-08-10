import 'dart:async';

import 'package:ahpsico/constants/app_constants.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/services/api/errors.dart';
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

  bool _hasCodeBeenSent = false;
  bool get hasCodeBeenSent => _hasCodeBeenSent;

  /* Methods */

  Future<bool> cancelCodeVerification() async {
    if (hasCodeBeenSent) {
      updateUi(() {
        _verificationCode = "";
        _hasCodeBeenSent = false;
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

    final err = await authService.sendVerificationCode(unmaskedPhone);
    if (err != null) {
      await handleDefaultErrors(
        err,
        defaultErrorMessage: "Ocorreu um erro ao tentar enviar um SMS para o seu telefone. "
            "Tente novamente mais tarde ou entre em contato com o desenvolvedor",
      );
      return updateUi(() => _isLoadingSendingCode = false);
    }

    return updateUi(() {
      emitEvent(LoginEvent.startCodeTimer);
      _isLoadingSendingCode = false;
      _hasCodeBeenSent = true;
    });
  }

  Future<void> _signIn(String phoneNumber, String code) async {
    updateUi(() => _isLoadingSignIn = true);
    final unmaskedPhone = "+55${MaskFormatters.phoneMaskFormatter.unmaskText(phoneNumber)}";
    var (user, err) = await authService.login(unmaskedPhone, code);
    if (err != null) {
      if (err is ApiUserNotRegisteredError) {
        emitEvent(LoginEvent.navigateToSignUp);
      } else if (err is ApiBadRequestError) {
        showSnackbar(
          "O código informado não está correto",
          LoginEvent.showSnackbarError,
        );
      } else {
        await handleDefaultErrors(err);
      }
      return updateUi(() => _isLoadingSignIn = false);
    }

    err = await userRepository.sync(user!.uuid);
    if (err != null) {
      await handleDefaultErrors(err);
      return updateUi(() => _isLoadingSignIn = false);
    }

    await preferencesRepository.saveUuid(user.uuid);

    showSnackbar("Login bem sucedido!", LoginEvent.showSnackbarMessage);
    if (user.role.isDoctor) {
      emitEvent(LoginEvent.navigateToDoctorHome);
    } else {
      emitEvent(LoginEvent.navigateToPatientHome);
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

    await getUserData(sync: true, showConnectionError: true);
    if (user!.role.isDoctor) {
      emitEvent(LoginEvent.navigateToDoctorHome);
    } else {
      emitEvent(LoginEvent.navigateToPatientHome);
    }

    updateUi(() => _isLoadingAutoSignIn = false);
  }
}
