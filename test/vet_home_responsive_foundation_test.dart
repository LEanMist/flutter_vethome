import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';
import 'package:flutter_vethome/widgets/vet/vet_page_scaffold.dart';

void main() {
  void useViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  test('fundação centraliza os limites responsivos aprovados', () {
    expect(VH.compactBreakpoint, 600);
    expect(VH.desktopBreakpoint, 900);
    expect(VH.mobileContentMaxWidth, 600);
    expect(VH.desktopContentMaxWidth, 1120);
    expect(VH.desktopShellMaxWidth, 1200);
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('${size.width.toInt()} px usa a composição mobile', (
      tester,
    ) async {
      useViewport(tester, size);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VetResponsiveLayout(
              mobile: Text('mobile'),
              desktop: Text('desktop'),
            ),
          ),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('desktop'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('desktop usa composição ampla sem esticar o conteúdo', (
    tester,
  ) async {
    useViewport(tester, const Size(1440, 900));
    await tester.pumpWidget(
      const MaterialApp(
        home: VetPageScaffold(
          title: 'Fundação responsiva',
          showBack: false,
          contentMaxWidth: VH.desktopContentMaxWidth,
          children: [
            VetResponsiveLayout(
              mobile: Text('mobile'),
              desktop: Text('desktop'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('desktop'), findsOneWidget);
    expect(find.text('mobile'), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('vet-page-shell'))).width,
      VH.desktopShellMaxWidth,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('vet-page-content'))).width,
      VH.desktopContentMaxWidth,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1440, 900),
  ]) {
    testWidgets(
      'navegação mantém cinco destinos e alvos acessíveis em ${size.width.toInt()} px',
      (tester) async {
        useViewport(tester, size);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: VetBottomNav(
                selectedIndex: 0,
                onSelected: (_) {},
              ),
            ),
          ),
        );

        for (final label in const [
          'Pets',
          'Perfil',
          'Whatsapp',
          'Agenda',
          'Configurações',
        ]) {
          final destination = find.bySemanticsLabel(label);
          expect(destination, findsOneWidget);
          final size = tester.getSize(destination);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
