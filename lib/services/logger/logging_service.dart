import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class LoggingService extends Logger {}

final loggerProvider = Provider((ref) {
  return LoggingService();
});
