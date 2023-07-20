import 'package:ahpsico/models/advice.dart';
import 'package:ahpsico/models/assignment/assignment.dart';
import 'package:ahpsico/models/assignment/assignment_status.dart';
import 'package:ahpsico/models/doctor.dart';
import 'package:ahpsico/models/invite.dart';
import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/models/schedule.dart';
import 'package:ahpsico/models/session/session.dart';
import 'package:ahpsico/models/session/session_status.dart';
import 'package:ahpsico/models/session/session_type.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/ui/app/router.dart';
import 'package:ahpsico/ui/app/theme/theme.dart';
import 'package:flutter/material.dart';

class AhpsicoApp extends StatelessWidget {
  const AhpsicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ahpsico',
      theme: AhpsicoTheme.themeData,
      routerConfig: AhpsicoRouter.router,
    );
  }
}

const mockUser = User(
  uid: 'some uuid',
  name: "Andréa Hahmeyer Pegoraro",
  phoneNumber: '99999999999',
  isDoctor: false,
);

const mockDoctor = Doctor(
  uuid: 'some uuid',
  name: "Andréa Hahmeyer Pegoraro",
  phoneNumber: '99999999999',
  description: "Psicólogo de família com mais de 10 anos de experiência",
  crp: "983928392-232",
  pixKey: 'marcos@gmail.com',
  paymentDetails: "088553-2 Itaú - Andréa Hahmeyer Pegoraro",
);

const mockPatient = Patient(
  uuid: 'oms euid',
  name: "Andréa Pegoraro",
  phoneNumber: '99999999999',
);

final mockInvite = Invite(
  id: 0,
  doctor: mockDoctor,
  patientId: mockPatient.uuid,
  phoneNumber: mockPatient.phoneNumber,
);

final mockAdvices = <Advice>[
  Advice(
    id: 0,
    message: "Não ligue para o que os outros pensam. A única coisa que importa é você!",
    doctor: mockDoctor,
    patientIds: [mockPatient.uuid],
  ),
  Advice(
    id: 1,
    message: "Cuide dos outros como gostaria de ser cuidado",
    doctor: mockDoctor,
    patientIds: [mockPatient.uuid],
  ),
  Advice(
    id: 3,
    message: "Não espere dos outros o que não esperaria de você mesmo",
    doctor: mockDoctor,
    patientIds: [mockPatient.uuid],
  ),
  Advice(
    id: 4,
    message:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    doctor: mockDoctor,
    patientIds: [mockPatient.uuid],
  ),
];

final mockAssignments = <Assignment>[
  Assignment(
    id: 0,
    title: "Tarefa da semana",
    description: "Escreva 10 qualidades suas, e 10 defeitos",
    doctor: mockDoctor,
    patientId: mockPatient.uuid,
    status: AssignmentStatus.pending,
    deliverySession: mockSessions.first,
  ),
  Assignment(
    id: 1,
    title: "Tarefa do mês",
    description: "Converse com 3 pessoas no seu trabalho",
    doctor: mockDoctor,
    patientId: mockPatient.uuid,
    status: AssignmentStatus.pending,
    deliverySession: mockSessions.last,
  ),
  Assignment(
    id: 2,
    title: "Para próxima sessão, não esquecer de entregar!",
    description: "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais"
        "Tente praticar o método de respiração quando sentir vontade de comer demais",
    doctor: mockDoctor,
    patientId: mockPatient.uuid,
    status: AssignmentStatus.pending,
    deliverySession: mockSessions.last,
  ),
];

final mockSchedules = List.generate(30, (index) {
  final now = DateTime.now();
  final hours = Duration(hours: index);
  return Schedule(
    id: index,
    doctorUuid: mockDoctor.uuid,
    date: index % 2 == 0 ? now.add(hours) : now.subtract(hours),
    isSession: index % 2 == 0,
  );
});

final mockSessions = <Session>[
  Session(
    id: 0,
    doctor: mockDoctor,
    patient: mockPatient.copyWith(name: "Janaína Gomes"),
    groupIndex: 0,
    status: SessionStatus.confirmed,
    type: SessionType.individual,
    date: DateTime.now().add(const Duration(days: 1)),
  ),
  Session(
    id: 4,
    doctor: mockDoctor,
    patient: mockPatient.copyWith(name: "Carlos Marques"),
    groupIndex: 0,
    status: SessionStatus.confirmed,
    type: SessionType.individual,
    date: DateTime.now().add(const Duration(days: 1, hours: 2)),
  ),
  Session(
    id: 5,
    doctor: mockDoctor,
    patient: mockPatient.copyWith(name: "Ana Silveira"),
    groupIndex: 0,
    status: SessionStatus.concluded,
    type: SessionType.individual,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
  Session(
    id: 6,
    doctor: mockDoctor,
    patient: mockPatient.copyWith(name: "Júlio Mariano"),
    groupIndex: 0,
    status: SessionStatus.notConfirmed,
    type: SessionType.individual,
    date: DateTime.now().add(const Duration(days: 1, hours: 4)),
  ),
  Session(
    id: 6,
    doctor: mockDoctor,
    patient: mockPatient.copyWith(name: "Carol Andrade"),
    groupIndex: 3,
    status: SessionStatus.canceled,
    type: SessionType.monthly,
    date: DateTime.now().add(const Duration(days: 1, hours: 6)),
  ),
  Session(
    id: 1,
    doctor: mockDoctor,
    patient: mockPatient.copyWith(name: "Túlio Teixeira"),
    groupIndex: 0,
    status: SessionStatus.notConfirmed,
    type: SessionType.individual,
    date: DateTime.now().add(const Duration(days: 7)),
  ),
  Session(
    id: 3,
    doctor: mockDoctor,
    patient: mockPatient.copyWith(name: "Larissa Costa"),
    groupIndex: 0,
    status: SessionStatus.notConfirmed,
    type: SessionType.monthly,
    date: DateTime.now().add(const Duration(days: 12)),
  ),
];
