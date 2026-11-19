import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/theme/vet_tones.dart';
import 'package:flutter_vethome/widgets/status_chip.dart';

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
  testWidgets('estados coloridos preservam contraste nos cartões rosa', (
    tester,
  ) async {
    const statuses = [
      (
        label: 'Confirmado',
        tone: VetTones.success,
        foreground: VetTones.successForeground,
      ),
      (
        label: 'Pendente',
        tone: VetTones.warning,
        foreground: VetTones.warningForeground,
      ),
      (
        label: 'Informação',
        tone: VetTones.info,
        foreground: VetTones.infoForeground,
      ),
    ];
    const cardRoseOpacity = [.16, .17, .18, .28];

    for (final status in statuses) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusChip(
              status.label,
              status.tone,
              dense: true,
              textColor: status.foreground,
            ),
          ),
        ),
      );
      final label = tester.widget<Text>(find.text(status.label));
      expect(label.style?.color, status.foreground);

      for (final roseOpacity in cardRoseOpacity) {
        final cardSurface = Color.alphaBlend(
          VetColors.rose.withValues(alpha: roseOpacity),
          VetColors.pink,
        );
        final chipSurface = Color.alphaBlend(
          status.tone.withValues(alpha: .15),
          cardSurface,
        );
        expect(
          _contrastRatio(status.foreground, chipSurface),
          greaterThanOrEqualTo(4.5),
          reason: '${status.label}, cartão rosa com opacidade $roseOpacity',
        );
      }
    }
  });
}
