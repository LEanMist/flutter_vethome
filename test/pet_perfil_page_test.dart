import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/menu_page.dart';
import 'package:flutter_vethome/pages/pet_perfil_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/widgets/etiqueta_perfil.dart';

Pet _pet(String id, String nome, String usuarioId) => Pet(
  id: id,
  usuarioId: usuarioId,
  tipo: PetType.cachorro,
  nome: nome,
  genero: PetGenero.macho,
  peso: 7,
  dataNascimento: DateTime(2020),
  raca: 'Labrador',
);

void main() {
  testWidgets('mantém o pet selecionado ao trocar de aba e volta à lista', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final usuarios = InMemoryUsuarioRepository(incluirUsuarioTeste: true);
    final usuarioId = usuarios.findAll().single.id!;
    final pets = InMemoryPetRepository()
      ..save(_pet('max', 'Max', usuarioId))
      ..save(_pet('luna', 'Luna', usuarioId));
    await tester.pumpWidget(
      MaterialApp(
        home: MenuPage(
          usuarioRepository: usuarios,
          usuarioId: usuarioId,
          petRepository: pets,
        ),
      ),
    );

    await tester.tap(find.text('Max'));
    await tester.pumpAndSettle();
    expect(find.byType(PetPerfilPage), findsOneWidget);
    expect(
      tester.getCenter(find.byTooltip('Voltar')).dy,
      closeTo(tester.getCenter(find.text('Pet')).dy, 0.1),
    );
    expect(tester.getCenter(find.byTooltip('Voltar')).dx, lessThan(50));
    expect(tester.getCenter(find.text('Pet')).dx, closeTo(195, 0.1));
    expect(find.text('Max'), findsOneWidget);
    expect(find.text('Detalhes'), findsOneWidget);
    expect(find.text('Vacinações'), findsOneWidget);
    expect(find.text('Próximo Agendamento'), findsOneWidget);
    expect(find.text('Nova Consulta'), findsOneWidget);
    expect(find.byTooltip('Pets'), findsOneWidget);

    await tester.tap(find.text('Detalhes'));
    await tester.pumpAndSettle();
    expect(find.text('Histórico de Atendimentos'), findsOneWidget);
    expect(find.byTooltip('Pets'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(PetPerfilPage), findsOneWidget);
    expect(find.text('Nova Consulta'), findsOneWidget);

    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Pets'));
    await tester.pumpAndSettle();
    expect(find.text('Max'), findsOneWidget);
    expect(find.byType(PetPerfilPage), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(PetPerfilPage), findsNothing);
    expect(find.text('Max'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    await tester.tap(find.text('Luna'));
    await tester.pumpAndSettle();
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Max'), findsNothing);
  });

  testWidgets('salva foto somente no pet selecionado e preserva alterações', (
    tester,
  ) async {
    final diretorio = Directory.systemTemp.createTempSync('vethome_pet_test_');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const picker = MethodChannel('plugins.flutter.io/image_picker');
    const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
    var imagemSelecionada = File('assets\\imagens\\cachorro.png').absolute.path;
    messenger.setMockMethodCallHandler(picker, (call) async {
      expect(call.method, 'pickImage');
      return imagemSelecionada;
    });
    messenger.setMockMethodCallHandler(pathProvider, (call) async {
      expect(call.method, 'getApplicationDocumentsDirectory');
      return diretorio.path;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(picker, null);
      messenger.setMockMethodCallHandler(pathProvider, null);
      final fotos = Directory(
        '${diretorio.path}${Platform.pathSeparator}fotos_pets',
      );
      if (fotos.existsSync()) {
        for (final arquivo in fotos.listSync()) {
          arquivo.deleteSync();
        }
        fotos.deleteSync();
      }
      diretorio.deleteSync();
    });

    final pets = InMemoryPetRepository()
      ..save(_pet('max', 'Max', 'usuario-1'))
      ..save(_pet('luna', 'Luna', 'usuario-1'))
      ..save(_pet('outro', 'Outro', 'usuario-2'));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetPerfilPage(
            petId: 'max',
            usuarioId: 'usuario-1',
            petRepository: pets,
            onVoltar: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Escolher da galeria'), findsOneWidget);
    pets.save(pets.findById('max')!.copyWith(nome: 'Max atualizado'));

    await tester.tap(find.text('Escolher da galeria'));
    await tester.pumpAndSettle();
    for (
      var tentativa = 0;
      tentativa < 40 && pets.findById('max')!.fotoPerfilPath == null;
      tentativa++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    final max = pets.findById('max')!;
    expect(max.fotoPerfilPath, isNotNull);
    expect(File(max.fotoPerfilPath!).existsSync(), isTrue);
    expect(max.nome, 'Max atualizado');
    expect(pets.findById('luna')!.fotoPerfilPath, isNull);
    expect(pets.findById('outro')!.fotoPerfilPath, isNull);
    expect(
      tester.widget<EtiquetaPerfil>(find.byType(EtiquetaPerfil)).fotoPerfilPath,
      max.fotoPerfilPath,
    );
    imagemSelecionada = File('assets\\imagens\\gato.png').absolute.path;
    await tester.tap(find.byType(EtiquetaPerfil));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher da galeria'));
    await tester.pumpAndSettle();
    for (
      var tentativa = 0;
      tentativa < 40 &&
          pets.findById('max')!.fotoPerfilPath == max.fotoPerfilPath;
      tentativa++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
    }
    final novaFoto = pets.findById('max')!.fotoPerfilPath;
    expect(novaFoto, isNot(max.fotoPerfilPath));
    expect(
      File(novaFoto!).readAsBytesSync(),
      File(imagemSelecionada).readAsBytesSync(),
    );
    expect(pets.findById('luna')!.fotoPerfilPath, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
  });

  testWidgets('cancelamento e erro na escolha de foto não alteram o pet', (
    tester,
  ) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const picker = MethodChannel('plugins.flutter.io/image_picker');
    var falhar = false;
    messenger.setMockMethodCallHandler(picker, (call) async {
      if (falhar) {
        throw PlatformException(code: 'erro', message: 'sem permissão');
      }
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(picker, null));
    final pets = InMemoryPetRepository()..save(_pet('max', 'Max', 'usuario-1'));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetPerfilPage(
            petId: 'max',
            usuarioId: 'usuario-1',
            petRepository: pets,
            onVoltar: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher da galeria'));
    await tester.pumpAndSettle();
    expect(pets.findById('max')!.fotoPerfilPath, isNull);
    falhar = true;
    await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tirar foto'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Não foi possível selecionar ou salvar a foto:'),
      findsOneWidget,
    );
    expect(pets.findById('max')!.fotoPerfilPath, isNull);
  });

  testWidgets('perfil não rola em tela pequena e oculta pet de outra conta', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 550));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pets = InMemoryPetRepository()..save(_pet('max', 'Max', 'usuario-1'));
    Widget pagina(String usuarioId) => MaterialApp(
      home: Scaffold(
        body: PetPerfilPage(
          petId: 'max',
          usuarioId: usuarioId,
          petRepository: pets,
          onVoltar: () {},
        ),
      ),
    );
    await tester.pumpWidget(pagina('usuario-1'));
    await tester.pumpAndSettle();
    expect(find.text('Nova Consulta').hitTestable(), findsOneWidget);
    expect(find.byType(Scrollable), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(pagina('usuario-2'));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível encontrar o pet.'), findsOneWidget);
    expect(find.text('Max'), findsNothing);
  });

  testWidgets('abre detalhes e mostra dados e histórico do pet', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pets = InMemoryPetRepository()..save(_pet('max', 'Max', 'usuario-1'));
    final repository = InMemoryAgendamentoRepository();
    final amanha = DateUtils.dateOnly(
      DateTime.now(),
    ).add(const Duration(days: 1));
    for (var index = 0; index < 9; index++) {
      await repository.save(
        Agendamento(
          usuarioId: 'usuario-1',
          petId: 'max',
          data: amanha.add(Duration(days: index)),
          horario: '13:00',
          status: index == 1
              ? StatusAgendamento.concluido
              : StatusAgendamento.ativo,
          servicos: [
            ServicoAgendamento(
              id: 'servico-$index',
              categoria: CategoriaServico.exames,
              nome: index == 8 ? 'Hemograma' : 'Atendimento $index',
            ),
            if (index == 8)
              const ServicoAgendamento(
                id: 'creatinina',
                categoria: CategoriaServico.exames,
                nome: 'Creatinina',
              ),
          ],
          convenio: ConvenioAgendamento.particular,
        ),
      );
    }
    await repository.save(
      Agendamento(
        usuarioId: 'usuario-1',
        petId: 'max',
        data: amanha.add(const Duration(days: 10)),
        horario: '14:00',
        status: StatusAgendamento.cancelado,
        servicos: const [
          ServicoAgendamento(
            id: 'cancelado',
            categoria: CategoriaServico.exames,
            nome: 'Atendimento cancelado',
          ),
        ],
        convenio: ConvenioAgendamento.particular,
      ),
    );
    final atualizacao = ValueNotifier<int>(0);
    addTearDown(atualizacao.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: const SizedBox(height: 92),
          body: PetPerfilPage(
            petId: 'max',
            usuarioId: 'usuario-1',
            petRepository: pets,
            agendamentoRepository: repository,
            atualizacaoAgendamentos: atualizacao,
            onVoltar: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Detalhes'));
    await tester.pumpAndSettle();

    expect(find.text('Gênero/Sexo'), findsOneWidget);
    expect(find.text('Macho'), findsOneWidget);
    expect(find.text('7 kg'), findsOneWidget);
    expect(find.text('01/01/2020'), findsOneWidget);
    expect(find.text('Labrador'), findsOneWidget);
    expect(find.text('Histórico de Atendimentos'), findsOneWidget);
    expect(find.text('Ativo'), findsWidgets);
    expect(find.text('Hemograma + Creatinina'), findsOneWidget);
    expect(find.text('Editar').hitTestable(), findsOneWidget);

    final lista = find.byKey(const ValueKey('historico-atendimentos-pet'));
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: lista, matching: find.byType(Scrollable)).first,
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    expect(find.byType(Scrollable), findsOneWidget);
    await tester.drag(lista, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(0));
    expect(find.text('Concluído'), findsOneWidget);
    expect(find.text('Atendimento cancelado'), findsNothing);
    expect(find.text('Editar').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Histórico de Atendimentos'), findsNothing);
    expect(find.byType(PetPerfilPage), findsOneWidget);
  });
}
