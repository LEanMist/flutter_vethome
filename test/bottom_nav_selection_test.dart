import 'package:flutter/material.dart';
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
      for (var item = 1; item < labels.length; item++) {
        final visual = tester.widget<Container>(
          find.byKey(ValueKey('vet-nav-visual-${labels[item]}')),
        );
        final decoration = visual.foregroundDecoration! as BoxDecoration;
        expect(decoration.border != null, item == index);
      }
    }
    await tester.tap(find.bySemanticsLabel('Pets'));
    await tester.pumpAndSettle();
    expect(selected, 0);
    final lastVisual = tester.widget<Container>(
      find.byKey(const ValueKey('vet-nav-visual-Configurações')),
    );
    expect((lastVisual.foregroundDecoration! as BoxDecoration).border, isNull);
  });
}
