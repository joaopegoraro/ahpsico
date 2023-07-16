import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:flutter/material.dart';

class AhpsicoSheet extends StatelessWidget {
  const AhpsicoSheet({
    super.key,
    required this.content,
  });

  final Widget content;

  static void show({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AhpsicoColors.light,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      showDragHandle: true,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}
