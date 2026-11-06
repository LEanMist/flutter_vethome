import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + .05) / (darker + .05);
}

void main() {
  testWidgets('texto dos exames nos cartões da Agenda tem contraste AA', (
    tester,
  ) async {
    for (final size in const [Size(390, 844), Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          home: AgendaScreen(initialDate: DateTime(2026, 1, 13)),
        ),
      );
      await tester.pumpAndSettle();

      for (final label in ['Hemograma', 'Urina', 'Creatinina']) {
        final text = tester.widget<Text>(find.text(label));
        final foreground = text.style!.color!;
        expect(foreground, VetColors.calendarTextOnRose);
        expect(
          _contrastRatio(foreground, VetColors.rose),
          greaterThanOrEqualTo(4.5),
          reason: '$label em ${size.width} px',
        );
      }
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
