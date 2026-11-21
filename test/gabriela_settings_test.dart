import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/theme_preferences.dart';
import 'package:flutter_vethome/pages/gabriela/gabriela_area_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    VH.themeSeed.value = VetColors.brown;
  });
  tearDown(() => VH.themeSeed.value = VetColors.brown);
  testWidgets('cores escolhidas correspondem aos nomes exibidos', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GabrielaSettingsTab())),
    );
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rosa VetHome'));
    await tester.pumpAndSettle();
    expect(VH.themeSeed.value, VetColors.rose);
    VH.themeSeed.value = VetColors.brown;
    await (await SharedPreferences.getInstance()).reload();
    await ThemePreferences.load();
    expect(VH.themeSeed.value, VetColors.rose);
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marrom VetHome'));
    await tester.pumpAndSettle();
    expect(VH.themeSeed.value, VetColors.brown);
  });

  testWidgets('gravação recusada mantém a paleta e informa falha', (
    tester,
  ) async {
    SharedPreferencesStorePlatform.instance = _PaletteWriteFailure();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GabrielaSettingsTab())),
    );
    await tester.tap(find.text('Tema do Aplicativo'));
    await tester.pumpAndSettle();
    expect(find.text('Paleta de cores'), findsOneWidget);
    await tester.tap(find.text('Rosa VetHome'));
    await tester.pumpAndSettle();
    expect(VH.themeSeed.value, VetColors.brown);
    expect(
      find.text('Não foi possível salvar a paleta de cores.'),
      findsOneWidget,
    );
  });

  testWidgets('histórico vazio e suporte exibem o que está disponível', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GabrielaSettingsTab())),
    );
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(
      find.text('Nenhum atendimento verificado disponível.'),
      findsOneWidget,
    );
    expect(find.text('Olivia · atendimento concluído'), findsNothing);
    Navigator.of(tester.element(find.byType(Dialog))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suporte'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'A equipe VetHome ainda não informou os canais oficiais de suporte.',
      ),
      findsOneWidget,
    );
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
          '/gabriela/login': (_) =>
              const Scaffold(body: Text('Login Gabriela')),
        },
      ),
    );
    final exit = find.text('Sair');
    await tester.scrollUntilVisible(exit.hitTestable(), 100);
    await tester.pumpAndSettle();
    expect(exit.hitTestable(), findsOneWidget);
    await tester.tap(exit);
    await tester.pumpAndSettle();
    expect(find.text('Login Gabriela'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PaletteWriteFailure extends InMemorySharedPreferencesStore {
  _PaletteWriteFailure() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}
