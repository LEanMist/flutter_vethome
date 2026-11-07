import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/widgets/figma_action_target.dart';

void main() {
  testWidgets(
    'alvo de 48 px preserva o botão visual e recebe toque adicional',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var taps = 0;
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: FigmaActionTarget(
                  key: const ValueKey('save-target'),
                  width: 90,
                  label: 'Salvar',
                  onPressed: () => taps++,
                  child: SizedBox(
                    width: 90,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () => taps++,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Salvar'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final target = find.byKey(const ValueKey('save-target'));
        final visual = find.widgetWithText(ElevatedButton, 'Salvar');
        final targetRect = tester.getRect(target);
        final visualRect = tester.getRect(visual);
        expect(targetRect.size, const Size(90, 48));
        expect(visualRect.size, const Size(90, 34));
        expect(visualRect.top, targetRect.bottom - 34);

        final semanticsFinder = find.bySemanticsLabel('Salvar');
        expect(semanticsFinder, findsOneWidget);
        final node = tester.getSemantics(semanticsFinder).getSemanticsData();
        expect(node.label, 'Salvar');
        expect(node.flagsCollection.isButton, isTrue);
        expect(node.hasAction(SemanticsAction.tap), isTrue);

        await tester.tapAt(Offset(targetRect.center.dx, targetRect.top + 5));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
}
