import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/servicos_page.dart';

void main() {
  testWidgets('shows dog exams and scrolls within the expanded panel', (
    tester,
  ) async {
    await _abrirCategoria(tester, PetType.cachorro, CategoriaServico.exames);

    expect(find.text('Hemograma'), findsOneWidget);
    expect(find.text('Ureia e creatinina'), findsOneWidget);
    expect(find.text('ALT e GGT'), findsOneWidget);
    expect(find.text('FIV e FeLV'), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('lista-servicos-exames')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coproparasitológico'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows cat exams including FIV and FeLV when scrolled', (
    tester,
  ) async {
    await _abrirCategoria(tester, PetType.gato, CategoriaServico.exames);

    expect(find.text('Ureia e creatinina'), findsOneWidget);
    expect(find.text('FIV e FeLV'), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('lista-servicos-exames')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.text('FIV e FeLV'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows dog vaccines and scrolls to the remaining options', (
    tester,
  ) async {
    await _abrirCategoria(tester, PetType.cachorro, CategoriaServico.vacinas);

    expect(find.text('V8 e V10'), findsOneWidget);
    expect(find.text('Cinomose'), findsOneWidget);
    expect(find.text('Parvovirose'), findsOneWidget);
    expect(find.text('Gripe dos canis'), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('lista-servicos-vacinas')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gripe dos canis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows cat vaccines and scrolls to V5 and antirrábica', (
    tester,
  ) async {
    await _abrirCategoria(tester, PetType.gato, CategoriaServico.vacinas);

    expect(find.text('V3'), findsOneWidget);
    expect(find.text('Calicivirose'), findsOneWidget);
    expect(find.text('Rinotraqueíte'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('lista-servicos-vacinas')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('V5'), findsOneWidget);
    expect(find.text('Antirrábica'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _abrirCategoria(
  WidgetTester tester,
  PetType petTipo,
  CategoriaServico categoria,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: ServicosPage(
        rascunho: AgendamentoRascunho(
          usuarioId: 'usuario-teste',
          petId: 'pet-teste',
          data: DateTime.now(),
          horario: '12:00',
        ),
        petNome: petTipo == PetType.gato ? 'Mimi' : 'Rex',
        petTipo: petTipo,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(
    find.byKey(ValueKey('icone-pet-${petTipo.name}')),
    findsOneWidget,
  );
  final imagem = tester.widget<Image>(
    find.byKey(ValueKey('icone-pet-${petTipo.name}')),
  );
  expect(
    (imagem.image as AssetImage).assetName,
    petTipo == PetType.gato
        ? 'assets/imagens/gato.png'
        : 'assets/imagens/cachorro.png',
  );
  expect(find.text(petTipo == PetType.gato ? 'Mimi' : 'Rex'), findsOneWidget);
  expect(tester.takeException(), isNull, reason: 'initial render');
  await tester.tap(find.byKey(ValueKey('categoria-${categoria.name}')));
  await tester.pumpAndSettle();
  final listaServicos = find.byKey(
    ValueKey('lista-servicos-${categoria.name}'),
  );
  expect(tester.widget<ListView>(listaServicos).padding, EdgeInsets.zero);
  final scrollbarFinder = find.ancestor(
    of: listaServicos,
    matching: find.byType(Scrollbar),
  );
  expect(tester.widget<Scrollbar>(scrollbarFinder).thumbVisibility, isTrue);
  expect(
    tester.getSize(listaServicos).height,
    lessThanOrEqualTo(_alturaPainelServicos),
  );
  expect(tester.takeException(), isNull, reason: 'expanded category render');
}

const _alturaPainelServicos = 144.0;