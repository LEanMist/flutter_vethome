import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/widgets/vet_calendar.dart';

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
    await tester.tap(find.byKey(const ValueKey('appointment-booking-date')));
    await tester.pumpAndSettle();

    final firstDate = tester
        .widget<VetCalendar>(find.byType(VetCalendar))
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

  test('data futura após o antigo limite móvel continua aceita', () {
    final before = VetRepository.agendamentos(pet.id).length;
    final dateAfterFormerMobileLimit = DateTime(now.year + 2, 1, 2, 10);

    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: appointment(dateAfterFormerMobileLimit),
        now: now,
      ),
      isTrue,
    );
    expect(VetRepository.agendamentos(pet.id).length, before + 1);
  });

  Agendamento savedAppointment(
    DateTime start,
    DateTime end, {
    String veterinarian = 'Dra. Ana Silva',
  }) => Agendamento(
    data: start,
    endDate: end,
    tipo: 'Consulta salva',
    veterinario: veterinarian,
    local: 'VetHome',
    status: StatusAgendamento.pendente,
  );

  test(
    'não permite sobreposição com outro agendamento do mesmo veterinário',
    () {
      final otherPet = VetRepository.pets.firstWhere(
        (item) => item.id != pet.id,
      );
      final start = DateTime(2098, 2, 3, 13);
      VetRepository.addAgendamento(
        otherPet.id,
        savedAppointment(start, start.add(const Duration(hours: 1))),
      );
      final before = VetRepository.agendamentos(pet.id).length;

      expect(
        tryScheduleAppointment(
          petId: pet.id,
          appointment: savedAppointment(
            start.add(const Duration(minutes: 30)),
            start.add(const Duration(hours: 1, minutes: 30)),
          ),
          now: DateTime.now(),
        ),
        isFalse,
      );
      expect(VetRepository.agendamentos(pet.id).length, before);
    },
  );

  test('não permite sobreposição do mesmo pet mesmo com outro veterinário', () {
    final start = DateTime(2098, 2, 4, 13);
    VetRepository.addAgendamento(
      pet.id,
      savedAppointment(
        start,
        start.add(const Duration(hours: 1)),
        veterinarian: 'Dr. João Mendes',
      ),
    );

    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: savedAppointment(
          start,
          start.add(const Duration(hours: 1)),
        ),
        now: DateTime.now(),
      ),
      isFalse,
    );
  });

  test('permite horários adjacentes', () {
    final start = DateTime(2098, 2, 5, 13);
    VetRepository.addAgendamento(
      pet.id,
      savedAppointment(start, start.add(const Duration(hours: 1))),
    );

    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: savedAppointment(
          start.add(const Duration(hours: 1)),
          start.add(const Duration(hours: 2)),
        ),
        now: DateTime.now(),
      ),
      isTrue,
    );
  });

  test('horário sem fim registrado ocupa uma hora', () {
    final otherPet = VetRepository.pets.firstWhere((item) => item.id != pet.id);
    final start = DateTime(2098, 2, 6, 13);
    VetRepository.addAgendamento(
      otherPet.id,
      Agendamento(
        data: start,
        tipo: 'Consulta antiga',
        veterinario: 'Dra. Ana Silva',
        local: 'VetHome',
        status: StatusAgendamento.confirmado,
      ),
    );

    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: savedAppointment(
          start.add(const Duration(minutes: 30)),
          start.add(const Duration(hours: 1, minutes: 30)),
        ),
        now: DateTime.now(),
      ),
      isFalse,
    );
  });

  test('não trata demonstrações como horários ocupados', () {
    final today = DateTime.now();
    final demoDate = DateTime(today.year, today.month, today.day + 5);
    final demoStart = demoDate.add(const Duration(hours: 14, minutes: 30));
    final demoIsVisible = VetRepository.agendamentos(
      pet.id,
    ).any((item) => item.data == demoStart);

    expect(demoIsVisible, isTrue);
    expect(
      VetRepository.hasAppointmentConflict(
        petId: pet.id,
        veterinarian: 'Dra. Ana Silva',
        start: demoDate.add(const Duration(hours: 14)),
        end: demoDate.add(const Duration(hours: 15)),
      ),
      isFalse,
    );
  });

  test('veterinários diferentes em pets diferentes não conflitam', () {
    final otherPet = VetRepository.pets.firstWhere((item) => item.id != pet.id);
    final start = DateTime(2098, 2, 7, 13);
    VetRepository.addAgendamento(
      otherPet.id,
      savedAppointment(
        start,
        start.add(const Duration(hours: 1)),
        veterinarian: 'Dr. João Mendes',
      ),
    );

    expect(
      tryScheduleAppointment(
        petId: pet.id,
        appointment: savedAppointment(
          start,
          start.add(const Duration(hours: 1)),
        ),
        now: DateTime.now(),
      ),
      isTrue,
    );
  });

  testWidgets('seletor desabilita horário ocupado por consulta salva', (
    tester,
  ) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12);
    VetRepository.addAgendamento(
      pet.id,
      savedAppointment(start, start.add(const Duration(hours: 1))),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(
          pet: pet,
          service: 'Consulta',
          plan: 'Particular',
        ),
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('appointment-booking-start-time')),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('time-choice-12')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('time-choice-13')))
          .onPressed,
      isNotNull,
    );
  });
}
