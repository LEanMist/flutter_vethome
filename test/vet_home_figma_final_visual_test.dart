import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/editar_pet_page.dart';
import 'package:flutter_vethome/pages/home_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/sucessoScreen.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/widgets/vet_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  Future<void> pumpAt(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump();
  }

  testWidgets('Pets e Escolha de Pet usam seus painéis do Figma', (
    tester,
  ) async {
    await pumpAt(tester, const PetsPage());
    expect(find.byKey(const ValueKey('pets-list-panel')), findsOneWidget);
    final firstListImage = tester.widget<Image>(
      find
          .descendant(
            of: find.byKey(const ValueKey('pets-list-panel')),
            matching: find.byType(Image),
          )
          .first,
    );
    expect(firstListImage.color, Colors.white);

    await pumpAt(tester, const EscolhaPetScreen());
    expect(find.byKey(const ValueKey('pets-list-panel')), findsNothing);
    final choicePanel = find.byKey(const ValueKey('pet-choice-panel'));
    expect(choicePanel, findsOneWidget);
    expect(tester.getRect(choicePanel), const Rect.fromLTWH(0, 0, 390, 408));
    expect(find.text('Escolha seu Pet'), findsOneWidget);
    final choiceList = find.byKey(const ValueKey('pet-choice-mobile-list'));
    expect(tester.getSize(choiceList), const Size(275, 262));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Perfil sem foto mostra marcador de edição no círculo tracejado',
    (tester) async {
      VetRepository.clientPhotoPath = null;
      VetRepository.clientPhotoBytes = null;
      await pumpAt(tester, const PerfilPage());
      expect(find.byKey(const ValueKey('profile-empty-photo')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('profile-empty-photo')),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
      expect(find.text('Mudar gênero'), findsNothing);

      await pumpAt(tester, const PerfilPage(), size: const Size(1280, 800));
      expect(
        find.byKey(const ValueKey('profile-desktop-layout')),
        findsOneWidget,
      );
      expect(find.text('Mudar gênero'), findsNothing);
      expect(find.text('Alterar endereço'), findsNothing);
    },
  );

  testWidgets('Editar pet modal respeita proporção e acabamento do Figma', (
    tester,
  ) async {
    await pumpAt(
      tester,
      EditarPetPage(pet: VetRepository.pets.first, modal: true),
    );
    final surface = tester.widget<Container>(
      find.byKey(const ValueKey('edit-pet-modal-surface')),
    );
    final dynamic decoration = surface.decoration!;
    expect(decoration.borderRadius, BorderRadius.circular(30));
    expect(decoration.boxShadow, isNotEmpty);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('edit-pet-modal-surface')))
          .width,
      310,
    );
  });

  testWidgets('agendamento mobile abre o calendário compartilhado', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    await pumpAt(
      tester,
      NovaConsultaPage(pet: pet, service: 'Hemograma', plan: 'Particular'),
    );
    await tester.tap(find.byKey(const ValueKey('appointment-booking-date')));
    await tester.pumpAndSettle();
    expect(find.byType(VetCalendar), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mobile-calendar-dialog')),
      findsOneWidget,
    );
  });

  testWidgets('seletor de horário usa painel e botões visuais do VetHome', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    await pumpAt(
      tester,
      NovaConsultaPage(pet: pet, service: 'Hemograma', plan: 'Particular'),
    );
    await tester.tap(
      find.byKey(const ValueKey('appointment-booking-start-time')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('time-choice-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('time-choice-12')), findsOneWidget);
  });

  testWidgets('Sucesso preserva nome real e confirmação do Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    VetRepository.updateClient(name: 'Cliente Teste');
    await tester.pumpWidget(
      MaterialApp(
        home: const SucessoScreen(),
        routes: {'/home': (_) => const HomePage()},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Cliente Teste'), findsOneWidget);
    expect(find.text('Usuário\nCadastrado!'), findsOneWidget);
    final ring = find.byKey(const ValueKey('success-logo-ring'));
    expect(ring, findsOneWidget);
    expect(tester.getTopLeft(ring).dx, closeTo(44.37, .01));
    expect(tester.getTopLeft(ring).dy, closeTo(274.37, .01));
    expect(tester.getSize(ring).width, closeTo(300.158, .01));
    expect(tester.getSize(ring).height, closeTo(300.158, .01));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-figma-frame')), findsOneWidget);
  });
}
