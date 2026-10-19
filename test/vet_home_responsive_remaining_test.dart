import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/pages/chat_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/sobre_page.dart';
import 'package:flutter_vethome/screens/pets.dart';

Future<void> pumpPage(WidgetTester tester, Widget page, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      routes: {
        '/sobre': (_) => const SobreScreen(),
        '/enderecos': (_) => const AddressesPage(),
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
}
