import 'package:ahpsico/models/patient.dart';
import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:ahpsico/ui/components/patient_card.dart';
import 'package:ahpsico/utils/extensions.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:flutter/material.dart';

class PatientSearchDelegate extends SearchDelegate<Patient?> {
  PatientSearchDelegate(this.patients);

  final List<Patient> patients;

  @override
  String get searchFieldLabel => 'Pesquisar';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      hintColor: AhpsicoColors.light60,
      textTheme: Theme.of(context).textTheme.copyWith(
            titleLarge: AhpsicoText.title3Style.copyWith(color: AhpsicoColors.light80),
          ),
      appBarTheme: const AppBarTheme(color: AhpsicoColors.violet),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final matchQuery = patients.where((patient) {
      final nameMatches = patient.name.toLowerCase().withoutDiacriticalMarks.contains(
            query.toLowerCase().withoutDiacriticalMarks,
          );
      // as a function so it only executes if nameMatches is false
      phoneMatches() {
        final unmaskedPhone = MaskFormatters.phoneMaskFormatter.unmaskText(patient.phoneNumber);
        if (unmaskedPhone.isEmpty) return false;
        final unmaskedQuery = MaskFormatters.phoneMaskFormatter.unmaskText(query);
        if (unmaskedQuery.isEmpty) return false;
        return unmaskedPhone.contains(MaskFormatters.phoneMaskFormatter.unmaskText(query));
      }

      return nameMatches || phoneMatches();
    });
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final patient = matchQuery.elementAt(index);
        return PatientCard(
          patient: patient,
          onTap: (patient) => close(context, patient),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
