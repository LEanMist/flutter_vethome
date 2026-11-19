import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';

class _FixtureStorage extends LocalStorage {
  _FixtureStorage(this.result);

  final LocalLoadResult result;

  @override
  Future<LocalLoadResult> load() async => result;

  @override
  Future<void> save(LocalState state) async {}
}

void main() {
  testWidgets('divisórias da Agenda longa permanecem entre os cartões', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final selectedDate = DateTime(2026, 1, 13);
    final pets = VetRepository.pets.toList();
    final petId = pets.first.id;
    final appointments = List.generate(
      16,
      (index) => Agendamento(
        data: selectedDate.add(Duration(hours: index)),
        tipo: 'Consulta real $index',
        veterinario: 'Dra. Exemplo',
        local: 'Clínica VetHome',
        status: StatusAgendamento.confirmado,
      ),
    );
    await VetRepository.initialize(
      storage: _FixtureStorage(
        LocalLoadResult.valid(
          LocalState(
            client: ClientData(
              name: 'Teste',
              birthDate: DateTime(2000, 1, 1),
              address: '',
              phone: '',
              email: '',
              gender: '',
            ),
            pets: pets,
            appointments: {petId: appointments},
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: AgendaScreen(initialDate: selectedDate)),
    );
    await tester.pumpAndSettle();

    final cards = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell &&
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'agenda-appointment-',
          ),
    );
    expect(cards, findsNWidgets(19));
    for (var index = 0; index < 18; index++) {
      final divider = tester.getRect(
        find.byKey(ValueKey('agenda-divider-$index')),
      );
      final followingCard = tester.getRect(cards.at(index + 1));
      expect(
        divider.bottom,
        lessThanOrEqualTo(followingCard.top),
        reason: 'Divisória $index não deve cobrir o cartão ${index + 1}',
      );
    }
    expect(tester.takeException(), isNull);
  });
}
