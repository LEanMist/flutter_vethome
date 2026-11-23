import 'package:flutter_vethome/auth/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/demo_auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    VetRepository.clientEmail = 'pessoa-a@example.test';
  });

  testWidgets(
    'login rejeita e-mail diferente do perfil local e das contas de demonstração',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: demoLogin(),
          routes: {'/pets': (_) => const Scaffold(body: Text('Pets aberta'))},
        ),
      );
      await tester.pumpAndSettle();

      Finder field(String hint) => find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == hint,
      );

      await tester.enterText(field('Usuário'), 'pessoa-b@example.test');
      await tester.enterText(field('Senha'), DemoAuthentication.demoPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
      expect(find.text('Pets aberta'), findsNothing);
    },
  );
}
