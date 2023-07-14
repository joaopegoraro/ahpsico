import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum DoctorHomeEvent {
  nothing,
}

final doctorHomeModelProvider = ViewModelProviderFactory.create((ref) {
  return DoctorHomeModel();
});

class DoctorHomeModel extends ViewModel<DoctorHomeEvent> {}
