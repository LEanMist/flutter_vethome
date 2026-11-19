import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/cadastro_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/widgets/auth/demo_mode_notice.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Login explica que não existem contas individuais', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    expect(find.byType(DemoModeNotice), findsOneWidget);
    expect(find.textContaining('dados fictícios'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(DemoModeNotice)).label.toLowerCase(),
      contains('não há contas individuais'),
    );
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Esqueceu sua senha?'));
    await tester.tap(find.text('Esqueceu sua senha?'));
    await tester.pump();
    expect(
      find.text(
        'A recuperação de senha ainda não está disponível nesta demonstração.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Login informa quando autenticação social não está disponível', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byTooltip('Google'));
    await tester.tap(find.byTooltip('Google'));
    await tester.pump();

    expect(
      find.text(
        'A autenticação com Google não está disponível nesta demonstração.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cadastro avisa para usar dados fictícios', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));

    expect(find.byType(DemoModeNotice), findsOneWidget);
    expect(find.textContaining('dados fictícios'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(DemoModeNotice)).label.toLowerCase(),
      contains('não há contas individuais'),
    );
    expect(tester.takeException(), isNull);
  });
}
