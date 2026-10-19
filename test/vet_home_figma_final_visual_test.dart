import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/editar_pet_page.dart';
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

  testWidgets('Pets usa painel do Figma e Escolha seu Pet não usa o painel', (
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
  });

  testWidgets(
    'Perfil sem foto mostra marcador de edição no círculo tracejado',
    (tester) async {
      VetRepository.clientPhotoPath = null;
      VetRepository.clientPhotoBytes = null;
      await pumpAt(tester, const PerfilPage());
      expect(find.byKey(const ValueKey('profile-empty-photo')), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
      expect(find.text('Mudar gênero'), findsNothing);

      await pumpAt(tester, const PerfilPage(), size: const Size(1280, 800));
      expect(
        find.byKey(const ValueKey('profile-desktop-layout')),
        findsOneWidget,
      );
      expect(find.text('Mudar gênero'), findsNothing);
      expect(find.text('Alterar endereço'), findsOneWidget);
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
    await tester.tap(find.text('Data'));
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
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('time-choice-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('time-choice-12')), findsOneWidget);
  });

  testWidgets('Sucesso preserva nome real e confirmação do Figma', (
    tester,
  ) async {
    VetRepository.updateClient(name: 'Cliente Teste');
    await pumpAt(tester, const SucessoScreen());
    expect(find.textContaining('Cliente Teste'), findsOneWidget);
    expect(find.text('Usuário\nCadastrado!'), findsOneWidget);
  });
}
