import 'dart:ui' show SemanticsAction;

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

    final surfaceTop = tester.getTopLeft(surface).dy;
    void expectTopAt(Finder finder, double expectedTop) {
      expect(
        tester.getTopLeft(finder).dy - surfaceTop,
        closeTo(expectedTop, 0.5),
      );
    }

    final title = tester.widget<Text>(
      find.descendant(of: surface, matching: find.text('Suporte')),
    );
    expectTopAt(
      find.descendant(of: surface, matching: find.text('Suporte')),
      24,
    );
    expect(title.style?.fontFamily, VH.bodyFontFamily);
    expect(title.style?.fontSize, 40);
    expect(title.style?.fontWeight, FontWeight.bold);
    expect(title.style?.color, VetColors.brown);
    final numberFinder = find.textContaining('Numero');
    final numberLabel = tester.widget<Text>(numberFinder);
    expectTopAt(numberFinder, 93);
    expect(numberLabel.style?.fontFamily, 'Comfortaa');
    expect(numberLabel.style?.fontSize, 20);
    expect(numberLabel.style?.fontWeight, FontWeight.w500);
    final phone = tester.widget<SelectableText>(
      find.ancestor(
        of: find.text('11 9793-8918'),
        matching: find.byType(SelectableText),
      ),
    );
    expectTopAt(find.text('11 9793-8918'), 129);
    expect(phone.style?.fontFamily, 'Comfortaa');
    expect(phone.style?.fontSize, 25);
    expect(phone.style?.fontWeight, FontWeight.w500);
    final emailLabel = tester.widget<Text>(find.text('Email:'));
    expectTopAt(find.text('Email:'), 172);
    expect(emailLabel.style?.fontFamily, 'Comfortaa');
    expect(emailLabel.style?.fontSize, 20);
    expect(emailLabel.style?.fontWeight, FontWeight.w500);
    // Figma 2783:637: somente a palavra Email usa Comfortaa Bold.
    expect(
      (emailLabel.textSpan as TextSpan?)?.children?.first.style?.fontWeight,
      FontWeight.bold,
    );
    final email = tester.widget<SelectableText>(
      find.ancestor(
        of: find.text('Kelvinpro@gmail.com'),
        matching: find.byType(SelectableText),
      ),
    );
    expectTopAt(find.text('Kelvinpro@gmail.com'), 205);
    expect(email.style?.fontFamily, 'Comfortaa');
    expect(email.style?.fontSize, 30);
    expect(email.style?.fontWeight, FontWeight.w500);
    expect(
      tester
          .getSize(
            find.ancestor(
              of: find.text('Kelvinpro@gmail.com'),
              matching: find.byType(SelectableText),
            ),
          )
          .height,
      lessThan(40),
      reason: 'o e-mail deve ficar em uma única linha, como no Figma',
    );
    expect(find.byType(SelectableText), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('título de Suporte é anunciado como cabeçalho', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await openSupport(tester, viewport: const Size(390, 844));
      final title = find.descendant(
        of: find.byKey(const ValueKey('support-figma-surface')),
        matching: find.text('Suporte'),
      );

      expect(
        tester.getSemantics(title).getSemanticsData().flagsCollection.isHeader,
        isTrue,
      );
    } finally {
      semantics.dispose();
    }
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
    expect(find.text('11 9793-8918'), findsOneWidget);
    expect(find.text('Kelvinpro@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contatos de Suporte anunciam que são fictícios', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await openSupport(tester, viewport: const Size(390, 844));

      final phone = find.bySemanticsLabel(
        'Telefone fictício para demonstração: 11 9793-8918',
      );
      final email = find.bySemanticsLabel(
        'E-mail fictício para demonstração: Kelvinpro@gmail.com',
      );
      expect(phone, findsOneWidget);
      expect(email, findsOneWidget);
      expect(
        tester
            .getSemantics(phone)
            .getSemanticsData()
            .hasAction(SemanticsAction.longPress),
        isTrue,
      );
      expect(
        tester
            .getSemantics(email)
            .getSemanticsData()
            .hasAction(SemanticsAction.longPress),
        isTrue,
      );
    } finally {
      semantics.dispose();
    }
  });
}
