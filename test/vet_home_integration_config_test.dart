import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/config_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(320, 640)]) {
    testWidgets('Configurações preserva cinco ações e visual em $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
      final header = find.byType(VHHeader);
      expect(tester.getSize(header).height, 125);
      final box = tester.widget<Container>(
        find.descendant(of: header, matching: find.byType(Container)).first,
      );
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, VH.secondary);
      expect(
        decoration.borderRadius,
        const BorderRadius.vertical(bottom: Radius.circular(30)),
      );
      expect(decoration.boxShadow, isNull);
      final title = tester.widget<Text>(find.text('Configurações'));
      expect(title.style?.fontFamily, 'Comfortaa');
      expect(title.style?.fontSize, 30);
      expect(title.style?.fontWeight, FontWeight.bold);
      expect(title.style?.color, Colors.white);
      expect(find.byTooltip('Telas de teste'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(5));
      expect(find.byType(Divider), findsNWidgets(4));
      for (final label in [
        'Tema do Aplicativo',
        'Meus Endereços',
        'Suporte',
        'Histórico',
        'Sair',
      ]) {
        final text = tester.widget<Text>(find.text(label));
        expect(text.style?.fontFamily, 'Comfortaa');
        expect(text.style?.fontSize, 18);
        expect(text.style?.fontWeight, FontWeight.bold);
        expect(text.style?.color, VH.foreground);
        expect(find.text(label).hitTestable(), findsOneWidget);
      }
      for (final label in [
        'Pets',
        'Perfil',
        'Conversa',
        'Agenda',
        'Configurações',
      ]) {
        expect(
          find.descendant(
            of: find.byType(VetBottomNav),
            matching: find.bySemanticsLabel(label),
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cabeçalho padrão preserva geometria sem atalho duplicado', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VHHeader('Padrão'))),
    );
    expect(tester.getSize(find.byType(VHHeader)).height, 125);
    final box = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(VHHeader),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = box.decoration! as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadius.vertical(bottom: Radius.circular(30)),
    );
    expect(decoration.boxShadow, isNull);
    expect(find.byTooltip('Telas de teste'), findsNothing);
  });

  testWidgets('Configurações mantém rotas, tema, suporte, histórico e saída', (
    tester,
  ) async {
    final previousSeed = VH.themeSeed.value;
    addTearDown(() => VH.themeSeed.value = previousSeed);
    await tester.pumpWidget(
      MaterialApp(
        home: const ConfigScreen(),
        routes: {
          '/enderecos': (_) => const Scaffold(body: Text('Destino endereços')),
          '/login': (_) => const Scaffold(body: Text('Destino login')),
        },
      ),
    );
    for (final entry in {'Meus Endereços': 'Destino endereços'}.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      Navigator.of(tester.element(find.text(entry.value))).pop();
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    final rose = find.byWidgetPredicate(
      (w) => w is CircleAvatar && w.backgroundColor == VH.secondary,
    );
    await tester.tap(rose);
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(VH.themeSeed.value, VH.secondary);
    await tester.tap(find.text('Suporte'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('support-figma-surface')), findsOneWidget);
    expect(find.text('11 9793-8918'), findsOneWidget);
    expect(find.text('Kelvinpro@gmail.com'), findsOneWidget);
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('support-figma-surface')), findsNothing);
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.ensureVisible(find.text('Fechar'));
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(ConfigScreen), findsOneWidget);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sair'));
    await tester.pumpAndSettle();
    expect(find.text('Destino login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
