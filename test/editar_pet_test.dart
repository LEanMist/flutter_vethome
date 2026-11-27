import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/menu_page.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:flutter_vethome/widgets/editar_pet.dart';

void main() {
  testWidgets('centraliza verticalmente os textos de gênero e peso', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pet = Pet(
      id: 'pet-1',
      usuarioId: 'usuario-1',
      tipo: PetType.gato,
      nome: 'Mimi',
      genero: PetGenero.femea,
      peso: 4,
      dataNascimento: DateTime(2020),
      raca: 'Siamês',
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: EditarPet(pet: pet))),
    );
    for (final titulo in ['Gênero/Sexo', 'Peso']) {
      final campo = find.byWidgetPredicate(
        (widget) => widget is CampoCadastro && widget.titulo == titulo,
      );
      final texto = find.descendant(
        of: campo,
        matching: find.byType(EditableText),
      );
      final icone = find.descendant(of: campo, matching: find.byType(Icon));
      expect(tester.getCenter(texto).dy, closeTo(tester.getCenter(icone).dy, 1));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('edita somente o pet selecionado e atualiza perfil e lista', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuarioId = usuarios.findAll().single.id!;
    final foto = File('assets\\imagens\\cachorro.png').absolute.path;
    final pets = InMemoryPetRepository();
    Pet criarPet(String id, String nome) => Pet(
      id: id,
      usuarioId: usuarioId,
      tipo: PetType.cachorro,
      nome: nome,
      genero: PetGenero.macho,
      peso: 7,
      dataNascimento: DateTime(2020),
      raca: 'Labrador',
      fotoPerfilPath: id == 'max' ? foto : null,
    );
    pets.save(criarPet('max', 'Max'));
    pets.save(criarPet('luna', 'Luna'));

    await tester.pumpWidget(
      MaterialApp(
        home: MenuPage(usuarioRepository: usuarios, usuarioId: usuarioId, petRepository: pets),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Max'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Detalhes'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    Finder campo(String titulo) => find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is CampoCadastro && widget.titulo == titulo,
      ),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(campo('Nome do Cachorro(a)')).controller!.text, 'Max');
    expect(tester.widget<TextField>(campo('Data de Nascimento')).controller!.text, '01/01/2020');
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Excluir')).onPressed, isNull);

    await tester.enterText(campo('Nome do Cachorro(a)'), '');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Nome do animal é obrigatório.'), findsOneWidget);
    expect(pets.findById('max')!.nome, 'Max');

    await tester.enterText(campo('Nome do Cachorro(a)'), 'Fernando');
    await tester.enterText(campo('Peso'), '8,5');
    await tester.enterText(campo('Raça'), 'Poodle');
    await tester.tap(campo('Gênero/Sexo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fêmea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final salvo = pets.findById('max')!;
    expect(salvo.nome, 'Fernando');
    expect(salvo.peso, 8.5);
    expect(salvo.genero, PetGenero.femea);
    expect(salvo.raca, 'Poodle');
    expect(salvo.fotoPerfilPath, foto);
    expect(salvo.usuarioId, usuarioId);
    expect(salvo.tipo, PetType.cachorro);
    expect(pets.findById('luna')!.nome, 'Luna');
    expect(find.text('Fêmea'), findsOneWidget);
    expect(find.text('8.5 kg'), findsOneWidget);
    expect(find.text('Poodle'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Fernando'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Fernando'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelar edição descarta alterações', (tester) async {
    final pet = Pet(
      id: 'pet-1',
      usuarioId: 'usuario-1',
      tipo: PetType.gato,
      nome: 'Mimi',
      genero: PetGenero.femea,
      peso: 4,
      dataNascimento: DateTime(2020),
      raca: 'Siamês',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<Pet>(
                context: context,
                builder: (_) => EditarPet(pet: pet),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Nome do Gato(a)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Outro');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(EditarPet), findsNothing);
    expect(pet.nome, 'Mimi');
  });

  testWidgets('gênero e peso ficam alinhados e gênero cabe em uma linha', (tester) async {
    final pet = Pet(
      id: 'pet-1',
      usuarioId: 'usuario-1',
      tipo: PetType.gato,
      nome: 'Mimi',
      genero: PetGenero.femea,
      peso: 4,
      dataNascimento: DateTime(2020),
      raca: 'Siamês',
    );
    addTearDown(() {
      tester.view.resetViewInsets();
      tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(600, 900));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: EditarPet(pet: pet))));
    Finder campo(String titulo) => find.byWidgetPredicate(
      (widget) => widget is CampoCadastro && widget.titulo == titulo,
    );
    for (final size in [const Size(390, 900), const Size(320, 640), const Size(600, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpAndSettle();
      final genero = campo('Gênero/Sexo');
      final peso = campo('Peso');
      final nome = campo('Nome do Gato(a)');
      final generoRect = tester.getRect(genero);
      final pesoRect = tester.getRect(peso);
      final nomeRect = tester.getRect(nome);
      expect(generoRect.width, greaterThan(pesoRect.width));
      expect(pesoRect.left - generoRect.right, 12);
      expect(generoRect.left, closeTo(nomeRect.left, 0.1));
      expect(pesoRect.right, closeTo(nomeRect.right, 0.1));
      expect(generoRect.top, closeTo(pesoRect.top, 0.1));
      final campoGenero = tester.widget<CampoCadastro>(genero);
      final field = tester.widget<TextField>(
        find.descendant(of: genero, matching: find.byType(TextField)),
      );
      final painter = TextPainter(
        text: TextSpan(text: 'Fêmea', style: field.style),
        textDirection: TextDirection.ltr,
      )..layout();
      expect(field.maxLines, 1);
      expect(painter.width, lessThanOrEqualTo(generoRect.width - campoGenero.paddingTexto!.horizontal));
      painter.dispose();
      expect(tester.takeException(), isNull);
    }
  });
}
