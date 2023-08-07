import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/services/api/api_service.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ScheduleRepository {
  Future<(Schedule?, ApiException?)> create(Schedule schedule);

  Future<ApiException?> delete(int id);

  Future<(List<Schedule>?, ApiException?)> getDoctorSchedule(String doctorId);
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
  Future<(Schedule?, ApiException?)> create(Schedule schedule) async {
    return await _api.createSchedule(schedule);
  }

  @override
  Future<ApiException?> delete(int id) async {
    return await _api.deleteSchedule(id);
  }

  @override
  Future<(List<Schedule>?, ApiException?)> getDoctorSchedule(String doctorId) async {
    return await _api.getDoctorSchedule(doctorId);
  }
}
