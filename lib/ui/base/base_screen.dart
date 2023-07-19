import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_riverpod/mvvm_riverpod.dart';

class BaseScreen<VM extends ViewModel<EVENT>, EVENT> extends StatelessWidget {
  const BaseScreen({
    super.key,
    required this.provider,
    required this.onEventEmitted,
    this.onCreate,
    this.onDispose,
    this.onWillPop,
    required this.shouldShowLoading,
    this.fabBuilder,
    required this.topbarBuilder,
    required this.bodyBuilder,
  });

  final ViewModelProvider<VM> provider;
  final Widget Function(BuildContext context, VM value) bodyBuilder;
  final Widget Function(BuildContext context, VM value) topbarBuilder;
  final Widget? Function(BuildContext context, VM value)? fabBuilder;
  final void Function(BuildContext, VM, EVENT)? onEventEmitted;
  final bool Function(BuildContext, VM value) shouldShowLoading;
  final Future<bool> Function(VM value)? onWillPop;
  final void Function(VM)? onCreate;
  final void Function()? onDispose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewModelBuilder<VM, EVENT>(
          provider: provider,
          onEventEmitted: onEventEmitted,
          onDispose: onDispose,
          onCreate: (model) {
            if (onCreate != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => onCreate?.call(model),
              );
            }
          },
          builder: (context, model) {
            if (shouldShowLoading(context, model)) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AhpsicoColors.violet,
                ),
              );
            }
            final fab = fabBuilder?.call(context, model);
            return WillPopScope(
              onWillPop: onWillPop == null ? null : () async => await onWillPop?.call(model) ?? true,
              child: Stack(
                children: [
                  NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return [topbarBuilder(context, model)];
                    },
                    body: bodyBuilder(context, model),
                  ),
                  if (fab != null)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: fab,
                      ),
                    ),
                ],
              ),
            );
          }),
    );
  }
}
