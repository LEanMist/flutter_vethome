import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';

void main() {
  final current = DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final now = today.add(const Duration(hours: 12));
  final pet = VetRepository.pets.first;

  Agendamento appointment(DateTime date) => Agendamento(
    data: date,
    tipo: 'Validação de horário',
    veterinario: 'Teste',
    local: 'Teste',
    status: StatusAgendamento.pendente,
  );

  testWidgets('seletor de data não disponibiliza dias anteriores a hoje', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(
          pet: pet,
          service: 'Consulta',
          plan: 'Particular',
        ),
      ),
    );
    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();

    final firstDate = tester
        .widget<DatePickerDialog>(find.byType(DatePickerDialog))
        .firstDate;
    final actualNow = DateTime.now();
    expect(firstDate, DateTime(actualNow.year, actualNow.month, actualNow.day));
  });

  test('ontem é rejeitado sem criar agendamento', () {
    final before = VetRepository.agendamentos(pet.id).length;
    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: appointment(today.subtract(const Duration(days: 1))),
        now: now,
      ),
      isFalse,
    );
    expect(VetRepository.agendamentos(pet.id).length, before);
  });

  test('hoje em horário passado é rejeitado sem criar agendamento', () {
    final before = VetRepository.agendamentos(pet.id).length;
    expect(
      isFutureAppointmentTime(today.add(const Duration(hours: 11)), now),
      isFalse,
    );
    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: appointment(today.add(const Duration(hours: 11))),
        now: now,
      ),
      isFalse,
    );
    expect(VetRepository.agendamentos(pet.id).length, before);
  });

  test('hoje em horário futuro é aceito', () {
    final before = VetRepository.agendamentos(pet.id).length;
    expect(
      isFutureAppointmentTime(today.add(const Duration(hours: 13)), now),
      isTrue,
    );
    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: appointment(today.add(const Duration(hours: 13))),
        now: now,
      ),
      isTrue,
    );
    expect(VetRepository.agendamentos(pet.id).length, before + 1);
  });

  test('amanhã é aceito', () {
    final before = VetRepository.agendamentos(pet.id).length;
    expect(
      isFutureAppointmentTime(
        today.add(const Duration(days: 1, hours: 11)),
        now,
      ),
      isTrue,
    );
    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: appointment(today.add(const Duration(days: 1))),
        now: now,
      ),
      isTrue,
    );
    expect(VetRepository.agendamentos(pet.id).length, before + 1);
  });
}
