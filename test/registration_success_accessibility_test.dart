import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/sucessoScreen.dart';

void main() {
  testWidgets('anuncia o cadastro concluído quando a mensagem aparece', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const SucessoScreen(saved: true),
        routes: {'/home': (_) => const Scaffold(body: Text('Início'))},
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Usuário cadastrado!'), findsNothing);

    await tester.pumpAndSettle();

    final announcement = find.byKey(
      const ValueKey('registration-success-announcement'),
    );
    expect(
      tester.widget<Semantics>(announcement).properties.label,
      'Cadastro demonstrativo concluído. Os dados foram salvos neste dispositivo; nenhuma conta on-line foi criada.',
    );
    final data = tester.getSemantics(announcement).getSemanticsData();
    expect(
      data.label,
      'Cadastro demonstrativo concluído. Os dados foram salvos neste dispositivo; nenhuma conta on-line foi criada.',
    );
    expect(data.flagsCollection.isLiveRegion, isTrue);
    expect(
      find.text(
        'Perfil salvo neste dispositivo. Esta demonstração não cria contas on-line.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('falha de gravação é anunciada sem afirmar que salvou', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            devicePixelRatio: 1,
            accessibleNavigation: true,
          ),
          child: const SucessoScreen(saved: false),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    final announcement = find.byKey(
      const ValueKey('registration-success-announcement'),
    );
    final label = tester.widget<Semantics>(announcement).properties.label;
    expect(label, contains('Os dados não foram salvos neste dispositivo'));
    expect(
      find.text(
        'Dados disponíveis somente nesta sessão. Não foi possível salvar no dispositivo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cadastro\nconcluído!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navegação acessível espera pelo comando Ir para o início', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            devicePixelRatio: 1,
            accessibleNavigation: true,
          ),
          child: const SucessoScreen(saved: true),
        ),
        routes: {'/home': (_) => const Scaffold(body: Text('Início'))},
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Início'), findsNothing);
    final continueButton = find.byKey(
      const ValueKey('registration-success-continue'),
    );
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Início'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
