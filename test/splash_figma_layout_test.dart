import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/splashScreen.dart';
import 'package:flutter_vethome/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final viewport in [
    const Size(390, 844),
    const Size(320, 640),
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
          home: const SplashScreen(),
        ),
      );
      await tester.pump();

      final scale =
          (viewport.width / 390 < viewport.height / 844
                  ? viewport.width / 390
                  : viewport.height / 844)
              .clamp(.5, 1.0)
              .toDouble();
      final frame = tester.getRect(
        find.byKey(const ValueKey('splash-figma-frame')),
      );
      final group = tester.getRect(
        find.byKey(const ValueKey('splash-logo-group')),
      );
      final logo = tester.getRect(find.byKey(const ValueKey('splash-logo')));
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
      expect(ring.left - group.left, closeTo(24.37 * scale, .01));
      expect(ring.top - group.top, closeTo(24.37 * scale, .01));
      expect(ring.width, closeTo(300.158 * scale, .01));
      expect(ring.height, closeTo(300.158 * scale, .01));
      expect(find.bySemanticsLabel('VetHome'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // A tela agenda a ida ao login; descarte-a e avance o relógio para
      // concluir o Timer pendente sem navegar para outra rota durante o teste.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    });
  }
}
