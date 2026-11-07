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
        home: const SucessoScreen(),
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
}
