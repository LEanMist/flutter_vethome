import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/sobre_page.dart';
import 'package:flutter_vethome/widgets.dart';

void main() {
  testWidgets('VHHeader respeita texto a 200% sem reduzir nem cortar', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  VHHeader('Sobre a veterinária'),
                  SizedBox(height: 800),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final header = find.byType(VHHeader);
      final title = find.bySemanticsLabel('Sobre a veterinária');
      expect(tester.getSize(header).height, greaterThan(125));
      expect(
        find.descendant(of: header, matching: find.byType(FittedBox)),
        findsNothing,
      );
      expect(title, findsOneWidget);
      expect(tester.getSemantics(title).flagsCollection.isHeader, isTrue);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('Sobre mim é anunciado como cabeçalho', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const MaterialApp(home: SobreScreen()));
      await tester.pumpAndSettle();

      final heading = find.bySemanticsLabel('Sobre mim');
      expect(heading, findsOneWidget);
      expect(tester.getSemantics(heading).flagsCollection.isHeader, isTrue);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
