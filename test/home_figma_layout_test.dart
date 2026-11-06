import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/home_page.dart';
import 'package:flutter_vethome/routes/app_routes.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a rota /home está registrada', () {
    expect(AppRoutes.routes.containsKey('/home'), isTrue);
  });

  for (final viewport in [
    const Size(390, 844),
    const Size(320, 640),
    const Size(1280, 800),
  ]) {
    testWidgets('HOME_PAGE_2 acompanha o frame em $viewport', (tester) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      final scale =
          (viewport.width / 390 < viewport.height / 844
                  ? viewport.width / 390
                  : viewport.height / 844)
              .clamp(.5, 1.0)
              .toDouble();
      final frame = tester.getRect(
        find.byKey(const ValueKey('home-figma-frame')),
      );
      expect(frame.width, closeTo(390 * scale, .01));
      expect(frame.height, closeTo(844 * scale, .01));
      final systemUi = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );
      expect(systemUi.value.systemNavigationBarColor, VetColors.pink);
      expect(systemUi.value.systemNavigationBarIconBrightness, Brightness.dark);
      expect(systemUi.value.systemNavigationBarContrastEnforced, isFalse);

      final illustration = tester.getRect(
        find.byKey(const ValueKey('home-walk-illustration')),
      );
      expect(illustration.left - frame.left, closeTo(-6 * scale, .01));
      expect(illustration.top - frame.top, closeTo(70 * scale, .01));
      expect(illustration.width, closeTo(400 * scale, .01));
      expect(illustration.height, closeTo(400 * scale, .01));

      final panel = tester.getRect(
        find.byKey(const ValueKey('home-welcome-panel')),
      );
      expect(panel.left - frame.left, closeTo(0, .01));
      expect(panel.top - frame.top, closeTo(415 * scale, .01));
      expect(panel.width, closeTo(390 * scale, .01));
      expect(panel.height, closeTo(429 * scale, .01));
      final panelContainer = tester.widget<Container>(
        find.byKey(const ValueKey('home-welcome-panel')),
      );
      final panelDecoration = panelContainer.decoration! as BoxDecoration;
      expect(panelDecoration.color, VetColors.pink);
      expect(
        panelDecoration.borderRadius,
        BorderRadius.only(
          topLeft: Radius.circular(50 * scale),
          topRight: Radius.circular(50 * scale),
          bottomLeft: Radius.circular(30 * scale),
          bottomRight: Radius.circular(30 * scale),
        ),
      );

      final title = tester.getRect(find.byKey(const ValueKey('home-title')));
      expect(title.top - frame.top, closeTo(458 * scale, 1));
      final titleText = tester.widget<Text>(
        find.byKey(const ValueKey('home-title')),
      );
      expect(titleText.style?.color, VetColors.brown);
      expect(titleText.style?.fontFamily, VH.headingFontFamily);
      expect(titleText.style?.fontSize, 30 * scale);
      final titleSpan = titleText.textSpan! as TextSpan;
      final firstTitleWord = titleSpan.children![0] as TextSpan;
      final remainingTitle = titleSpan.children![1] as TextSpan;
      expect(firstTitleWord.text, 'Seja ');
      expect(firstTitleWord.style?.fontWeight, FontWeight.w600);
      expect(remainingTitle.text, 'Bem Vindo!');
      expect(remainingTitle.style?.fontWeight, FontWeight.bold);
      expect(find.text('Cuidando de quem\nte faz sorrir'), findsOneWidget);

      final profile = tester.getRect(
        find.byKey(const ValueKey('home-profile-chip')),
      );
      expect(profile.left - frame.left, closeTo(242 * scale, .01));
      expect(profile.top - frame.top, closeTo(14 * scale, .01));
      expect(profile.width, closeTo(136 * scale, .01));
      expect(profile.height, closeTo(56 * scale, .01));
      final profilePill = tester.widget<Container>(
        find.byKey(const ValueKey('home-profile-pill')),
      );
      final profileDecoration = profilePill.decoration! as BoxDecoration;
      expect(profileDecoration.color, VetColors.roseOverlay50);
      expect(
        profileDecoration.borderRadius,
        BorderRadius.circular(100 * scale),
      );
      expect(profileDecoration.boxShadow?.single.offset, const Offset(2, 2));
      final userName = tester.widget<Text>(
        find.byKey(const ValueKey('home-user-name')),
      );
      expect(userName.style?.fontFamily, VH.bodyFontFamily);
      expect(userName.style?.fontSize, 14 * scale);

      final play = tester.getRect(find.byKey(const ValueKey('home-open-pets')));
      expect(play.left - frame.left, closeTo(117 * scale, .01));
      expect(play.top - frame.top, closeTo(591 * scale, .01));
      expect(play.width, closeTo(155 * scale, .01));
      expect(play.height, closeTo(155 * scale, .01));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('HOME_PAGE_2 leva o chip ao Perfil e o play a Pets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const HomePage(),
        routes: {
          '/perfil': (_) => const Scaffold(body: Text('Destino Perfil')),
          '/pets': (_) => const Scaffold(body: Text('Destino Pets')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Abrir área dos pets'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-profile-chip')));
    await tester.pumpAndSettle();
    expect(find.text('Destino Perfil'), findsOneWidget);

    Navigator.of(tester.element(find.text('Destino Perfil'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-open-pets')));
    await tester.pumpAndSettle();
    expect(find.text('Destino Pets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
