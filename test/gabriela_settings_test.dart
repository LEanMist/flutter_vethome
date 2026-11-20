import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_area_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

void main() {
  testWidgets('cores escolhidas correspondem aos nomes exibidos', (
    tester,
  ) async {
    addTearDown(() => VH.themeSeed.value = VetColors.brown);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GabrielaSettingsTab())),
    );
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rosa VetHome'));
    await tester.pumpAndSettle();
    expect(VH.themeSeed.value, VetColors.rose);
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marrom VetHome'));
    await tester.pumpAndSettle();
    expect(VH.themeSeed.value, VetColors.brown);
  });

  testWidgets('permite rolar até Sair e voltar ao login da Gabriela', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 260);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: GabrielaSettingsTab()),
        routes: {
          '/gabriela/login': (_) => const Scaffold(body: Text('Login Gabriela')),
        },
      ),
    );
    final exit = find.text('Sair');
    await tester.scrollUntilVisible(exit, 100);
    await tester.tap(exit);
    await tester.pumpAndSettle();
    expect(find.text('Login Gabriela'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
