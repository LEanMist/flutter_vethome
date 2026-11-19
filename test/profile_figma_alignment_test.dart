import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/widgets/pets/pets_theme.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

void main() {
  testWidgets('PROFILE_PAGE: geometria do contorno oval e da foto em 390x844', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();

    final panel = tester
        .widgetList<Container>(find.byType(Container))
        .singleWhere(
          (widget) =>
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color ==
                  VetColors.pinkOverlay50,
        );
    expect(
      tester.getRect(find.byWidget(panel)),
      const Rect.fromLTWH(85, 72, 220, 280),
    );

    // Figma 2783:1078: foto em x=27, y=88 dentro do painel.
    expect(
      tester.getRect(find.byKey(const ValueKey('profile-change-photo-action'))),
      const Rect.fromLTWH(112, 160, 165, 165),
    );

    // Figma 2783:1083: a elipse tem origem x=16.4486, y=78.8448
    // dentro do painel. O CustomPainter começa 1.5 px antes do traçado.
    final painter = tester.getRect(
      find.byKey(const ValueKey('profile-avatar-dashes')),
    );
    expect(painter.left + 1.5, closeTo(85 + 16.4486, 0.2));
    expect(painter.top + 1.5, closeTo(72 + 78.8448, 0.2));

    // As posições dos textos de ação vêm dos nós 2783:1085/1087/1088.
    for (final (label, top) in [
      ('Mudar Foto de Perfil', 469.0),
      ('Mudar Nome de Perfil', 526.0),
      ('Mudar Data de Nascimento', 583.0),
    ]) {
      expect(tester.getTopLeft(find.text(label)).dy, closeTo(top, 0.5));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('PROFILE_PAGE: área segura superior não desloca o Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Perfil')).dy, closeTo(27, .5));
    final avatar = tester
        .widgetList<Container>(find.byType(Container))
        .singleWhere(
          (widget) =>
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color ==
                  VetColors.pinkOverlay50,
        );
    expect(
      tester.getRect(find.byWidget(avatar)),
      const Rect.fromLTWH(85, 72, 220, 280),
    );
    expect(
      tester.getTopLeft(find.text('Mudar Foto de Perfil')).dy,
      closeTo(469, .5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'PROFILE_PAGE: nascimento, ações, separadores e navegação em 390x844',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
      await tester.pumpAndSettle();

      final title = find.text('Perfil');
      expect(tester.getTopLeft(title).dy, closeTo(27, .5));
      final titleStyle = tester.widget<Text>(title).style!;
      expect(titleStyle.fontFamily, PetsTheme.fontComfortaa);
      expect(titleStyle.fontSize, 30);
      expect(titleStyle.fontWeight, FontWeight.bold);

      final birthIcon = find.byKey(const ValueKey('profile-birthday-icon'));
      final birthRow = find
          .ancestor(of: birthIcon, matching: find.byType(Row))
          .first;
      final birthText = find
          .descendant(of: birthRow, matching: find.byType(Text))
          .first;
      final birthStyle = tester.widget<Text>(birthText).style!;
      expect(birthStyle.fontSize, 18);
      expect(birthStyle.fontFamily, PetsTheme.fontComfortaa);
      expect(birthStyle.fontWeight, FontWeight.bold);
      expect(tester.getTopLeft(birthText).dy, closeTo(365, .5));
      expect(tester.getSize(birthIcon), const Size(18, 22));

      for (final (index, label, y) in [
        (0, 'Mudar Foto de Perfil', 469.0),
        (1, 'Mudar Nome de Perfil', 526.0),
        (2, 'Mudar Data de Nascimento', 583.0),
      ]) {
        final text = find.text(label);
        expect(tester.getTopLeft(text).dx, closeTo(27, 1.5));
        expect(tester.getTopLeft(text).dy, closeTo(y, .5));
        final textStyle = tester.widget<Text>(text).style!;
        expect(textStyle.fontFamily, PetsTheme.fontComfortaa);
        expect(textStyle.fontSize, 18);
        expect(textStyle.fontWeight, FontWeight.bold);

        final arrow = find.byKey(ValueKey('profile-option-chevron-$index'));
        expect(arrow, findsOneWidget);
        expect(tester.getSize(arrow), const Size(11, 19.6299));
        expect(tester.widget<SvgPicture>(arrow).fit, BoxFit.fill);
        // O SVG export tem 1,5 px de margem de traço fora dos nós 1089-1091.
        // O viewport expandido mantém o início do caminho em x=352 e y+2.
        expect(tester.getRect(arrow).left, closeTo(350.508, .1));
        expect(tester.getRect(arrow).top, closeTo(y + .5, .1));
      }

      final dividers = find.byType(Divider);
      expect(dividers, findsNWidgets(2));
      expect(tester.getTopLeft(dividers.at(0)).dy, closeTo(506, .5));
      expect(tester.getTopLeft(dividers.at(1)).dy, closeTo(563, .5));

      final nav = find.byType(VetBottomNav);
      expect(nav, findsOneWidget);
      expect(tester.widget<VetBottomNav>(nav).selectedIndex, 1);
      final navSurface = find.descendant(
        of: nav,
        matching: find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is inset_shadow.BoxDecoration &&
              decoration.borderRadius == BorderRadius.circular(25) &&
              decoration.color == VetColors.rose.withValues(alpha: .5);
        }),
      );
      expect(navSurface, findsOneWidget);
      // O Container também inclui as margens externas; comparar sua superfície.
      final surfaceWidget = tester.widget<Container>(navSurface);
      final margin = surfaceWidget.margin!.resolve(TextDirection.ltr);
      final outer = tester.getRect(navSurface);
      final visibleSurface = Rect.fromLTRB(
        outer.left + margin.left,
        outer.top + margin.top,
        outer.right - margin.right,
        outer.bottom - margin.bottom,
      );
      expect(visibleSurface, const Rect.fromLTWH(12, 724, 366, 70));
      expect(
        find.descendant(
          of: nav,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Perfil' &&
                widget.properties.selected == true,
          ),
        ),
        findsOneWidget,
      );
      for (final (index, label) in const [
        (0, 'Pets'),
        (1, 'Perfil'),
        (2, 'Conversa'),
        (3, 'Agenda'),
        (4, 'Configurações'),
      ]) {
        final destination = find.descendant(
          of: nav,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.label == label,
          ),
        );
        expect(destination, findsOneWidget);
        expect(
          tester.getRect(destination),
          Rect.fromLTWH(30 + index * 70, 734, 50, 50),
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('PROFILE_PAGE: nascimento tem rótulo semântico', (tester) async {
    final semantics = tester.ensureSemantics();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp(r'^Data de nascimento: \d{2}/\d{2}/\d{4}$')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'Perfil mostra nome longo inteiro antes do avatar em texto 200%',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final previousName = VetRepository.clientName;
      const longName = 'Gabriela Fernandes Souza de Oliveira Pereira da Costa';
      VetRepository.clientName = longName;
      addTearDown(() => VetRepository.clientName = previousName);

      for (final viewport in [const Size(390, 844), const Size(320, 640)]) {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: viewport,
                devicePixelRatio: 1,
                textScaler: TextScaler.linear(2),
              ),
              child: const PerfilPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final nameFinder = find.text(longName);
        final nameText = tester.widget<Text>(nameFinder);
        final nameRect = tester.getRect(
          find.byKey(const ValueKey('profile-change-name-action')),
        );
        final photoRect = tester.getRect(
          find.byKey(const ValueKey('profile-change-photo-action')),
        );
        expect(nameText.maxLines, isNull, reason: '$viewport');
        expect(nameRect.height, greaterThan(100), reason: '$viewport');
        expect(
          nameRect.bottom,
          lessThanOrEqualTo(photoRect.top),
          reason: '$viewport',
        );
        expect(tester.takeException(), isNull, reason: '$viewport');
      }
    },
  );

  testWidgets('Perfil desktop acomoda nome longo com texto a 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final previousName = VetRepository.clientName;
    const longName = 'Gabriela Fernandes Souza de Oliveira Pereira da Costa';
    VetRepository.clientName = longName;
    addTearDown(() => VetRepository.clientName = previousName);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const PerfilPage(),
      ),
    );
    await tester.pumpAndSettle();

    final avatar = tester
        .widgetList<Container>(find.byType(Container))
        .singleWhere(
          (widget) =>
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color ==
                  VetColors.pinkOverlay50,
        );
    final avatarRect = tester.getRect(find.byWidget(avatar));
    final nameRect = tester.getRect(
      find.byKey(const ValueKey('profile-change-name-action')),
    );
    final photoRect = tester.getRect(
      find.byKey(const ValueKey('profile-change-photo-action')),
    );

    expect(avatarRect.height, greaterThan(280));
    expect(nameRect.height, greaterThan(80));
    expect(nameRect.bottom, lessThanOrEqualTo(photoRect.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Perfil desktop mantém composição e ações originais', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();

    final avatar = tester
        .widgetList<Container>(find.byType(Container))
        .singleWhere(
          (widget) =>
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color ==
                  VetColors.pinkOverlay50,
        );
    expect(tester.getSize(find.byWidget(avatar)), const Size(220, 280));
    expect(
      find.byKey(const ValueKey('profile-desktop-layout')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile-avatar-dashes')), findsNothing);
    expect(
      find.byKey(const ValueKey('profile-change-name-action')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-change-photo-action')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
