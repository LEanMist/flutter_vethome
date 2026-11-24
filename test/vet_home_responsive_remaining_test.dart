import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/cliente/endereco/addresses_page.dart';
import 'package:flutter_vethome/pages/cliente/consulta/agenda_page.dart';
import 'package:flutter_vethome/pages/cliente/pet/cadastroPet_page.dart';
import 'package:flutter_vethome/pages/cliente/pet/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/chat_page.dart';
import 'package:flutter_vethome/pages/cliente/consulta/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/cliente/perfil_page.dart';
import 'package:flutter_vethome/pages/cliente/pet/pets_page.dart';
import 'package:flutter_vethome/pages/veterinario/sobre_page.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';
import 'package:flutter_vethome/widgets.dart';

Future<void> pumpPage(
  WidgetTester tester,
  Widget page,
  Size size, {
  Map<String, WidgetBuilder> extraRoutes = const {},
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      routes: {
        '/sobre': (_) => const SobreScreen(),
        '/enderecos': (_) => const AddressesPage(),
        ...extraRoutes,
      },
      home: page,
    ),
  );
  await tester.pump();
  final exception = tester.takeException();
  expect(
    exception,
    isNull,
    reason: '${page.runtimeType} em ${size.width}x${size.height}',
  );
}

Future<void> pumpMobileDetails(
  WidgetTester tester,
  Size size, {
  Map<String, WidgetBuilder> routes = const {},
}) async {
  // Evita reaproveitar a pilha de navegação e o estado do widget anterior.
  await tester.pumpWidget(const SizedBox.shrink());
  await pumpPage(
    tester,
    DetalhesPetPage(pet: VetRepository.pets.first),
    size,
    extraRoutes: routes,
  );
}

