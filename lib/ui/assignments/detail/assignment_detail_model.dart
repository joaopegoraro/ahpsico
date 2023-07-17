import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/app/app.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum AssignmentDetailEvent {
  showSnackbarError,
  navigateToLogin,
}

final assignmentDetailModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final assignmentRepository = ref.watch(assignmentRepositoryProvider);
  return AssignmentDetailModel(
    authService,
    userRepository,
    assignmentRepository,
  );
});

class AssignmentDetailModel extends BaseViewModel<AssignmentDetailEvent> {
  AssignmentDetailModel(
    super.authService,
    super.userRepository,
    this._assignmentRepository,
  ) : super(
          errorEvent: AssignmentDetailEvent.showSnackbarError,
          navigateToLoginEvent: AssignmentDetailEvent.navigateToLogin,
        );

  /* Services */

  final AssignmentRepository _assignmentRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    // TODO REMOTE THIS BLOCK
    user = mockUser.copyWith(isDoctor: false);
    return updateUi(() => _isLoading = false);
    // TODO REMOVING BLOCK ENDS HERE
    await getUserData();
    updateUi(() => _isLoading = false);
  }
}
