import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum LoginEvent {
  nothing,
}

final loginModelProvider = ViewModelProviderFactory.create((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return LoginModel(userRepository, authService);
});

class LoginModel extends ViewModel<LoginEvent> {
  LoginModel(this._userRepository, this._authService);

  final UserRepository _userRepository;
  final AuthService _authService;
}
