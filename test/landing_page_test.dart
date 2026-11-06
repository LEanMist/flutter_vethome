import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/landing_page.dart';
import 'package:flutter_vethome/pages/splashScreen.dart';
import 'package:flutter_vethome/pages/start_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final montserrat = FontLoader('MontserratAlternates')
      ..addFont(rootBundle.load('assets/fonts/MontserratAlternatesRegular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/MontserratAlternatesMedium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/MontserratAlternatesBold.ttf'));
    await montserrat.load();
  });

  testWidgets('landing desktop mantém o frame e conteúdo do Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1543, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LandingPage()));

    expect(find.byKey(const ValueKey('landing-figma-frame')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('landing-figma-frame'))),
      LandingPage.designSize,
    );
    expect(find.text('Escolha o melhor\npara o seu Pet'), findsOneWidget);
    expect(find.text('NOSSOS SERVIÇOS'), findsOneWidget);
    expect(find.text('Atendimento a\ndomicílio'), findsOneWidget);
    expect(find.text('Exames'), findsOneWidget);
    expect(find.text('Vacinas'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('entrada larga mostra landing e entrada móvel conserva Splash', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpWidget(const MaterialApp(home: StartPage()));
    expect(find.byType(LandingPage), findsOneWidget);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(
      MaterialApp(
        home: const StartPage(),
        routes: {'/login': (_) => const Scaffold(body: Text('login route'))},
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('login route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
