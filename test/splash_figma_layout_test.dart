import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/routes/app_routes.dart';
import 'package:flutter_vethome/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final viewport in [
    const Size(390, 844),
    const Size(320, 640),
    const Size(640, 300),
    const Size(1280, 800),
  ]) {
    testWidgets('SPLASH_START acompanha o frame em $viewport', (tester) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          initialRoute: '/',
          routes: AppRoutes.routes,
        ),
      );
      await tester.pump();

      final scale =
          (viewport.width / 390 < viewport.height / 844
                  ? viewport.width / 390
                  : viewport.height / 844)
              .clamp(0.0, 1.0)
              .toDouble();
      final frame = tester.getRect(
        find.byKey(const ValueKey('splash-figma-frame')),
      );
      final clip = tester.widget<ClipRRect>(
        find.byKey(const ValueKey('splash-figma-clip')),
      );
      expect(clip.borderRadius, BorderRadius.circular(30 * scale));
      final surface = tester.widget<ColoredBox>(
        find.byKey(const ValueKey('splash-figma-surface')),
      );
      expect(surface.color, VH.background);
      final group = tester.getRect(
        find.byKey(const ValueKey('splash-logo-group')),
      );
      final logo = tester.getRect(find.byKey(const ValueKey('splash-logo')));
      final logoClip = tester.widget<ClipRRect>(
        find.byKey(const ValueKey('splash-logo-clip')),
      );
      final ring = tester.getRect(
        find.byKey(const ValueKey('splash-logo-ring')),
      );

      expect(frame.width, closeTo(390 * scale, .01));
      expect(frame.height, closeTo(844 * scale, .01));
      expect(group.left - frame.left, closeTo(20 * scale, .01));
      expect(group.top - frame.top, closeTo(250 * scale, .01));
      expect(group.width, closeTo(350 * scale, .01));
      expect(group.height, closeTo(350 * scale, .01));
      expect(logo.width, closeTo(350 * scale, .01));
      expect(logo.height, closeTo(350 * scale, .01));
      expect(logoClip.borderRadius, BorderRadius.circular(200 * scale));
      expect(
        tester.widget<Image>(find.byKey(const ValueKey('splash-logo'))).fit,
        BoxFit.cover,
      );
      final logoImage = tester.widget<Image>(
        find.byKey(const ValueKey('splash-logo')),
      );
      expect(
        (logoImage.image as AssetImage).assetName,
        'assets/imagens/figma/splash-start-logo.png',
      );
      final ringImage = tester.widget<Image>(
        find.byKey(const ValueKey('splash-logo-ring')),
      );
      expect(
        (ringImage.image as AssetImage).assetName,
        'assets/imagens/figma/splash-start-ring.png',
      );
      expect(ring.left - group.left, closeTo(24.37 * scale, .01));
      expect(ring.top - group.top, closeTo(24.37 * scale, .01));
      expect(ring.width, closeTo(300.158 * scale, .01));
      expect(ring.height, closeTo(300.158 * scale, .01));
      expect(find.bySemanticsLabel('VetHome'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 1499));
      expect(find.byType(LoginPage), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byKey(const ValueKey('splash-figma-frame')), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(LoginPage))).canPop(),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('SPLASH_START não troca uma rota aberta sobre a entrada', (
    tester,
  ) async {
    final routes = AppRoutes.routes;
    expect(routes.containsKey('/landing'), isFalse);
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/revisao',
        routes: {
          ...routes,
          '/revisao': (_) => const Scaffold(body: Text('Tela aberta por link')),
        },
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Tela aberta por link'), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('splash-figma-frame')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
