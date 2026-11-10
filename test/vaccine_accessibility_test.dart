import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/vacinacao_page.dart';
import 'package:flutter_vethome/widgets.dart';

class _InMemoryVaccineStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await VetRepository.initialize(storage: _InMemoryVaccineStorage());
  });

  Future<void> openVaccination(
    WidgetTester tester,
    Size viewport,
    double scale,
  ) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: VacinacaoPage(pet: VetRepository.pets.first),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder vaccineInput(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is VHField && widget.label == label,
    ),
    matching: find.byType(TextFormField),
  );

  for (final viewport in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1280, 800),
  ]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('Vacinação em $viewport com texto ${scale}x: tela e editor', (
        tester,
      ) async {
        await openVaccination(tester, viewport, scale);
        expect(find.text('Carteira de vacinação'), findsOneWidget);
        final add = find.widgetWithText(TextButton, 'Adicionar vacina');
        expect(add, findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(add);
        await tester.tap(add);
        await tester.pumpAndSettle();

        expect(find.text('Salvar vacina'), findsOneWidget);
        for (final label in [
          'Nome da vacina',
          'Data aplicada',
          'Próxima dose (opcional)',
        ]) {
          final input = vaccineInput(label);
          expect(input, findsOneWidget);
          expect(tester.widget<TextFormField>(input).enabled, isNot(false));
          await tester.ensureVisible(input);
          await tester.pumpAndSettle();

          RenderEditable? locateEditor(RenderObject object) {
            if (object is RenderEditable) return object;
            RenderEditable? found;
            object.visitChildren((child) {
              found ??= locateEditor(child);
            });
            return found;
          }

          final editable = find.descendant(
            of: input,
            matching: find.byType(EditableText),
          );
          expect(editable, findsOneWidget);
          final render = locateEditor(tester.renderObject(editable));
          expect(render, isNotNull);
          expect(
            render!.size.height,
            greaterThanOrEqualTo(render.preferredLineHeight - 1),
            reason: 'Campo $label deve comportar uma linha em ${scale}x',
          );
          expect(tester.takeException(), isNull);
        }

        // Exercita a validação sem alterar os dados do pet.
        await tester.ensureVisible(find.text('Salvar vacina'));
        await tester.tap(find.text('Salvar vacina'));
        await tester.pumpAndSettle();
        expect(find.text('Informe o nome da vacina.'), findsOneWidget);
        expect(find.text('Informe uma data válida até hoje.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('opções da vacina têm alvo de 48 px sem overflow', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    VetRepository.saveVaccine(
      pet.id,
      Vacina(
        nome: 'Vacina múltipla para cães',
        aplicada: DateUtils.dateOnly(DateTime.now()),
      ),
    );

    for (final viewport in [
      const Size(320, 640),
      const Size(390, 844),
      const Size(1280, 800),
    ]) {
      await openVaccination(tester, viewport, 1.0);
      final options = find.byTooltip(
        'Opções da vacina Vacina múltipla para cães',
      );
      await tester.ensureVisible(options);
      await tester.pumpAndSettle();

      final target = tester.getRect(options);
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'vacinas demonstrativas são identificadas e ordenadas pelo vencimento',
    (tester) async {
      await openVaccination(tester, const Size(390, 844), 1.0);
      final semantics = tester.ensureSemantics();
      try {
        expect(
          find.bySemanticsLabel(RegExp(r'^Vacina demonstrativa:')),
          findsNWidgets(3),
        );

        final giardiaTop = tester.getTopLeft(find.text('Giardia')).dy;
        final v10Top = tester.getTopLeft(find.text('V10')).dy;
        final rabiesTop = tester.getTopLeft(find.text('Antirrábica')).dy;
        expect(giardiaTop, lessThan(v10Top));
        expect(v10Top, lessThan(rabiesTop));
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
}
