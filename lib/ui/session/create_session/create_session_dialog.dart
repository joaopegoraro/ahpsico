import 'package:ahpsico/constants/session_payment_type.dart';
import 'package:ahpsico/constants/session_type.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/spacing.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/input_field.dart';
import 'package:ahpsico/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateSessionDialog extends StatefulWidget {
  const CreateSessionDialog({
    super.key,
    required this.dateTime,
    required this.onConfirm,
  });

  final DateTime dateTime;
  final void Function(
    String? message,
    SessionPaymentType paymentType,
    SessionType sessionType,
  ) onConfirm;

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  bool _showMessageTextfield = false;
  String? _message;
  SessionType _sessionType = SessionType.individual;
  SessionPaymentType _paymentType = SessionPaymentType.particular;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Aviso"),
      content: Column(
        children: [
          Text(
            "Tem certeza que deseja agendar uma sessão para "
            "${TimeUtils.getReadableDate(widget.dateTime)}, "
            "às ${TimeUtils.getDateAsHours(widget.dateTime)}?",
          ),
          AhpsicoSpacing.verticalSpaceMedium,
          const Text(
            "Escolha se a sessão que você está agendando é mensal, ou individual:",
          ),
          AhpsicoSpacing.verticalSpaceSmall,
          DropdownButton(
            value: _sessionType,
            items: const [
              DropdownMenuItem(
                value: SessionType.individual,
                child: Text("Individual"),
              ),
              DropdownMenuItem(
                value: SessionType.monthly,
                child: Text("Mensal"),
              ),
            ],
            onChanged: (newType) => setState(() {
              if (newType != null) _sessionType = newType;
            }),
          ),
          AhpsicoSpacing.verticalSpaceMedium,
          const Text(
            "Escolha a forma de pagamento da sessão:",
          ),
          AhpsicoSpacing.verticalSpaceSmall,
          DropdownButton(
            value: _paymentType,
            items: const [
              DropdownMenuItem(
                value: SessionPaymentType.particular,
                child: Text("Particular"),
              ),
              DropdownMenuItem(
                value: SessionPaymentType.healthPlan,
                child: Text("Convênio"),
              ),
              DropdownMenuItem(
                value: SessionPaymentType.clinic,
                child: Text("Clínica"),
              ),
            ],
            onChanged: (newType) => setState(() {
              if (newType != null) _paymentType = newType;
            }),
          ),
          AhpsicoSpacing.verticalSpaceMedium,
          GestureDetector(
            onTap: () => setState(() {
              _showMessageTextfield = !_showMessageTextfield;
            }),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Checkbox(
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: _showMessageTextfield,
                    fillColor: const MaterialStatePropertyAll(
                      AhpsicoColors.violet,
                    ),
                    onChanged: null,
                  ),
                  AhpsicoSpacing.horizontalSpaceSmall,
                  const Text("Anexar mensagem"),
                ],
              ),
            ),
          ),
          if (_showMessageTextfield) ...[
            AhpsicoSpacing.verticalSpaceSmall,
            AhpsicoInputField(
              minLines: 3,
              maxLenght: 200,
              textAlign: TextAlign.start,
              onChanged: (message) => _message = message,
              hint: "Digite a mensagem",
            ),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => widget.onConfirm(
            _message,
            _paymentType,
            _sessionType,
          ),
          child: Text(
            "Confirmar",
            textAlign: TextAlign.end,
            style:
                AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
        TextButton(
          onPressed: context.pop,
          child: Text(
            "Cancelar",
            textAlign: TextAlign.end,
            style:
                AhpsicoText.regular1Style.copyWith(color: AhpsicoColors.violet),
          ),
        ),
      ],
    );
  }
}
