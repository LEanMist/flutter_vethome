import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/teste_page.dart';
import 'package:flutter_vethome/screens/auth.dart';
import 'package:flutter_vethome/screens/outros.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/widgets.dart';

void main() {
  late List<PetModel> savedPets;
  late String? savedSelection;
  late Map<String, String> savedClient;
  late DateTime savedBirth;

  setUp(() {
    savedPets = [...VetRepository.pets];
    savedSelection = VetRepository.selectedPetId;
    savedBirth = VetRepository.clientBirthDate;
    savedClient = {
      'name': VetRepository.clientName,
      'email': VetRepository.clientEmail,
      'phone': VetRepository.clientPhone,
      'address': VetRepository.clientAddress,
      'gender': VetRepository.clientGender,
    };
  });
  tearDown(() {
    // Cada teste cria seus próprios IDs, sem tocar nos eventos dos exemplos.
    for (final pet in [...VetRepository.pets]) {
      if (!savedPets.any((saved) => saved.id == pet.id)) {
        VetRepository.removePet(pet);
      }
    }
    VetRepository.pets
      ..clear()
      ..addAll(savedPets);
    VetRepository.selectedPetId = savedSelection;
    VetRepository.clientName = savedClient['name']!;
    VetRepository.clientEmail = savedClient['email']!;
    VetRepository.clientPhone = savedClient['phone']!;
    VetRepository.clientAddress = savedClient['address']!;
    VetRepository.clientGender = savedClient['gender']!;
    VetRepository.clientBirthDate = savedBirth;
  });

  PetModel addPet(String name) => VetRepository.addPet(
    name: name,
    species: 'Gato',
    sex: 'Fêmea',
    weightKg: 4,
    birthDate: DateTime(2020, 4, 2),
    breed: 'SRD',
  );

  Agendamento event(String description) => Agendamento(
    data: DateTime.now().add(const Duration(days: 2)),
    tipo: 'Consulta Geral',
    veterinario: 'Exemplo',
    local: 'VetHome',
    status: StatusAgendamento.pendente,
    descricao: description,
  );

  void largeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> fill(WidgetTester tester, String label, String value) async {
    final field = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is VHField && widget.label == label,
      ),
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('Cadastro completo separa nascimento e gênero de usuário e pet', (
    tester,
  ) async {
    largeViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: const CadastroScreen(),
        routes: {
          '/endereco': (context) => EnderecoScreen(
            initialData:
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, String>,
          ),
          '/cadastroPet': (context) => CadastroPetScreen(
            initialData:
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, String>,
          ),
          '/sucesso': (_) => const Scaffold(body: Text('Cadastro concluído')),
        },
      ),
    );
    for (final entry in {
      'Nome Completo': 'Cliente Teste',
      'Data de Nascimento': '05/02/1995',
      'Gênero/Sexo': 'Feminino',
      'CPF': '12345678900',
      'Telefone/Celular': '11999999999',
      'E-mail': 'cliente@example.com',
      'Senha': '123456',
      'Confirmar Senha': '123456',
    }.entries) {
      await fill(tester, entry.key, entry.value);
    }
    await submit(tester);
    for (final entry in {
      'CEP': '12345678',
      'Endereço': 'Rua Teste',
      'Número': '10',
      'Cidade': 'Cidade Teste',
    }.entries) {
      await fill(tester, entry.key, entry.value);
    }
    await submit(tester);
    for (final label in ['Data de Nascimento', 'Gênero/Sexo']) {
      final input = tester.widget<TextFormField>(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) => widget is VHField && widget.label == label,
          ),
          matching: find.byType(TextFormField),
        ),
      );
      expect(input.controller!.text, isEmpty);
    }
    for (final entry in {
      'Tipo de Animal': 'Gato',
      'Nome do Pet': 'Pet Cadastro 4A',
      'Gênero/Sexo': 'Macho',
      'Peso': '4,5',
      'Data de Nascimento': '02/04/2020',
      'Raça': 'SRD',
    }.entries) {
      await fill(tester, entry.key, entry.value);
    }
    await submit(tester);
    expect(find.text('Cadastro concluído'), findsOneWidget);
    expect(VetRepository.clientBirthDate, DateTime(1995, 2, 5));
    expect(VetRepository.clientGender, 'Feminino');
    expect(VetRepository.clientName, 'Cliente Teste');
    expect(VetRepository.clientEmail, 'cliente@example.com');
    expect(VetRepository.clientPhone, '11999999999');
    expect(VetRepository.clientAddress, contains('Rua Teste'));
    final pet = VetRepository.pets.last;
    expect(pet.birthDate, DateTime(2020, 4, 2));
    expect(pet.sex, 'Macho');
    expect(pet.weightKg, 4.5);
    expect(tester.takeException(), isNull);
  });

  test('Cadastro isolado de pet não modifica o usuário e vice-versa', () {
    addPet('Pet isolado 4A');
    VetRepository.registerClient({
      'pet.Data de Nascimento': '02/04/2020',
      'pet.Gênero/Sexo': 'Macho',
    });
    expect(VetRepository.clientBirthDate, savedBirth);
    expect(VetRepository.clientName, savedClient['name']);
    expect(VetRepository.clientGender, savedClient['gender']);
    final pets = [...VetRepository.pets];
    VetRepository.registerClient({
      'client.Nome Completo': 'Outro cliente',
      'client.Data de Nascimento': '01/01/2000',
    });
    expect(VetRepository.pets, pets);
  });

  test('IDs são únicos, independentes do nome e preservados no copyWith', () {
    final first = PetModel(name: 'Mesmo nome', imagePath: '', description: '');
    final second = PetModel(name: 'Mesmo nome', imagePath: '', description: '');
    expect(first.id, isNotEmpty);
    expect(first.id, isNot(second.id));
    expect(first.copyWith(name: 'Novo nome').id, first.id);
    expect(
      VetRepository.pets.map((pet) => pet.id).toSet().length,
      VetRepository.pets.length,
    );
  });

  test('Renomear preserva agendamento, perfil e seleção por ID', () {
    final pet = addPet('Pet renomear 4A');
    final appointment = event('Evento do ID');
    VetRepository.addAgendamento(pet.id, appointment);
    VetRepository.selectedPetId = pet.id;
    final profile = VetRepository.perfil(pet.id);
    final renamed = pet.copyWith(name: 'Pet renomeado 4A');
    // Uma instância reconstruída com o mesmo ID também pode editar.
    VetRepository.updatePet(pet.copyWith(), renamed);
    expect(VetRepository.petById(pet.id), renamed);
    expect(VetRepository.agendamentos(pet.id), contains(appointment));
    expect(VetRepository.perfil(pet.id).resumo, profile.resumo);
    expect(VetRepository.perfil(pet.id).pesoKg, profile.pesoKg);
    expect(VetRepository.selectedPet, renamed);
    expect(VetRepository.selectedPetIndex, VetRepository.pets.indexOf(renamed));
  });

  test('Perfil deriva dados do modelo atualizado, sem cópia paralela', () {
    final pet = addPet('Pet perfil 4A');
    VetRepository.updatePet(
      pet,
      pet.copyWith(species: 'Cachorro', weightKg: 9, neutered: true),
    );
    final profile = VetRepository.perfil(pet.id);
    expect(profile.especie, 'Cachorro');
    expect(profile.pesoKg, 9);
    expect(profile.castrado, isTrue);
  });

  testWidgets('Renomear pelo modal mantém o ID e o próximo agendamento', (
    tester,
  ) async {
    largeViewport(tester);
    final pet = addPet('Pet modal 4A');
    final appointment = event('Modal');
    VetRepository.addAgendamento(pet.id, appointment);
    VetRepository.selectedPetId = pet.id;
    await tester.pumpWidget(MaterialApp(home: DetalhesPetPage(pet: pet)));
    await tester.ensureVisible(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    final nameField = find.widgetWithText(TextFormField, 'Nome do pet');
    await tester.enterText(nameField, 'Pet modal renomeado 4A');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(VetRepository.petById(pet.id)?.name, 'Pet modal renomeado 4A');
    expect(VetRepository.selectedPet?.id, pet.id);
    expect(VetRepository.agendamentos(pet.id), contains(appointment));
    expect(find.text('Pet modal renomeado 4A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'Excluir remove apenas o ID escolhido mesmo após renomear e reusar nome',
    () {
      final first = addPet('Nome reutilizado 4A');
      final renamed = first.copyWith(name: 'Pet anterior 4A');
      VetRepository.updatePet(first, renamed);
      final second = addPet('Nome reutilizado 4A');
      final firstEvent = event('Primeiro');
      final secondEvent = event('Segundo');
      VetRepository.addAgendamento(first.id, firstEvent);
      VetRepository.addAgendamento(second.id, secondEvent);
      VetRepository.selectedPetId = second.id;
      VetRepository.removePet(first); // Referência antiga, mesmo ID.
      expect(VetRepository.petById(first.id), isNull);
      expect(VetRepository.agendamentos(first.id), isEmpty);
      expect(VetRepository.agendamentos(second.id), contains(secondEvent));
      expect(
        VetRepository.agendamentos(second.id),
        isNot(contains(firstEvent)),
      );
      expect(VetRepository.selectedPetId, second.id);
      expect(VetRepository.perfil(second.id).pesoKg, 4);
    },
  );

  test(
    'Excluir anterior não desloca seleção; excluir selecionado oferece outro',
    () {
      final first = addPet('Seleção anterior 4A');
      final second = addPet('Seleção atual 4A');
      VetRepository.selectedPetIndex = VetRepository.pets.indexOf(second);
      VetRepository.removePet(first);
      expect(VetRepository.selectedPet?.id, second.id);
      VetRepository.removePet(second);
      expect(VetRepository.selectedPet, isNotNull);
      expect(VetRepository.selectedPet?.id, isNot(second.id));
    },
  );

  test('Repositório aceita zero pets e rejeita evento órfão', () {
    for (final pet in [...VetRepository.pets]) {
      VetRepository.removePet(pet);
    }
    expect(VetRepository.selectedPet, isNull);
    expect(VetRepository.selectedPetId, isNull);
    expect(VetRepository.selectedPetIndex, -1);
    expect(
      () => VetRepository.addAgendamento('inexistente', event('Órfão')),
      throwsArgumentError,
    );
  });

  testWidgets(
    'Catálogo aberto não usa pet antigo depois de excluir todos os pets',
    (tester) async {
      largeViewport(tester);
      await tester.pumpWidget(const MaterialApp(home: TestePage()));
      await tester.ensureVisible(find.text('Nova consulta'));
      await tester.pumpAndSettle();
      for (final pet in [...VetRepository.pets]) {
        VetRepository.removePet(pet);
      }
      await tester.tap(find.text('Nova consulta'));
      await tester.pumpAndSettle();
      expect(find.byType(PetsPage), findsOneWidget);
      expect(find.byType(NovaConsultaPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Zero pets não quebra Pets, escolha, serviços, convênio, agenda ou catálogo',
    (tester) async {
      largeViewport(tester);
      for (final pet in [...VetRepository.pets]) {
        VetRepository.removePet(pet);
      }
      for (final screen in <Widget>[
        const PetsPage(),
        const EscolhaPetScreen(),
        const ServicosScreen(),
        const ConvenioScreen(),
        const AgendaScreen(),
        const TestePage(),
      ]) {
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.text('Detalhes do pet'));
      await tester.pumpAndSettle();
      expect(find.byType(PetsPage), findsOneWidget);
      expect(find.byType(DetalhesPetPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
