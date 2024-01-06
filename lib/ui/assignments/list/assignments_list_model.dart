import 'package:ahpsico/data/repositories/assignment_repository.dart';
import 'package:ahpsico/data/repositories/preferences_repository.dart';
import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/assignment.dart';
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
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return AssignmentListModel(
    authService,
    userRepository,
    preferencesRepository,
    assignmentRepository,
  );
});

class AssignmentListModel extends BaseViewModel<AssignmentListEvent> {
  AssignmentListModel(
    super.authService,
    super.userRepository,
    super.preferencesRepository,
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

  Future<void> fetchScreenData({required int? patientId}) async {
    updateUi(() => _isLoading = true);
    await getUserData();
    await _fetchAssignments(patientId: patientId);
    updateUi(() => _isLoading = false);
  }

  Future<void> _fetchAssignments({required int? patientId}) async {
    final err = await _assignmentRepository.syncPatientAssignments(
      patientId ?? user!.id,
    );
    if (err != null) {
      await handleDefaultErrors(err, shouldShowConnectionError: false);
    }

    _assignments = await _assignmentRepository.getPatientAssignments(
      patientId ?? user!.id,
    );
  }
}
