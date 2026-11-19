import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_agenda_tab.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_area_page.dart';

void main() {
  for (final size in [const Size(800, 900), const Size(390, 500)]) {
    group('pop-ups em ${size.width.toInt()}x${size.height.toInt()}', () {
      testWidgets('calendário fica no centro e permite escolher uma data', (
        tester,
      ) async {
        await _showScreen(tester, size, const GabrielaAgendaTab());
        await tester.tap(find.text('10 - Terça Feira'));
        await tester.pumpAndSettle();
        _expectCentered(tester, size);
        expect(tester.takeException(), isNull);

        final day = find.descendant(
          of: find.byType(Dialog),
          matching: find.text('11'),
        );
        await tester.ensureVisible(day);
        await tester.tap(day);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(find.text('11 - Quarta Feira'), findsOneWidget);
      });

      testWidgets('detalhes da consulta ficam no centro e acessíveis', (
        tester,
      ) async {
        await _showScreen(tester, size, const GabrielaAgendaTab());
        await tester.tap(find.text('Rambo Augusto'));
        await tester.pumpAndSettle();
        _expectCentered(tester, size);
        expect(tester.takeException(), isNull);

        final address = find.descendant(
          of: find.byType(Dialog),
          matching: find.text('R. Augusto Cury, 123 – Vila Osasco'),
        );
        await tester.ensureVisible(address);
        await tester.pumpAndSettle();
        expect(address.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('opções de foto ficam no centro', (tester) async {
        await _showScreen(tester, size, const GabrielaProfileTab());
        await tester.tap(find.text('Mudar Foto de Perfil'));
        await tester.pumpAndSettle();
        _expectCentered(tester, size);
        expect(find.text('Escolher da galeria').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('escolha de tema fica no centro', (tester) async {
        await _showScreen(tester, size, const GabrielaSettingsTab());
        await tester.tap(find.text('Tema do Aplicativo'));
        await tester.pumpAndSettle();
        _expectCentered(tester, size);
        expect(find.text('Rosa VetHome').hitTestable(), findsOneWidget);
        expect(find.text('Marrom VetHome').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('histórico fica no centro e acessível', (tester) async {
        await _showScreen(tester, size, const GabrielaSettingsTab());
        await tester.tap(find.text('Histórico'));
        await tester.pumpAndSettle();
        _expectCentered(tester, size);
        final lastItem = find.text('Olivia · atendimento concluído');
        await tester.ensureVisible(lastItem);
        await tester.pumpAndSettle();
        expect(lastItem.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}

Future<void> _showScreen(WidgetTester tester, Size size, Widget screen) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: screen),
    ),
  );
}

void _expectCentered(WidgetTester tester, Size viewport) {
  final dialog = find.byType(Dialog);
  expect(dialog, findsOneWidget);
  final surface = find
      .descendant(of: dialog, matching: find.byType(Material))
      .first;
  final rect = tester.getRect(surface);
  expect(rect.center.dx, closeTo(viewport.width / 2, 1));
  expect(rect.center.dy, closeTo(viewport.height / 2, 1));
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(viewport.width));
  expect(rect.bottom, lessThanOrEqualTo(viewport.height));
}
