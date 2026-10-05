import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/core/utils/vet_nav.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/teste_page.dart';
import 'package:flutter_vethome/screens/outros.dart';
import 'package:flutter_vethome/screens/pets.dart' show ConvenioScreen;

Widget agendaRoute(BuildContext context) {
  final date = ModalRoute.of(context)?.settings.arguments as DateTime?;
  return AgendaScreen(initialDate: date);
}

void main() {
  testWidgets('novo agendamento abre Agenda na data marcada', (tester) async {
    final pet = VetRepository.pets.first;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(
          pet: pet,
          service: 'Consulta',
          plan: 'Particular',
        ),
        routes: {'/agenda': agendaRoute},
      ),
    );

    await tester.ensureVisible(find.text('Confirmar agendamento'));
    await tester.tap(find.text('Confirmar agendamento'));
    await tester.pumpAndSettle();

    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    expect(
      find.text('${months[tomorrow.month - 1]} ${tomorrow.year}'),
      findsOneWidget,
    );
    expect(find.text('Consulta'), findsWidgets);
  });

  testWidgets('próximo agendamento do pet abre o mês correspondente', (
    tester,
  ) async {
    final pet = VetRepository.addPet(
      name: 'Pet rota futura',
      species: 'Cão',
      sex: 'Macho',
      weightKg: 10,
      birthDate: DateTime(2020),
      breed: 'SRD',
    );
    addTearDown(() => VetRepository.removePet(pet));
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final date = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12);
    VetRepository.addAgendamento(
      pet.id,
      Agendamento(
        data: date,
        tipo: 'Retorno teste',
        veterinario: 'Teste',
        local: 'Teste',
        status: StatusAgendamento.pendente,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: DetalhesPetPage(pet: pet),
        routes: {'/agenda': agendaRoute},
      ),
    );

    await tester.ensureVisible(find.text('Próximo agendamento'));
    await tester.tap(find.text('Próximo agendamento'));
    await tester.pumpAndSettle();

    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    expect(find.text('${months[date.month - 1]} ${date.year}'), findsOneWidget);
    expect(find.text('Retorno teste'), findsWidgets);
  });

  testWidgets('Pets no rodapé de Convênio navega para a rota Pets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ConvenioScreen(),
        routes: {
          '/pets': (context) =>
              Scaffold(body: Text(ModalRoute.of(context)!.settings.name!)),
        },
      ),
    );

    await tester.tap(find.bySemanticsLabel('Pets'));
    await tester.pumpAndSettle();
    expect(find.text('/pets'), findsOneWidget);
  });

  testWidgets('menu de teste abre Pets e Agenda com rotas nomeadas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const TestePage(),
        routes: {
          '/pets': (context) =>
              Scaffold(body: Text(ModalRoute.of(context)!.settings.name!)),
          '/agenda': (context) =>
              Scaffold(body: Text(ModalRoute.of(context)!.settings.name!)),
        },
      ),
    );

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Pets'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Pets'));
    await tester.pumpAndSettle();
    expect(find.text('/pets'), findsOneWidget);
    Navigator.of(tester.element(find.text('/pets'))).pop();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Agenda'),
      300,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Agenda'));
    await tester.pumpAndSettle();
    expect(find.text('/agenda'), findsOneWidget);
  });

  testWidgets('navegação inferior mantém a rota Web sincronizada', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => vetNavigate(context, 0),
              child: const Text('Abrir Pets'),
            ),
          ),
        ),
        routes: {
          '/pets': (context) =>
              Scaffold(body: Text(ModalRoute.of(context)!.settings.name!)),
        },
      ),
    );

    await tester.tap(find.text('Abrir Pets'));
    await tester.pumpAndSettle();
    expect(find.text('/pets'), findsOneWidget);
  });
}
