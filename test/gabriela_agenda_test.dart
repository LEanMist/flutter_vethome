import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_calendar_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_agenda_tab.dart';

void main() {
  testWidgets(
    'inicia hoje e navega por mês mesmo com consulta local do Cliente',
    (tester) async {
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({});
        await VetRepository.initialize();
        final pet = VetRepository.pets.first;
        final today = DateUtils.dateOnly(DateTime.now());
        VetRepository.updateClient(name: 'Tutor do dispositivo');
        VetRepository.addAgendamento(
          pet.id,
          Agendamento(
            data: today.add(const Duration(hours: 11)),
            tipo: 'Exame privado do Cliente',
            veterinario: 'Gabriela',
            local: 'Endereço privado do Cliente',
            status: StatusAgendamento.confirmado,
          ),
        );
        expect(await VetRepository.flush(), isTrue);
        expect(VetRepository.realAppointments(pet.id), hasLength(1));
      });

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GabrielaAgendaTab())),
      );
      final picker = find.byType(GabrielaCalendarPicker);
      final today = DateUtils.dateOnly(DateTime.now());
      expect(tester.widget<GabrielaCalendarPicker>(picker).selectedDate, today);
      expect(find.text('Nenhum agendamento para este dia.'), findsOneWidget);
      expect(find.text('Tutor do dispositivo'), findsNothing);
      expect(find.text('Exame privado do Cliente'), findsNothing);
      expect(find.text('Endereço privado do Cliente'), findsNothing);

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();
      final nextMonth = DateTime(today.year, today.month + 1);
      final day = find.descendant(of: picker, matching: find.text('15')).first;
      await tester.tap(day);
      await tester.pumpAndSettle();
      expect(
        tester.widget<GabrielaCalendarPicker>(picker).selectedDate,
        DateTime(nextMonth.year, nextMonth.month, 15),
      );
      expect(find.text('Exame privado do Cliente'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('consulta distingue cliente Rambo do pet Fernando', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GabrielaAgendaTab())),
    );

    final examples = find.text('Ver exemplos de 10/03/2026');
    await tester.ensureVisible(examples);
    await tester.tap(examples);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Rambo Augusto'));
    await tester.tap(find.text('Rambo Augusto'));
    await tester.pumpAndSettle();
    final dialog = find.byType(Dialog);
    Finder inDialog(String text) =>
        find.descendant(of: dialog, matching: find.text(text));
    expect(inDialog('Consulta demonstrativa'), findsOneWidget);
    expect(inDialog('Rambo'), findsOneWidget);
    expect(inDialog('Fernando'), findsOneWidget);
    expect(find.bySemanticsLabel('Foto de Fernando'), findsOneWidget);
    for (final field in [
      'Gênero/Sexo',
      'Peso',
      'Data de Nascimento',
      'Raça',
      'M',
      '24kg',
      '23 / 03 / 2012',
      'Lulu-da-Pomerânia',
      'Hemograma + 3',
      'R. Augusto Cury 123 - Vila Osasco',
    ]) {
      expect(inDialog(field), findsOneWidget);
    }
    Navigator.of(tester.element(inDialog('Fernando'))).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Nicolly Santos'));
    await tester.tap(find.text('Nicolly Santos'));
    await tester.pumpAndSettle();
    expect(inDialog('Consulta demonstrativa'), findsOneWidget);
    expect(inDialog('Sem foto'), findsOneWidget);
    expect(inDialog('Fernando'), findsNothing);
    expect(inDialog('Lulu-da-Pomerânia'), findsNothing);
    expect(inDialog('24kg'), findsNothing);
    expect(find.bySemanticsLabel('Foto de Fernando'), findsNothing);
    semantics.dispose();
  });
}
