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
}
