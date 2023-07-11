import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AssignmentRepository {
  /// Creates remotely an [Assignment] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote creating;
  /// - [DatabaseInsertException] when something goes wrong when inserting
  /// the new [Assignment];
  ///
  /// returns:
  /// - the created [Assignment];
  Future<Assignment> create(Assignment assignment);

  /// throws:
  /// - [ApiException] when something goes wrong with the remote updating;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  ///
  /// returns:
  /// - the updated [Assignment];
  Future<Assignment> update(Assignment assignment);

  /// throws:
  /// - [DatabaseNotFoundException] when something goes wrong when trying to retrieve the
  /// [Assignment] list;
  /// - [DatabaseMappingException] when something goes wrong when converting the
  /// database data to a list of [Assignment] models;
  ///
  /// returns:
  /// - the [Assignment] list of the [Patient] with [patientId];
  Future<List<Assignment>> getPatientAssignments(String patientId);

  /// Fetches from the API the [Assignment] list from the [Doctor] with the provided [uuid]
  /// and saves it in the local database;
  ///
  /// throws:
  /// - [ApiException] when something goes wrong with the remote fethcing;
  /// - [DatabaseInsertException] when something goes wrong when inserting the fetched data;
  Future<void> syncPatientAssignments(String patientId);
}

final assignmentRepositoryProvider = Provider((ref) {
  return AssignmentRepositoryImpl();
});

final class AssignmentRepositoryImpl implements AssignmentRepository {
  
}
