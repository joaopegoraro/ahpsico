import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/base/base_screen.dart';
import 'package:ahpsico/ui/components/snackbar.dart';
import 'package:ahpsico/ui/components/topbar.dart';
import 'package:ahpsico/ui/login/login_screen.dart';
import 'package:ahpsico/ui/session/card/session_card.dart';
import 'package:ahpsico/ui/session/detail/session_detail.dart';
import 'package:ahpsico/ui/session/list/session_list_model.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.patient,
    required this.navigateBackOnTap,
  });

  static const route = "/sessions";
  static const patientArgsKey = "patient";
  static const navigateBackOnTapArgsKey = "navigateBackOnTap";

  static Map<String, dynamic> buildArgs({
    User? patient,
    bool navigateBackOnTap = false,
  }) {
    return {
      patientArgsKey: patient,
      navigateBackOnTapArgsKey: navigateBackOnTap,
    };
  }

  final User? patient;
  final bool navigateBackOnTap;

  void _onEventEmitted(
    BuildContext context,
    SessionListModel model,
    SessionListEvent event,
  ) {
    switch (event) {
      case SessionListEvent.showSnackbarError:
        AhpsicoSnackbar.showError(context, model.snackbarMessage);
      case SessionListEvent.navigateToLogin:
        context.go(LoginScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      provider: sessionListModelProvider,
      onEventEmitted: _onEventEmitted,
      shouldShowLoading: (context, model) {
        return model.isLoading || model.user == null;
      },
      onCreate: (model) {
        model.fetchScreenData(patientUuid: patient?.uuid);
      },
      topbarBuilder: (context, model) {
        return Topbar(
          title: "Sessões",
          onBackPressed: context.pop,
        );
      },
      bodyBuilder: (context, model) {
        if (model.sessions.isEmpty) {
          return Center(
            child: Text(
              "Nenhuma sessão encontrada",
              style: AhpsicoText.title3Style.copyWith(
                color: AhpsicoColors.dark75,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: model.sessions.length,
          itemBuilder: (context, index) {
            final session = model.sessions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SessionCard(
                session: session,
                isUserDoctor: model.user!.role.isDoctor,
                onTap: (session) {
                  if (navigateBackOnTap) {
                    return context.pop(session);
                  }
                  context.push(SessionDetail.route, extra: session).then(
                    (shouldRefresh) {
                      if (shouldRefresh == true) {
                        model.fetchScreenData(patientUuid: patient?.uuid);
                      }
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
