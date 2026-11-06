import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/pets/pets_theme.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

void main() {
  const viewports = <Size>[Size(320, 640), Size(390, 844), Size(1280, 800)];
  const address = SavedAddress(
    id: 'figma-address',
    street: 'Rua das Flores',
    name: 'Casa da Irmã',
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
      final profileTitle = tester.widget<Text>(find.text('Perfil'));
      expect(profileTitle.style?.fontSize, closeTo(30 * scale, .01));
      expect(profileTitle.style?.fontFamily, PetsTheme.fontComfortaa);
      expect(profileTitle.style?.fontWeight, FontWeight.bold);

      final birthdayIcon = find.byKey(const ValueKey('profile-birthday-icon'));
      expect(birthdayIcon, findsOneWidget);
      final birthdayImage = tester.widget<Image>(birthdayIcon);
      expect(birthdayImage.width, closeTo(18 * scale, .01));
      expect(birthdayImage.height, closeTo(22 * scale, .01));
      final birthdayRow = find.ancestor(
        of: birthdayIcon,
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
      if (viewport.width < 600) {
        final ellipse = find.byKey(const ValueKey('profile-avatar-dashes'));
        expect(ellipse, findsOneWidget);
        expect(tester.getSize(ellipse).width, closeTo(190.103 * scale, .01));
        expect(tester.getSize(ellipse).height, closeTo(186.971 * scale, .01));
      }
      if (viewport == const Size(390, 844)) {
        expect(tester.getTopLeft(find.text('Perfil')).dy, closeTo(27, 1));
        expect(
          tester.getSize(find.byWidget(avatarPanel)),
          const Size(220, 280),
        );
        expect(tester.getTopLeft(find.text('Mudar Foto de Perfil')).dx, 28);
        expect(
          tester.getTopLeft(find.text('Mudar Foto de Perfil')).dy,
          closeTo(469, .5),
        );
        expect(
          tester.getTopLeft(find.text('Mudar Nome de Perfil')).dy,
          closeTo(526, .5),
        );
        expect(
          tester.getTopLeft(find.text('Mudar Data de Nascimento')).dy,
          closeTo(583, .5),
        );
        final dividers = find.byType(Divider);
        expect(tester.getTopLeft(dividers.at(0)).dy, closeTo(506, .5));
        expect(tester.getTopLeft(dividers.at(1)).dy, closeTo(563, .5));
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('endereço corresponde ao Figma em $viewport', (tester) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      if (viewport == const Size(390, 844)) {
        tester.view.padding = const FakeViewPadding(bottom: 24);
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
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

      expect(find.text('Endereços'), findsOneWidget);
      expect(find.text('Meus Endereços'), findsNothing);
      final bottomNavigation = find.byType(VetBottomNav);
      expect(
        bottomNavigation,
        viewport.width < 900 ? findsOneWidget : findsNothing,
      );
      expect(find.text('Nome:'), findsOneWidget);
      expect(find.text('Endereço:'), findsOneWidget);
      expect(find.text('Casa da Irmã'), findsOneWidget);
      expect(
        find.text('Rua das Flores\nCasa - 123\nSão Paulo'),
        findsOneWidget,
      );

      final cardFinder = find
          .ancestor(
            of: find.text(address.name),
            matching: find.byType(Container),
          )
          .first;
      final card = tester.widget<Container>(cardFinder);
      final decoration = card.decoration! as inset_shadow.BoxDecoration;
      expect(decoration.color, VetColors.roseOverlay50);
      expect(decoration.borderRadius, BorderRadius.circular(25));
      expect(decoration.boxShadow, isNotEmpty);
      expect(tester.getSize(cardFinder).height, 173);
      if (viewport == const Size(390, 844)) {
        expect(tester.getSize(cardFinder).width, 320);
        expect(tester.getTopLeft(cardFinder).dy, 153);
        final newAddressButton = find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox && widget.width == 161 && widget.height == 67,
        );
        expect(tester.getTopLeft(newAddressButton).dy, 710);
        expect(tester.getTopLeft(bottomNavigation).dy, 794);
        expect(tester.getSize(bottomNavigation), const Size(390, 50));
        final settingsDestination = find.descendant(
          of: bottomNavigation,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Configurações' &&
                widget.properties.selected == true,
          ),
        );
        expect(settingsDestination, findsOneWidget);
      }

      expect(find.text('Deletar'), findsOneWidget);
      expect(find.text('Novo Endereço'), findsOneWidget);
      await tester.ensureVisible(find.text('Editar'));
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      if (viewport.width < 900) {
        expect(
          find.byKey(const ValueKey('address-editor-dialog')),
          findsOneWidget,
        );
        expect(find.byType(AddressEditorPage), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('address-editor-panel'))),
          const Size(290, 633),
        );
        expect(find.text('Editar endereço'), findsNothing);
      } else {
        expect(editedAddress, same(address));
        expect(find.text('Editor aberto'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Configurações da barra abre a tela correspondente', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const AddressesPage(),
        onGenerateRoute: (settings) {
          if (settings.name == '/config') {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Configuração aberta')),
            );
          }
          return null;
        },
      ),
    );

    await tester.tap(find.bySemanticsLabel('Configurações'));
    await tester.pumpAndSettle();

    expect(find.text('Configuração aberta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
