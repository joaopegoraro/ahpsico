import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ScheduleRepository {
  Future<(Schedule?, ApiError?)> create(Schedule schedule);

  Future<ApiError?> delete(int id);

  Future<(List<Schedule>?, ApiError?)> getDoctorSchedule(String doctorId);
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
  Future<(Schedule?, ApiError?)> create(Schedule schedule) async {
    return await _api.createSchedule(schedule);
  }

  @override
  Future<ApiError?> delete(int id) async {
    return await _api.deleteSchedule(id);
  }

  @override
  Future<(List<Schedule>?, ApiError?)> getDoctorSchedule(String doctorId) async {
    return await _api.getDoctorSchedule(doctorId);
  }
}
