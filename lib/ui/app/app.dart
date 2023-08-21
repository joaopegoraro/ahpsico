import 'package:ahpsico/ui/app/router.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/app/theme/theme.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class AhpsicoApp extends StatelessWidget {
  const AhpsicoApp({super.key});

  Future<bool> _shouldForceUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 12),
    ));
    try {
      await remoteConfig.fetchAndActivate();
    } on Exception catch (_) {
      return false;
    }
    final forcedUpdate = remoteConfig.getBool("forced_update");
    return forcedUpdate;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ahpsico',
      theme: AhpsicoTheme.themeData,
      routerConfig: AhpsicoRouter.router,
      builder: (context, child) {
        return FutureBuilder(
          future: _shouldForceUpdate(),
          builder: (context, snapshot) {
            final shouldForceUpdate = snapshot.data;

            if (shouldForceUpdate == null) {
              return Scaffold(
                backgroundColor: AhpsicoColors.violet,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Buscando por atualizações",
                        style: AhpsicoText.title3Style.copyWith(
                          color: AhpsicoColors.light80,
                        ),
                      ),
                      AhpsicoSpacing.verticalSpaceLarge,
                      const CircularProgressIndicator(
                        color: AhpsicoColors.light80,
                      ),
                    ],
                  ),
                ),
              );
            }

            return UpgradeAlert(
              navigatorKey: AhpsicoRouter.router.routerDelegate.navigatorKey,
              upgrader: Upgrader(
                languageCode: "pt",
                showIgnore: !shouldForceUpdate,
                showLater: !shouldForceUpdate,
                durationUntilAlertAgain: const Duration(days: 1),
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}
