import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ScheduleRepository {
  /// Creates remotely an [Schedule] and then saves it to the local database;
  ///
  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the created [Schedule];
  Future<Schedule> create(Schedule schedule);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  Future<void> delete(int id);

  /// throws:
  /// - [ApiConnectionException] when the request suffers any connection problems;
  /// - [ApiUnauthorizedException] when the response returns a status of 401 or 403;
  ///
  /// returns:
  /// - the [Schedule] list of the [Doctor] with [doctorId];
  Future<List<Schedule>> getDoctorSchedule(String doctorId);
}

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ScheduleRepositoryImpl(apiService: apiService);
});

final class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({
    required ApiService apiService,
  }) : _api = apiService;

  final ApiService _api;

  @override
  Future<Schedule> create(Schedule schedule) async {
    return await _api.createSchedule(schedule);
  }

  @override
  Future<void> delete(int id) async {
    await _api.deleteSchedule(id);
  }

  @override
  Future<List<Schedule>> getDoctorSchedule(String doctorId) async {
    return await _api.getDoctorSchedule(doctorId);
  }
}
