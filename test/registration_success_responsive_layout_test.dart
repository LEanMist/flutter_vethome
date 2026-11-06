import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/sucessoScreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final viewport in [
    const Size(390, 844),
    const Size(390, 640),
    const Size(320, 640),
    const Size(1280, 800),
  ]) {
    testWidgets('SPLASH_REGISTER_CONFIRM cabe em $viewport', (tester) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: SucessoScreen()));
      await tester.pump();

      final frame = tester.getRect(
        find.byKey(const ValueKey('registration-success-figma-frame')),
      );
      final scale = math
          .min(viewport.width / 390, viewport.height / 844)
          .clamp(.5, 1.0)
          .toDouble();
      expect(frame.width, closeTo(390 * scale, .01));
      expect(frame.height, closeTo(844 * scale, .01));
      final confirmation = tester.getRect(find.text('Usuário\nCadastrado!'));
      expect(
        confirmation.bottom,
        lessThanOrEqualTo(frame.bottom + .01),
        reason: 'A mensagem de sucesso precisa caber no quadro da tela.',
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    });
  }
}
