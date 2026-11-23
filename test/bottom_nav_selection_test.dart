import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

void main() {
  testWidgets('cada destino recebe o destaque ao ser selecionado', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => VetBottomNav(
              selectedIndex: selected,
              onSelected: (index) => setState(() => selected = index),
            ),
          ),
        ),
      ),
    );

    const labels = ['Pets', 'Perfil', 'Conversa', 'Agenda', 'Configurações'];
    for (var index = 1; index < labels.length; index++) {
      await tester.tap(find.bySemanticsLabel(labels[index]));
      await tester.pumpAndSettle();
      expect(selected, index);
      final selectedCircle = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(ValueKey('vet-nav-visual-${labels[index]}')),
              matching: find.byType(Container),
            ),
          )
          .singleWhere(
            (container) => container.decoration is inset.BoxDecoration,
          );
      final decoration = selectedCircle.decoration! as inset.BoxDecoration;
      expect((decoration.boxShadow!.single as inset.BoxShadow).inset, isTrue);
      for (var item = 1; item < labels.length; item++) {
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byKey(ValueKey('vet-nav-visual-${labels[item]}')),
            matching: find.byType(Icon),
          ),
        );
        expect(icon.color == Colors.white, item == index);
      }
    }
    await tester.tap(find.bySemanticsLabel('Pets'));
    await tester.pumpAndSettle();
    expect(selected, 0);
    final lastIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const ValueKey('vet-nav-visual-Configurações')),
        matching: find.byType(Icon),
      ),
    );
    expect(lastIcon.color, isNot(Colors.white));
  });
}
