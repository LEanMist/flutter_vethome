import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/saude_page.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/vet/vet_card.dart';
import 'package:flutter_vethome/widgets/vet/vet_bottom_nav.dart';

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
  testWidgets('Resumo de saúde anuncia cada indicador com seu valor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(home: SaudePage(pet: VetRepository.pets.first)),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp(r'^Vacinação: \d+/\d+ em dia$')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'^Peso: .+')), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Vermifugação: dado demonstrativo; não há data real cadastrada.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('Descrição do histórico mantém contraste legível', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    final description = VetRepository.consultas(pet.id).first.descricao;
    await tester.pumpWidget(MaterialApp(home: SaudePage(pet: pet)));
    await tester.pumpAndSettle();

    final descriptionText = tester.widget<Text>(find.text(description));
    expect(descriptionText.style?.color, VetColors.brown);
  });

  testWidgets('Seções de Saúde são cabeçalhos semânticos no mobile e desktop', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final headings = {
        'health-summary-heading': 'Resumo de saúde',
        'appointments-history-heading': 'Histórico de atendimentos',
      };

      for (final viewport in [const Size(390, 844), const Size(1024, 800)]) {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(home: SaudePage(pet: VetRepository.pets.first)),
        );
        await tester.pumpAndSettle();

        for (final entry in headings.entries) {
          final heading = find.byKey(ValueKey(entry.key));
          expect(find.text(entry.value), findsOneWidget, reason: '$viewport');
          expect(
            tester.widget<Semantics>(heading).properties.header,
            isTrue,
            reason: '${entry.value} em $viewport',
          );
          expect(
            tester
                .getSemantics(heading)
                .getSemanticsData()
                .flagsCollection
                .isHeader,
            isTrue,
            reason: '${entry.value} em $viewport',
          );
        }
        expect(tester.takeException(), isNull, reason: '$viewport');
      }
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'Histórico anuncia data, situação, tipo, veterinário e descrição',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();

      final pet = VetRepository.pets.first;
      await tester.pumpWidget(MaterialApp(home: SaudePage(pet: pet)));
      await tester.pumpAndSettle();

      final first = VetRepository.consultas(pet.id).first;
      expect(
        VetRepository.consultas(pet.id).every((c) => c.isDemonstration),
        isTrue,
      );
      final expected = RegExp(
        '^Atendimento demonstrativo; não representa um registro clínico real\\. '
        'Data ilustrativa: .+\\. ${RegExp.escape(first.tipo)}\\. '
        'Veterinário de exemplo: ${RegExp.escape(first.veterinario)}\\. '
        'Descrição de exemplo: ${RegExp.escape(first.descricao)}',
      );
      await tester.ensureVisible(find.text(first.tipo).first);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(expected), findsOneWidget);
      expect(find.text('Demonstração'), findsNWidgets(4));
      semantics.dispose();
    },
  );
  testWidgets(
    'Cartões informativos não capturam Tab e navegação permanece focalizável',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(home: SaudePage(pet: VetRepository.pets.first)),
      );
      await tester.pumpAndSettle();

      final infoCards = [
        find
            .ancestor(
              of: find.text('Peso').first,
              matching: find.byType(VetCard),
            )
            .first,
        find
            .ancestor(
              of: find.text('Consulta Geral').first,
              matching: find.byType(VetCard),
            )
            .first,
      ];
      for (final card in infoCards) {
        final ink = find.descendant(of: card, matching: find.byType(InkWell));
        expect(ink, findsOneWidget);
        final inkwell = tester.widget<InkWell>(ink);
        expect(inkwell.onTap, isNull);
        expect(inkwell.canRequestFocus, isFalse);
      }

      final navElement = tester.element(find.byType(VetBottomNav));
      bool focusIsInNavigation() {
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused == null) return false;
        if (identical(focused, navElement)) return true;
        var inside = false;
        focused.visitAncestorElements((ancestor) {
          if (identical(ancestor, navElement)) {
            inside = true;
            return false;
          }
          return true;
        });
        return inside;
      }

      var navigationFocused = focusIsInNavigation();
      for (var step = 0; step < 25 && !navigationFocused; step++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        navigationFocused = focusIsInNavigation();
      }
      expect(navigationFocused, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
