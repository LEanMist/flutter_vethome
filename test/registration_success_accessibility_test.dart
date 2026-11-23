import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/sucessoScreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Comfortaa',
    )..addFont(rootBundle.load('assets/fonts/ComfortaaBold.ttf'))).load();
    await (FontLoader('MontserratAlternates')..addFont(
          rootBundle.load('assets/fonts/MontserratAlternatesRegular.ttf'),
        ))
        .load();
  });
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
        routes: {'/pets': (_) => const Scaffold(body: Text('Início'))},
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

  testWidgets('navegação acessível espera pelo comando Ir para Pets', (
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
        routes: {'/pets': (_) => const Scaffold(body: Text('Início'))},
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

  testWidgets(
    'avanço automático respeita acessibilidade ativada durante a espera',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var accessibleNavigation = false;
      late StateSetter updateMediaQuery;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              updateMediaQuery = setState;
              return MediaQuery(
                data: MediaQueryData(
                  size: const Size(390, 844),
                  devicePixelRatio: 1,
                  accessibleNavigation: accessibleNavigation,
                ),
                child: const SucessoScreen(saved: true),
              );
            },
          ),
          routes: {'/pets': (_) => const Scaffold(body: Text('Início'))},
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      updateMediaQuery(() => accessibleNavigation = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump();

      expect(find.text('Início'), findsNothing);
      expect(
        find.byKey(const ValueKey('registration-success-continue')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('fluxo comum vai para Início após a confirmação', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const SucessoScreen(saved: true),
        routes: {'/pets': (_) => const Scaffold(body: Text('Início'))},
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (viewport, textScale) in const [
    (Size(390, 844), 1.0),
    (Size(320, 667), 1.0),
    (Size(390, 640), 1.0),
    (Size(320, 320), 1.0),
    (Size(390, 844), 2.0),
    (Size(320, 640), 2.0),
  ]) {
    testWidgets('ações cabem sem sobreposição em $viewport a ${textScale}x', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: viewport,
              devicePixelRatio: 1,
              accessibleNavigation: true,
              textScaler: TextScaler.linear(textScale),
            ),
            child: const SucessoScreen(saved: true),
          ),
          routes: {'/pets': (_) => const Scaffold(body: Text('Início'))},
        ),
      );
      await tester.pumpAndSettle();

      final frame = tester.getRect(
        find.byKey(const ValueKey('registration-success-figma-frame')),
      );
      final confirmation = tester.getRect(find.text('Usuário\nCadastrado!'));
      final continueButton = tester.getRect(
        find.byKey(const ValueKey('registration-success-continue')),
      );
      final notice = tester.getRect(
        find.text(
          'Perfil salvo neste dispositivo. Esta demonstração não cria contas on-line.',
        ),
      );

      expect(continueButton.height, greaterThanOrEqualTo(48 - .01));
      expect(continueButton.top, greaterThanOrEqualTo(confirmation.bottom));
      if (viewport == const Size(390, 844) || textScale >= 2) {
        expect(
          continueButton.top - confirmation.bottom,
          greaterThanOrEqualTo(8),
        );
      }
      expect(notice.top, greaterThanOrEqualTo(continueButton.bottom));
      if (textScale >= 2) {
        final noticeText = find.text(
          'Perfil salvo neste dispositivo. Esta demonstração não cria contas on-line.',
        );
        await tester.ensureVisible(noticeText);
        await tester.pumpAndSettle();
        expect(
          tester.getBottomRight(noticeText).dy,
          lessThanOrEqualTo(frame.bottom + .01),
        );
      } else {
        expect(notice.bottom, lessThanOrEqualTo(frame.bottom + .01));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
