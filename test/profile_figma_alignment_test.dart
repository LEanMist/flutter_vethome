import 'package:flutter/material.dart';
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

  testWidgets('Perfil desktop mantém composição e ações originais', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();

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
