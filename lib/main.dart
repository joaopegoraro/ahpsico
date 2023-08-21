import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

import 'package:ahpsico/data/database/ahpsico_database.dart';
import 'package:ahpsico/ui/app/app.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show a progress indicator while awaiting things
  runApp(
    const MaterialApp(
      home: Scaffold(
        backgroundColor: AhpsicoColors.violet,
        body: Center(
          child: CircularProgressIndicator(
            color: AhpsicoColors.light80,
          ),
        ),
      ),
    ),
  );

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await initializeDateFormatting(await findSystemLocale(), null);

  final database = await AhpsicoDatabase.instance;

  runApp(
    ProviderScope(
      overrides: [
        ahpsicoDatabaseProvider.overrideWithValue(database),
      ],
      child: const AhpsicoApp(),
    ),
  );
}
