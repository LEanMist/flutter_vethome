import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/core/utils/photo_picker.dart';

void main() {
  Future<void> openPhotoPicker(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => pickLocalPhoto(context),
              child: const Text('Abrir seletor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
  }

  testWidgets(
    kIsWeb
        ? 'navegador no Windows oferece câmera e galeria'
        : 'Windows nativo oferece somente a galeria',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await openPhotoPicker(tester);

        expect(
          find.byIcon(Icons.photo_camera),
          kIsWeb ? findsOneWidget : findsNothing,
        );
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform oferece câmera e galeria', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await openPhotoPicker(tester);

        expect(find.byIcon(Icons.photo_camera), findsOneWidget);
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
