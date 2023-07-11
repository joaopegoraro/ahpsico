import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum LoginEvent {
  nothing,
}

final loginModelProvider = ViewModelProviderFactory.create((ref) {
  return LoginModel();
});

class LoginModel extends ViewModel<LoginEvent> {}
