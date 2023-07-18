import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/base/base_view_model.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

enum AssignmentListEvent {
  showSnackbarError,
  navigateToLogin,
}

final assignmentListModelProvider = ViewModelProviderFactory.create((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final assignmentRepository = ref.watch(assignmentRepositoryProvider);
  return AssignmentListModel(
    authService,
    userRepository,
    assignmentRepository,
  );
});

class AssignmentListModel extends BaseViewModel<AssignmentListEvent> {
  AssignmentListModel(
    super.authService,
    super.userRepository,
    this._assignmentRepository,
  ) : super(
          errorEvent: AssignmentListEvent.showSnackbarError,
          navigateToLoginEvent: AssignmentListEvent.navigateToLogin,
        );

  /* Services */

  final AssignmentRepository _assignmentRepository;

  /* Fields */

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Assignment> _assignments = [];
  List<Assignment> get assignments => _assignments;

  /* Calls */

  Future<void> fetchScreenData() async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _fetchAssignments();
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchAssignments() async {
    try {
      await _assignmentRepository.syncPatientAssignments(user!.uid);
    } on ApiUnauthorizedException catch (_) {
      logout(showError: true);
    } on ApiConnectionException catch (_) {
      showConnectionError();
    }

    _assignments = await _assignmentRepository.getPatientAssignments(user!.uid);
  }
}
