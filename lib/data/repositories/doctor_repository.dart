import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class DoctorRepository {}

final doctorRepositoryProvider = Provider((ref) {
  return DoctorRepositoryImpl();
});

final class DoctorRepositoryImpl implements DoctorRepository {
  
}
