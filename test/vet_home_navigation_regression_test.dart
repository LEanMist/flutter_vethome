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
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

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

    final save = find.byKey(const ValueKey('appointment-booking-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
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
    expect(find.text(months[tomorrow.month - 1]), findsOneWidget);
    expect(find.text('${tomorrow.year}'), findsOneWidget);
    final appointment = VetRepository.agendamentos(
      pet.id,
    ).singleWhere((item) => item.tipo == 'Consulta');
    expect(find.text(pet.name), findsWidgets);
    final card = find.byKey(
      ValueKey(
        'agenda-appointment-${appointment.data.microsecondsSinceEpoch}-${appointment.tipo}',
      ),
    );
    expect(
      find.ancestor(
        of: card,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label?.contains('Consulta') == true,
        ),
      ),
      findsOneWidget,
    );
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
    expect(find.text(months[date.month - 1]), findsOneWidget);
    expect(find.text('${date.year}'), findsOneWidget);
    expect(find.text(pet.name), findsWidgets);
    final card = find.byKey(
      ValueKey(
        'agenda-appointment-${date.microsecondsSinceEpoch}-Retorno teste',
      ),
    );
    expect(
      find.ancestor(
        of: card,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label?.contains('Retorno teste') == true,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Convênio não mostra abas e retorna pela navegação do sistema', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(builder: (_) => const ConvenioScreen()),
              ),
              child: const Text('Abrir Convênio'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir Convênio'));
    await tester.pumpAndSettle();

    expect(find.byType(ConvenioScreen), findsOneWidget);
    expect(find.byType(VetBottomNav), findsNothing);
    expect(find.byTooltip('Voltar'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Abrir Convênio'), findsOneWidget);
    expect(find.byType(ConvenioScreen), findsNothing);
    expect(tester.takeException(), isNull);
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

    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Pets'),
      300,
    );
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
