import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:flutter/material.dart';

final class AhpsicoTheme {
  AhpsicoTheme._();

  static final themeData = ThemeData(
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AhpsicoColors.violet,
    ),
  );
}
