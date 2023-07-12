import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

class Countdown extends AnimatedWidget {
  const Countdown({super.key, required this.animation}) : super(listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    return Text(
      '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}',
      style: AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.light80),
    );
  }
}
