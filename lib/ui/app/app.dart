import 'package:ahpsico/ui/app/theme/theme.dart';
import 'package:flutter/material.dart';

class AhpsicoApp extends StatelessWidget {
  const AhpsicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ahpsico',
      theme: AhpsicoTheme.themeData,
      home: const Placeholder(),
    );
  }
}
