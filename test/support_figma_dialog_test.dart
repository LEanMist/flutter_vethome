import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/config_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final comfortaa = FontLoader('Comfortaa')
      ..addFont(rootBundle.load('assets/fonts/ComfortaaRegular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/ComfortaaMedium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/ComfortaaBold.ttf'));
    final montserrat = FontLoader('MontserratAlternates')
      ..addFont(rootBundle.load('assets/fonts/MontserratAlternatesRegular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/MontserratAlternatesMedium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/MontserratAlternatesBold.ttf'));
    await Future.wait([comfortaa.load(), montserrat.load()]);
  });

  Future<void> openSupport(
    WidgetTester tester, {
    required Size viewport,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const ConfigScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suporte'));
    await tester.pumpAndSettle();
  }

  testWidgets('SUPORT_WIDGET mantém dimensões e estilo do Figma', (
    tester,
  ) async {
    await openSupport(tester, viewport: const Size(390, 844));

    final surface = find.byKey(const ValueKey('support-figma-surface'));
    expect(tester.getSize(surface), const Size(349, 289));
    final decoration =
        tester.widget<Container>(surface).decoration! as BoxDecoration;
    expect(decoration.color, VetColors.pink);
    expect(decoration.borderRadius, BorderRadius.circular(30));

    final title = tester.widget<Text>(
      find.descendant(of: surface, matching: find.text('Suporte')),
    );
    expect(title.style?.fontFamily, VH.bodyFontFamily);
    expect(title.style?.fontSize, 40);
    expect(title.style?.fontWeight, FontWeight.bold);
    expect(title.style?.color, VetColors.brown);
    expect(find.textContaining('Número'), findsOneWidget);
    expect(find.text('11 93244-4392'), findsOneWidget);
    expect(find.text('Email:'), findsOneWidget);
    expect(find.text('Gabriela@gmail.com'), findsOneWidget);
    expect(find.byType(SelectableText), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Suporte se adapta a tela estreita com texto ampliado', (
    tester,
  ) async {
    await openSupport(tester, viewport: const Size(320, 640), textScale: 2);

    final surface = find.byKey(const ValueKey('support-figma-surface'));
    final size = tester.getSize(surface);
    expect(size.width, lessThanOrEqualTo(280));
    expect(size.height, greaterThanOrEqualTo(289));
    expect(size.height, lessThanOrEqualTo(592));
    expect(find.text('11 93244-4392'), findsOneWidget);
    expect(find.text('Gabriela@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
