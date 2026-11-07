import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    VetRepository.clientEmail = 'pessoa-a@example.test';
  });

  testWidgets('login explica quando o e-mail não é o perfil local', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const LoginPage(),
        routes: {'/home': (_) => const Scaffold(body: Text('Home aberta'))},
      ),
    );
    await tester.pumpAndSettle();

    Finder field(String hint) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
    );

    await tester.enterText(field('Usuário'), 'pessoa-b@example.test');
    await tester.enterText(field('Senha'), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Este protótipo mantém um perfil local. Use o e-mail salvo neste dispositivo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Home aberta'), findsNothing);
  });
}
