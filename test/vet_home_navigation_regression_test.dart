import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/core/utils/vet_nav.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/editar_pet_page.dart';
import 'package:flutter_vethome/pages/home_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/cadastroPet_page.dart';
import 'package:flutter_vethome/pages/teste_page.dart';
import 'package:flutter_vethome/screens/outros.dart';
import 'package:flutter_vethome/screens/pets.dart'
    show ConvenioScreen, ServicosScreen;
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

Widget agendaRoute(BuildContext context) {
  final date = ModalRoute.of(context)?.settings.arguments as DateTime?;
  return AgendaScreen(initialDate: date);
}

void main() {
  testWidgets('Home permite trocar para as abas principais', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const HomePage(),
        routes: {
          '/chat': (_) => const Scaffold(body: Text('Conversa destino')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VetBottomNav), findsOneWidget);
    final chatTab = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == 'Conversa',
    );
    expect(chatTab, findsOneWidget);
    await tester.tap(chatTab);
    await tester.pumpAndSettle();

    expect(find.text('Conversa destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadastro interno de pet permite trocar de tela com proteção', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const CadastroPetScreen(initialData: {'flow': 'addPet'}),
        routes: {
          '/config': (_) => const Scaffold(body: Text('Config destino')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VetBottomNav), findsOneWidget);
    final settingsTab = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Configurações',
    );
    await tester.tap(settingsTab);
    await tester.pumpAndSettle();
    expect(find.text('Sair do cadastro?'), findsOneWidget);
    await tester.tap(find.text('Continuar editando'));
    await tester.pumpAndSettle();
    expect(find.byType(CadastroPetScreen), findsOneWidget);

    await tester.tap(settingsTab);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair sem salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Config destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
    final compactConfirm = find.byKey(
      const ValueKey('appointment-booking-compact-confirm'),
    );
    final confirm = save.evaluate().isNotEmpty ? save : compactConfirm;
    expect(confirm, findsOneWidget);
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
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

  testWidgets('Convênio permite trocar de tela pela navegação global', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousPetId = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousPetId);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(
      MaterialApp(
        home: const ConvenioScreen(service: 'Hemograma'),
        routes: {'/pets': (_) => const Scaffold(body: Text('Pets destino'))},
      ),
    );

    expect(find.byType(ConvenioScreen), findsOneWidget);
    expect(find.byType(VetBottomNav), findsOneWidget);
    final petsTab = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == 'Pets',
    );
    expect(petsTab, findsOneWidget);
    await tester.tap(petsTab);
    await tester.pumpAndSettle();
    expect(find.text('Sair do agendamento?'), findsOneWidget);
    await tester.tap(find.text('Continuar editando'));
    await tester.pumpAndSettle();
    expect(find.byType(ConvenioScreen), findsOneWidget);

    await tester.tap(petsTab);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair sem salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Pets destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Serviços permite trocar de tela sem salvar a seleção', (
    tester,
  ) async {
    final previousPetId = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = previousPetId);
    VetRepository.selectedPetId = VetRepository.pets.first.id;

    await tester.pumpWidget(
      MaterialApp(
        home: const ServicosScreen(),
        routes: {
          '/config': (_) => const Scaffold(body: Text('Config destino')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VetBottomNav), findsOneWidget);
    final settingsTab = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Configurações',
    );
    expect(settingsTab, findsOneWidget);
    await tester.tap(settingsTab);
    await tester.pumpAndSettle();

    expect(find.text('Config destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Serviços protege escolhas ainda não enviadas ao trocar de tela',
    (tester) async {
      final previousPetId = VetRepository.selectedPetId;
      addTearDown(() => VetRepository.selectedPetId = previousPetId);
      VetRepository.selectedPetId = VetRepository.pets.first.id;

      await tester.pumpWidget(
        MaterialApp(
          home: const ServicosScreen(),
          routes: {
            '/config': (_) => const Scaffold(body: Text('Config destino')),
          },
        ),
      );
      await tester.pumpAndSettle();

      final hemograma = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Hemograma',
      );
      await tester.tap(hemograma);
      await tester.pumpAndSettle();
      final settingsTab = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Configurações',
      );
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();
      expect(find.text('Descartar serviços?'), findsOneWidget);

      await tester.tap(find.text('Continuar editando'));
      await tester.pumpAndSettle();
      expect(find.byType(ServicosScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Hemograma' &&
              widget.properties.checked == true,
        ),
        findsOneWidget,
      );

      await tester.tap(settingsTab);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair sem salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Config destino'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

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

  testWidgets('edição de pet permite trocar de tela com proteção', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EditarPetPage(pet: VetRepository.pets.first),
        routes: {
          '/config': (_) => const Scaffold(body: Text('Config destino')),
        },
      ),
    );
    await tester.pumpAndSettle();

    final settingsTab = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Configurações',
    );
    expect(find.byType(VetBottomNav), findsOneWidget);
    await tester.tap(settingsTab);
    await tester.pumpAndSettle();
    expect(find.text('Sair da edição?'), findsOneWidget);

    await tester.tap(find.text('Continuar editando'));
    await tester.pumpAndSettle();
    expect(find.byType(EditarPetPage), findsOneWidget);

    await tester.tap(settingsTab);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair sem salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Config destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor modal de pet oferece troca de tela protegida', (
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
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) =>
                    EditarPetPage(pet: VetRepository.pets.first, modal: true),
              ),
              child: const Text('Abrir edição'),
            ),
          ),
        ),
        routes: {
          '/agenda': (_) => const Scaffold(body: Text('Agenda destino')),
        },
      ),
    );
    await tester.tap(find.text('Abrir edição'));
    await tester.pumpAndSettle();

    final routeMenu = find.byKey(const ValueKey('pet-edit-modal-route-menu'));
    expect(routeMenu, findsOneWidget);
    await tester.tap(routeMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agenda').last);
    await tester.pumpAndSettle();
    expect(find.text('Sair da edição?'), findsOneWidget);
    await tester.tap(find.text('Sair sem salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Agenda destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
