import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pets/pets_theme.dart';

void main() {
  const viewports = <Size>[Size(320, 640), Size(390, 844), Size(1280, 800)];
  const address = SavedAddress(
    id: 'figma-address',
    street: 'Rua das Flores',
    number: '123',
    complement: 'Casa',
    city: 'São Paulo',
    cep: '01234-567',
  );

  late List<SavedAddress> originalAddresses;

  setUp(() {
    originalAddresses = List<SavedAddress>.of(VetRepository.addresses);
    VetRepository.addresses
      ..clear()
      ..add(address);
  });

  tearDown(() {
    VetRepository.addresses
      ..clear()
      ..addAll(originalAddresses);
  });

  double scaleFor(Size viewport) =>
      (viewport.width / PetsTheme.designWidth).clamp(0.8, 1.0).toDouble();

  for (final viewport in viewports) {
    testWidgets('Perfil aplica tipografia e avatar do Figma em $viewport', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
      await tester.pump();

      final scale = scaleFor(viewport);
      final name = tester.widget<Text>(find.text(VetRepository.clientName));
      expect(name.style?.fontFamily, PetsTheme.fontComfortaa);
      expect(name.style?.fontSize, closeTo(22 * scale, .01));
      expect(name.style?.fontWeight, FontWeight.bold);
      expect(name.maxLines, 2);

      final birthdayRow = find.ancestor(
        of: find.byIcon(Icons.cake_outlined),
        matching: find.byType(Row),
      );
      final birthday = tester.widget<Text>(
        find.descendant(of: birthdayRow.first, matching: find.byType(Text)),
      );
      expect(birthday.style?.fontFamily, PetsTheme.fontComfortaa);
      expect(birthday.style?.fontSize, closeTo(18 * scale, .01));
      expect(birthday.style?.fontWeight, FontWeight.bold);

      for (final label in const [
        'Mudar Foto de Perfil',
        'Mudar Nome de Perfil',
        'Mudar Data de Nascimento',
        'Alterar endereço',
      ]) {
        final option = tester.widget<Text>(find.text(label));
        expect(option.style?.fontFamily, PetsTheme.fontComfortaa);
        expect(option.style?.fontSize, closeTo(18 * scale, .01));
        expect(option.style?.fontWeight, FontWeight.bold);
      }

      final avatarPanel = tester
          .widgetList<Container>(find.byType(Container))
          .singleWhere((container) {
            final decoration = container.decoration;
            return decoration is BoxDecoration &&
                decoration.color == VetColors.pinkOverlay50;
          });
      final avatarDecoration = avatarPanel.decoration! as BoxDecoration;
      expect(avatarDecoration.border?.top.width, closeTo(5 * scale, .01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('card de endereço aplica acabamento do Figma em $viewport', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Object? editedAddress;

      await tester.pumpWidget(
        MaterialApp(
          home: const AddressesPage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/editar-endereco') {
              editedAddress = settings.arguments;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const Scaffold(body: Text('Editor aberto')),
              );
            }
            return null;
          },
        ),
      );
      await tester.pump();

      final card = tester.widget<Material>(
        find
            .ancestor(
              of: find.text(address.street),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.color, VetColors.roseOverlay50);
      expect(card.borderRadius, BorderRadius.circular(25));

      final title = tester.widget<Text>(find.text(address.street));
      expect(title.style?.fontFamily, PetsTheme.fontComfortaa);
      expect(title.style?.fontSize, 18);
      expect(title.style?.fontWeight, FontWeight.bold);

      for (final detail in const [
        'Número: 123',
        'Complemento: Casa',
        'São Paulo',
        'CEP: 01234-567',
      ]) {
        final text = tester.widget<Text>(find.text(detail));
        expect(text.style?.fontFamily, PetsTheme.fontComfortaa);
        expect(text.style?.fontSize, 12);
        expect(text.style?.fontWeight, FontWeight.bold);
      }

      expect(find.text('Excluir'), findsOneWidget);
      await tester.ensureVisible(find.text('Editar'));
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      expect(editedAddress, same(address));
      expect(find.text('Editor aberto'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
