import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

abstract class BaseViewModel<T> extends ViewModel<T> {
  BaseViewModel(
    this.authService,
    this.userRepository, {
    this.messageEvent,
    required this.errorEvent,
    required this.navigateToLoginEvent,
  });

  @protected
  final AuthService authService;

  @protected
  final UserRepository userRepository;

  @protected
  final T errorEvent;

  @protected
  final T? messageEvent;

  @protected
  final T navigateToLoginEvent;

  @protected
  Future<void> logout({bool showError = false}) async {
    await userRepository.clear();
    await authService.signOut();
    if (showError) {
      showSnackbar("Sua sessão expirou!", errorEvent);
    } else if (messageEvent != null) {
      showSnackbar("Logout bem sucedido!", messageEvent as T);
    }
    emitEvent(navigateToLoginEvent);
  }

  @protected
  void showConnectionError() {
    showSnackbar(
      "Ocorreu um erro ao tentar se conectar ao servidor. Certifique-se de que seu dispositivo esteja conectado corretamente com a internet",
      errorEvent,
    );
  }
}
