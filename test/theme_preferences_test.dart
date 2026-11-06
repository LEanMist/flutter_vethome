import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/data/theme_preferences.dart';
import 'package:flutter_vethome/pages/config_page.dart';
import 'package:flutter_vethome/theme.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tema escolhido em Configurações persiste após reinicialização', (
    tester,
  ) async {
    final previousSeed = VH.themeSeed.value;
    addTearDown(() => VH.themeSeed.value = previousSeed);

    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    final rose = find.byWidgetPredicate(
      (widget) =>
          widget is CircleAvatar &&
          widget.backgroundColor == const Color(0xFFC08081),
    );
    await tester.tap(rose);
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt(ThemePreferences.storageKey), 0xFFC08081);

    VH.themeSeed.value = VH.primary;
    await ThemePreferences.load();
    expect(VH.themeSeed.value, const Color(0xFFC08081));
    expect(tester.takeException(), isNull);
  });

  test(
    'prefere o tema padrão quando o armazenamento contém uma cor inválida',
    () async {
      SharedPreferences.setMockInitialValues({
        ThemePreferences.storageKey: 0xFF12AB34,
      });
      VH.themeSeed.value = VH.primary;

      await ThemePreferences.load();

      expect(VH.themeSeed.value, VH.primary);
    },
  );

  test('não grava cores fora da paleta disponível', () async {
    final saved = await ThemePreferences.save(Colors.red);
    final preferences = await SharedPreferences.getInstance();

    expect(saved, isFalse);
    expect(preferences.getInt(ThemePreferences.storageKey), isNull);
  });
}