void main() {
  testWidgets('Cadastro Pet inicial usa a posição de referência uma vez', (
    tester,
  ) async {
    await pumpPage(tester, const CadastroPetScreen(), const Size(390, 844));
    final panel = find.byKey(const ValueKey('pet-registration-panel'));
    expect(tester.getTopLeft(panel), const Offset(49, 139));

    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPadding);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(panel), const Offset(49, 139));
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets(
      'Cadastro Pet pelo + deixa kg visível com Peso vazio em $size',
      (tester) async {
        await pumpPage(
          tester,
          const CadastroPetScreen(initialData: {'flow': 'addPet'}),
          size,
        );
        if (size.width == 390) {
          final panel = find.byKey(const ValueKey('pet-registration-panel'));
          expect(tester.getTopLeft(panel), const Offset(49, 115));
        }
        final weight = find.byWidgetPredicate(
          (widget) => widget is VHField && widget.label == 'Peso',
        );
        final input = find.descendant(
          of: weight,
          matching: find.byType(TextFormField),
        );
        final decorator = find.descendant(
          of: weight,
          matching: find.byType(InputDecorator),
        );
        expect(tester.widget<TextFormField>(input).controller!.text, isEmpty);
        expect(
          tester.widget<InputDecorator>(decorator).decoration.suffixIcon,
          isNotNull,
        );
        final suffix = find.descendant(of: weight, matching: find.text('kg'));
        expect(
          tester.getRect(input).contains(tester.getCenter(suffix)),
          isTrue,
        );
        await tester.enterText(input, '4,2');
        await tester.pumpAndSettle();
        expect(tester.widget<TextFormField>(input).controller!.text, '4,2');
        expect(
          tester.getRect(input).contains(tester.getCenter(suffix)),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Cadastro Pet pela lista mantém o formulário visível em desktop',
    (tester) async {
      await pumpPage(
        tester,
        const PetsPage(),
        const Size(1280, 720),
        extraRoutes: {
          '/cadastroPet': (_) =>
              const CadastroPetScreen(initialData: {'flow': 'addPet'}),
        },
      );
      await tester.tap(find.byKey(const ValueKey('pets-add-target')));
      await tester.pumpAndSettle();

      final navigation = find.byType(VetBottomNav);
      expect(tester.getSize(navigation).height, lessThan(110));
      expect(find.text('Cadastro Pet').hitTestable(), findsOneWidget);
      expect(find.byType(EditableText).hitTestable(), findsWidgets);
      final weightUnit = find.text('kg');
      final weightDecoration = find.ancestor(
        of: weightUnit,
        matching: find.byType(InputDecorator),
      );
      expect(
        tester.widget<InputDecorator>(weightDecoration).decoration.suffixIcon,
        isNotNull,
      );
      final skip = find.text('Pular');
      expect(skip.hitTestable(), findsOneWidget);
      await tester.tap(skip);
      await tester.pumpAndSettle();
      expect(find.byType(PetsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('telas principais não apresentam overflow nas cinco larguras', (
    tester,
  ) async {
    for (final size in const [
      Size(320, 640),
      Size(390, 844),
      Size(768, 1024),
      Size(1280, 800),
      Size(1440, 900),
    ]) {
      await pumpPage(tester, const PetsPage(), size);
      await pumpPage(tester, const AgendaScreen(), size);
      await pumpPage(tester, const ChatScreen(), size);
    }
  });

  testWidgets('desktop ativa grades e composições aprovadas', (tester) async {
    const desktop = Size(1280, 800);
    await pumpPage(tester, const PetsPage(), desktop);
    expect(find.byKey(const ValueKey('pets-desktop-grid')), findsOneWidget);

    await pumpPage(tester, const PerfilPage(), desktop);
    expect(
      find.byKey(const ValueKey('profile-desktop-layout')),
      findsOneWidget,
    );

    await pumpPage(tester, const AgendaScreen(), desktop);
    expect(find.byKey(const ValueKey('agenda-desktop-layout')), findsOneWidget);

    await pumpPage(tester, const ChatScreen(), desktop);
    expect(find.byKey(const ValueKey('chat-desktop-layout')), findsOneWidget);

    await pumpPage(tester, const AddressesPage(), desktop);
    expect(
      find.byKey(const ValueKey('addresses-desktop-grid')),
      findsOneWidget,
    );
  });

  testWidgets('serviços, convênio e consulta preservam argumentos e desktop', (
    tester,
  ) async {
    const desktop = Size(1280, 800);
    final pet = VetRepository.pets.first;
    VetRepository.selectedPetId = pet.id;

    await pumpPage(tester, const ServicosScreen(), desktop);
    expect(
      find.byKey(const ValueKey('services-desktop-layout')),
      findsOneWidget,
    );

    await pumpPage(
      tester,
      NovaConsultaPage(pet: pet, service: 'Hemograma', plan: 'Particular'),
      desktop,
    );
    expect(
      find.byKey(const ValueKey('new-appointment-desktop-layout')),
      findsOneWidget,
    );
    expect(find.text('Serviço: Exames'), findsOneWidget);
    expect(find.text('Convênio: Particular'), findsOneWidget);
  });

  testWidgets('perfil do pet preserva a composição ampla em 600 e 899 px', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    for (final size in const [Size(600, 844), Size(899, 844)]) {
      await pumpPage(tester, DetalhesPetPage(pet: pet), size);
      expect(find.text('Detalhes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('detalhes móvel: composição anterior em 320 e 390 px', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    for (final size in const [Size(320, 640), Size(390, 844)]) {
      await pumpMobileDetails(tester, size);
      await tester.pumpAndSettle();
      expect(find.text('Detalhes'), findsOneWidget);
      expect(find.text(pet.name), findsOneWidget);
      expect(find.text('Nova Consulta'), findsOneWidget);
      Future<void> checkRecordButton(String label) async {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate(
            (widget) => widget is OutlinedButton,
          ),
        );
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        expect(button.hitTestable(), findsOneWidget);
        final style = tester.widget<OutlinedButton>(button).style;
        expect(style?.textStyle?.resolve({})?.fontFamily, VH.bodyFontFamily);
      }

      await checkRecordButton('Vacinação');
      expect(find.byType(VetBottomNav), findsOneWidget);
      await tester.ensureVisible(find.text('Próximo agendamento'));
      await tester.pumpAndSettle();
      expect(find.text('Próximo agendamento'), findsOneWidget);
      await tester.ensureVisible(find.text('Detalhes'));
      await tester.tap(find.text('Detalhes'));
      await tester.pumpAndSettle();
      await checkRecordButton('Saúde');
      final back = find.byTooltip('Voltar');
      await tester.ensureVisible(back);
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Detalhes em $size');
    }
  });

  testWidgets('detalhes móvel: dados e histórico ficam na página de detalhes', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    for (final size in const [Size(320, 640), Size(390, 844)]) {
      await pumpMobileDetails(tester, size);
      expect(find.text('Espécie'), findsNothing);
      expect(find.text('Castração'), findsNothing);
      await tester.tap(find.text('Detalhes'));
      await tester.pumpAndSettle();
      expect(find.text('Espécie'), findsOneWidget);
      expect(find.text('Castração'), findsOneWidget);
      expect(find.text(pet.species!), findsOneWidget);
      expect(find.text('Castrado'), findsOneWidget);
      expect(find.text('Histórico de atendimentos'), findsOneWidget);
      expect(find.text('Dados demonstrativos'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Detalhes em $size');
    }
  });

  testWidgets('detalhes móvel: Editar abre modal e Cancelar preserva o pet', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    for (final size in const [Size(320, 640), Size(390, 844)]) {
      await pumpMobileDetails(tester, size);
      await tester.tap(find.text('Detalhes'));
      await tester.pumpAndSettle();
      final edit = find.widgetWithText(ElevatedButton, 'Editar');
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('edit-pet-modal-surface')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Editar pet'), findsOneWidget);
      final figmaCancelTarget = find.byKey(
        const ValueKey('pet-edit-cancel-target'),
      );
      final cancelTarget = figmaCancelTarget.evaluate().isNotEmpty
          ? figmaCancelTarget
          : find.widgetWithText(OutlinedButton, 'Cancelar');
      await tester.ensureVisible(cancelTarget);
      await tester.tap(cancelTarget);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('edit-pet-modal-surface')),
        findsNothing,
      );
      expect(find.text('Histórico de atendimentos'), findsOneWidget);
      expect(VetRepository.petById(pet.id)?.name, pet.name);
      expect(tester.takeException(), isNull, reason: 'Editar em $size');
    }
  });

  testWidgets('histórico permite ver o último atendimento acima das ações', (
    tester,
  ) async {
    for (final size in const [Size(320, 640), Size(390, 844)]) {
      await pumpMobileDetails(tester, size);
      await tester.tap(find.text('Detalhes'));
      await tester.pumpAndSettle();
      final last = find.text('Pesagem e avaliação');
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      final edit = find.widgetWithText(ElevatedButton, 'Editar');
      expect(
        tester.getBottomLeft(last).dy,
        lessThan(tester.getTopLeft(edit).dy),
      );
      expect(tester.takeException(), isNull, reason: 'Histórico em $size');
    }
  });

  testWidgets('detalhes mantém histórico acessível com texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: DetalhesPetPage(pet: VetRepository.pets.first),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Detalhes'));
    await tester.tap(find.text('Detalhes'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Pesagem e avaliação'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('detalhes móvel: Nova Consulta seleciona pet e abre Serviços', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    final oldSelection = VetRepository.selectedPetId;
    addTearDown(() => VetRepository.selectedPetId = oldSelection);
    for (final size in const [Size(320, 640), Size(390, 844)]) {
      VetRepository.selectedPetId = VetRepository.pets.last.id;
      await pumpMobileDetails(
        tester,
        size,
        routes: {
          '/servicos': (_) =>
              const Scaffold(body: Center(child: Text('Destino Serviços'))),
        },
      );
      await tester.ensureVisible(find.text('Nova Consulta'));
      await tester.tap(find.text('Nova Consulta'));
      await tester.pumpAndSettle();
      expect(find.text('Destino Serviços'), findsOneWidget);
      expect(VetRepository.selectedPetId, pet.id);
      expect(find.byType(DetalhesPetPage), findsNothing);
      expect(tester.takeException(), isNull, reason: 'Nova Consulta em $size');
    }
  });

  testWidgets('detalhes móvel: barra inferior navega para as cinco abas', (
    tester,
  ) async {
    const destinations = <String, String>{
      'Pets': '/pets',
      'Perfil': '/perfil',
      'Conversa': '/chat',
      'Agenda': '/agenda',
      'Configurações': '/config',
    };
    for (final size in const [Size(320, 640), Size(390, 844)]) {
      for (final entry in destinations.entries) {
        await pumpMobileDetails(
          tester,
          size,
          routes: {
            for (final route in destinations.values)
              route: (_) =>
                  Scaffold(body: Center(child: Text('Destino $route'))),
          },
        );
        final button = find.descendant(
          of: find.byType(VetBottomNav),
          matching: find.bySemanticsLabel(entry.key),
        );
        expect(button, findsOneWidget);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text('Destino ${entry.value}'), findsOneWidget);
        expect(find.byType(DetalhesPetPage), findsNothing);
        expect(tester.takeException(), isNull, reason: '${entry.key} em $size');
      }
    }
  });
}
