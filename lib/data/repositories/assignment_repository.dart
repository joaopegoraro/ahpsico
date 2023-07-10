import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AssignmentRepository {}

final assignmentRepositoryProvider = Provider((ref) {
  return AssignmentRepositoryImpl();
});

final class AssignmentRepositoryImpl implements AssignmentRepository {}
