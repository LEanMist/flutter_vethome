import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/chat_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/sobre_page.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

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
      expect(find.byType(VetBottomNav), findsOneWidget);
      await tester.ensureVisible(find.text('Próximo agendamento'));
      await tester.pumpAndSettle();
      expect(find.text('Próximo agendamento'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Detalhes em $size');
    }
  });

  testWidgets('detalhes móvel: expandir e recolher dados no cartão anterior', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    final summary = find.byType(PetSummary);

    for (final size in const [Size(320, 640), Size(390, 844)]) {
      await pumpMobileDetails(tester, size);
      expect(find.text('Espécie'), findsNothing);
      expect(find.text('Castração'), findsNothing);
      await tester.ensureVisible(summary);
      await tester.tap(summary);
      await tester.pumpAndSettle();
      expect(find.text('Espécie'), findsOneWidget);
      expect(find.text('Castração'), findsOneWidget);
      expect(find.text(pet.species!), findsOneWidget);
      expect(find.text('Castrado'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Expandido em $size');
      await tester.ensureVisible(summary);
      await tester.tap(summary);
      await tester.pumpAndSettle();
      expect(find.text('Espécie'), findsNothing);
      expect(find.text('Castração'), findsNothing);
      expect(find.text('Castrado'), findsNothing);
      expect(tester.takeException(), isNull, reason: 'Recolhido em $size');
    }
  });

  testWidgets('detalhes móvel: Editar abre modal e Cancelar preserva o pet', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    for (final size in const [Size(320, 640), Size(390, 844)]) {
      await pumpMobileDetails(tester, size);
      await tester.ensureVisible(find.byTooltip('Editar'));
      await tester.tap(find.byTooltip('Editar'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('edit-pet-modal-surface')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Editar pet'), findsOneWidget);
      await tester.ensureVisible(find.text('Cancelar'));
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('edit-pet-modal-surface')),
        findsNothing,
      );
      expect(find.text(pet.name), findsOneWidget);
      expect(VetRepository.petById(pet.id)?.name, pet.name);
      expect(tester.takeException(), isNull, reason: 'Editar em $size');
    }
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
