import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/saude_page.dart';
import 'package:flutter_vethome/widgets/vet/vet_card.dart';

void main() {
  testWidgets('Saúde respeita TextScaler sem reduzir valores nem transbordar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pet = VetRepository.pets.first;
    final heights = <double, Map<String, double>>{};
    final titleHeights = <double, Map<String, double>>{};
    final violations = <String>[];

    for (final factor in [1.0, 1.5, 2.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData.fromView(
              tester.view,
            ).copyWith(textScaler: TextScaler.linear(factor)),
            child: SaudePage(pet: pet),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final measured = <String, double>{};
      final measuredTitles = <String, double>{};
      for (final title in ['Vacinação', 'Peso', 'Vermifugação']) {
        final statusCard = find
            .ancestor(
              of: find.text(title).first,
              matching: find.byType(VetCard),
            )
            .first;
        final titleText = find.descendant(
          of: statusCard,
          matching: find.text(title),
        );
        expect(titleText, findsOneWidget);
        expect(
          tester.renderObject<RenderParagraph>(titleText).didExceedMaxLines,
          isFalse,
        );
        measuredTitles[title] = tester.getRect(titleText).height;
        final fittedValue = find.descendant(
          of: statusCard,
          matching: find.byType(FittedBox),
        );
        expect(fittedValue, factor == 1.0 ? findsOneWidget : findsNothing);
        final textValue = find
            .descendant(of: statusCard, matching: find.byType(Text))
            .last;
        expect(
          tester.renderObject<RenderParagraph>(textValue).didExceedMaxLines,
          isFalse,
        );
        measured[title] = tester.getRect(textValue).height;
      }
      heights[factor] = measured;
      titleHeights[factor] = measuredTitles;

      final layoutError = tester.takeException();
      if (layoutError != null) {
        violations.add('TextScaler $factor: overflow/erro de layout');
      }
      // ignore: avoid_print
      print(
        'SAUDE_ESCALA $factor: valores=$measured; títulos=$measuredTitles; erro=${layoutError != null}',
      );
    }

    for (final factor in [1.5, 2.0]) {
      final minimumRatio = factor == 1.5 ? 1.35 : 1.7;
      for (final title in titleHeights[1.0]!.keys) {
        final baselineTitle = titleHeights[1.0]![title]!;
        final enlargedTitle = titleHeights[factor]![title]!;
        if (enlargedTitle < baselineTitle * minimumRatio) {
          violations.add(
            'TextScaler $factor: título $title não ampliou como esperado '
            '(${enlargedTitle.toStringAsFixed(1)} vs '
            '${baselineTitle.toStringAsFixed(1)} em 1x)',
          );
        }
      }
      for (final title in heights[1.0]!.keys) {
        final baseline = heights[1.0]![title]!;
        final amplified = heights[factor]![title]!;
        if (amplified < baseline * minimumRatio) {
          violations.add(
            'TextScaler $factor: $title ficou com altura '
            '${amplified.toStringAsFixed(1)} vs '
            '${baseline.toStringAsFixed(1)} em 1x '
            '(mínimo proporcional ${minimumRatio}x)',
          );
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Falhas de acessibilidade textual na tela Saúde: '
          '${violations.join("; ")}',
    );
  });
}
