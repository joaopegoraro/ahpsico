import 'package:flutter/widgets.dart';

final class AhpsicoSpacing {
  AhpsicoSpacing._();

  // Horizontal Spacing
  /// 5px
  static const Widget horizontalSpaceTiny = SizedBox(width: 5.0);

  /// 10px
  static const Widget horizontalSpaceSmall = SizedBox(width: 10.0);

  /// 18px
  static const Widget horizontalSpaceRegular = SizedBox(width: 18.0);

  /// 25px
  static const Widget horizontalSpaceMedium = SizedBox(width: 25.0);

  /// 50px
  static const Widget horizontalSpaceLarge = SizedBox(width: 50.0);

  // Vertical Spacing
  /// 5px
  static const Widget verticalSpaceTiny = SizedBox(height: 5.0);

  /// 10px
  static const Widget verticalSpaceSmall = SizedBox(height: 10.0);

  /// 18px
  static const Widget verticalSpaceRegular = SizedBox(height: 18.0);

  /// 25px
  static const Widget verticalSpaceMedium = SizedBox(height: 25);

  /// 50px
  static const Widget verticalSpaceLarge = SizedBox(height: 50.0);

  /// 120px
  static const Widget verticalSpaceMassive = SizedBox(height: 120.0);
}
