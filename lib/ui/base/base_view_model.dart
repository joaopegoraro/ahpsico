import 'package:ahpsico/data/database/exceptions.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
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

  User? _user;
  User? get user => _user;

  @protected
  set user(User? user) {
    _user = user;
  }

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
  Future<void> getUserData({bool sync = false}) async {
    if (sync) {
      try {
        await userRepository.sync();
      } on ApiUnauthorizedException catch (_) {
        logout(showError: true);
      } on ApiConnectionException catch (_) {
        showConnectionError();
      }
    }

    try {
      _user = await userRepository.get();
    } on DatabaseNotFoundException catch (_) {
      await logout(showError: true);
    }
  }

  @protected
  void showConnectionError() {
    showSnackbar(
      "Ocorreu um erro ao tentar se conectar ao servidor. Certifique-se de que seu dispositivo esteja conectado corretamente com a internet",
      errorEvent,
    );
  }
}
