import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/landing_page.dart';
import 'package:flutter_vethome/pages/splashScreen.dart';
import 'package:flutter_vethome/pages/start_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final montserrat = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/MontserratVariable.ttf'));
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
    final raleway = FontLoader('Raleway')
      ..addFont(rootBundle.load('assets/fonts/RalewayVariable.ttf'));
    await Future.wait([montserrat.load(), poppins.load(), raleway.load()]);
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
    expect(find.text('Atendimento a\ndomicilio'), findsOneWidget);
    expect(find.text('Exames'), findsOneWidget);
    expect(find.text('Vacinas'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(5));
    final title = tester.widget<Text>(
      find.text('Escolha o melhor\npara o seu Pet'),
    );
    expect(title.style?.fontFamily, 'Montserrat');
    expect(title.style?.fontWeight, FontWeight.w700);

    final servicesHeading = tester.widget<Text>(find.text('NOSSOS SERVIÇOS'));
    expect(servicesHeading.style?.fontFamily, 'Poppins');
    expect(servicesHeading.style?.fontWeight, FontWeight.w600);

    final serviceLabel = tester.widget<Text>(find.text('Exames'));
    expect(serviceLabel.style?.fontFamily, 'Poppins');
    expect(serviceLabel.style?.fontWeight, FontWeight.w500);

    final navigationLabel = tester.widget<Text>(find.text('Home'));
    expect(navigationLabel.style?.fontFamily, 'Raleway');
    expect(navigationLabel.style?.fontWeight, FontWeight.w700);

    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! Container || widget.decoration is! BoxDecoration) {
          return false;
        }
        return (widget.decoration! as BoxDecoration).boxShadow?.length == 6;
      }),
      findsNWidgets(3),
    );
    expect(find.byType(ClipPath), findsOneWidget);
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
