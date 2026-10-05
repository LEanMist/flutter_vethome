import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/core/utils/form_fields.dart';
import 'package:flutter_vethome/data/cep_service.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/addresses_page.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/screens/auth.dart';
import 'package:flutter_vethome/screens/outros.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/address_form.dart';
import 'package:flutter_vethome/widgets/pet_avatar.dart';

class TestCep extends CepService {
  TestCep({this.missing = false, this.fail = false});
  final bool missing, fail;
  @override
  Future<CepResult?> lookup(String cep) async {
    if (fail) throw StateError('Rede indisponível');
    return missing ? null : const CepResult('Praça da Sé', 'São Paulo');
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });
  tearDown(() async {
    await VetRepository.flush();
  });

  Finder field(String label) => find.descendant(
    of: find.byWidgetPredicate((w) => w is VHField && w.label == label),
    matching: find.byType(TextFormField),
  );
  Future<void> fill(WidgetTester tester, String label, String text) async {
    await tester.ensureVisible(field(label));
    await tester.enterText(field(label), text);
    await tester.pump();
  }

  Future<void> choose(WidgetTester tester, String label, String value) async {
    await tester.ensureVisible(field(label));
    await tester.pumpAndSettle();
    await tester.tap(field(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(value).last);
    await tester.pumpAndSettle();
  }

  Map<String, dynamic> legacy() => {
    'schemaVersion': 1,
    'client': {
      'name': 'Cliente antigo',
      'birthDate': DateTime(1995, 1, 1).toIso8601String(),
      'address': 'Rua antiga, 9, Cidade',
      'phone': '',
      'email': '',
      'gender': 'Feminino',
    },
    'pets': [],
    'appointments': [],
  };

  test('máscara de nascimento e validação de datas reais', () {
    final value = const DigitsMask('##/##/####').formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '03102000',
        selection: TextSelection.collapsed(offset: 8),
      ),
    );
    expect(value.text, '03/10/2000');
    expect(parseBirthDate(value.text), DateTime(2000, 10, 3));
    expect(parseBirthDate('35/19/2020'), isNull);
    expect(parseBirthDate('31/02/2020'), isNull);
    expect(parseBirthDate('29/02/2020'), DateTime(2020, 2, 29));
  });
  test('máscaras mantêm dígitos de CPF, CEP, telefone fixo e celular', () {
    TextEditingValue input(String value) => TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    expect(
      const DigitsMask(
        '###.###.###-##',
      ).formatEditUpdate(TextEditingValue.empty, input('12345678901')).text,
      '123.456.789-01',
    );
    expect(
      const DigitsMask(
        '#####-###',
      ).formatEditUpdate(TextEditingValue.empty, input('01001000')).text,
      '01001-000',
    );
    expect(
      const PhoneMask()
          .formatEditUpdate(TextEditingValue.empty, input('1132345678'))
          .text,
      '(11) 3234-5678',
    );
    expect(
      const PhoneMask()
          .formatEditUpdate(TextEditingValue.empty, input('11987654321'))
          .text,
      '(11) 98765-4321',
    );
  });
  test('raças filtram acentos e mantêm sugestões por espécie', () {
    expect(
      breedsFor('Cachorro').where((b) => normalizedText(b).contains('gold')),
      ['Golden Retriever'],
    );
    expect(
      breedsFor('Gato').any((b) => normalizedText(b).contains('siames')),
      isTrue,
    );
    expect(breedsFor('Gato'), isNot(contains('Golden Retriever')));
  });
  test(
    'snapshot antigo permanece versão 1 e preserva endereço integral',
    () async {
      SharedPreferences.setMockInitialValues({
        LocalStorage.stateKey: jsonEncode(legacy()),
      });
      await VetRepository.initialize();
      expect(VetRepository.clientName, 'Cliente antigo');
      expect(VetRepository.clientGenderCustom, '');
      expect(VetRepository.addresses.single.street, 'Rua antiga, 9, Cidade');
      VetRepository.saveAddress(
        const SavedAddress(
          id: 'novo',
          street: 'Rua nova',
          number: '10',
          city: 'Cidade nova',
          cep: '01001-000',
        ),
      );
      await VetRepository.initialize();
      expect(VetRepository.addresses.length, 2);
      expect(VetRepository.addresses.first.street, 'Rua antiga, 9, Cidade');
      for (final a in [...VetRepository.addresses]) {
        VetRepository.removeAddress(a.id);
      }
      await VetRepository.initialize();
      expect(VetRepository.addresses, isEmpty);
      expect(VetRepository.clientAddress, '');
    },
  );
  test('gênero Outro e descrição opcional persistem sem afetar pet', () async {
    final petId = VetRepository.pets.first.id;
    VetRepository.registerClient({
      'client.Gênero/Sexo': 'Outro',
      'client.Gênero personalizado': 'Identidade teste',
    });
    await VetRepository.initialize();
    expect(VetRepository.clientGender, 'Outro');
    expect(VetRepository.clientGenderCustom, 'Identidade teste');
    expect(VetRepository.pets.first.id, petId);
  });
  test('editar/excluir endereço persiste sem perder outros', () async {
    VetRepository.saveAddress(
      const SavedAddress(id: 'a', street: 'Rua A', number: '1', city: 'A'),
    );
    VetRepository.saveAddress(
      const SavedAddress(id: 'b', street: 'Rua B', number: '2', city: 'B'),
    );
    VetRepository.saveAddress(
      const SavedAddress(
        id: 'a',
        street: 'Rua A editada',
        number: '3',
        city: 'A',
      ),
    );
    VetRepository.removeAddress('b');
    await VetRepository.initialize();
    expect(VetRepository.addresses.single.street, 'Rua A editada');
    expect(VetRepository.addresses.single.id, 'a');
  });
  testWidgets('gênero é seleção e Outro revela campo opcional', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: field('Gênero/Sexo'),
              matching: find.byType(TextField),
            ),
          )
          .readOnly,
      isTrue,
    );
    await choose(tester, 'Gênero/Sexo', 'Outro');
    expect(
      find.text('Como prefere se identificar? (opcional)'),
      findsOneWidget,
    );
    await choose(tester, 'Gênero/Sexo', 'Prefiro não informar');
    expect(find.text('Como prefere se identificar? (opcional)'), findsNothing);
  });
  testWidgets('pular endereço não cria registro vazio', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const EnderecoScreen(),
        routes: {
          '/cadastroPet': (_) => const Scaffold(body: Text('Etapa pet')),
        },
      ),
    );
    await tester.ensureVisible(find.text('Pular por enquanto'));
    await tester.tap(find.text('Pular por enquanto'));
    await tester.pumpAndSettle();
    expect(find.text('Etapa pet'), findsOneWidget);
    expect(VetRepository.addresses, isEmpty);
  });
  testWidgets('pular pet funciona com zero pets', (tester) async {
    await tester.runAsync(() async {
      for (final pet in [...VetRepository.pets]) {
        VetRepository.removePet(pet);
      }
      await VetRepository.flush();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: const CadastroPetScreen(),
        routes: {'/sucesso': (_) => const Scaffold(body: Text('Concluído'))},
      ),
    );
    await tester.ensureVisible(find.text('Pular por enquanto'));
    await tester.tap(find.text('Pular por enquanto'));
    await tester.pumpAndSettle();
    expect(VetRepository.pets, isEmpty);
    expect(find.text('Concluído'), findsOneWidget);
  });
  testWidgets('trocar espécie limpa raça e troca sugestões', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CadastroPetScreen()));
    await choose(tester, 'Tipo de Animal', 'Cachorro');
    await fill(tester, 'Raça', 'gold');
    await tester.pumpAndSettle();
    expect(find.text('Golden Retriever'), findsOneWidget);
    await tester.tap(find.text('Golden Retriever'));
    await tester.pump();
    await choose(tester, 'Tipo de Animal', 'Gato');
    expect(tester.widget<TextFormField>(field('Raça')).controller!.text, '');
  });
  testWidgets(
    'CEP preenche campos editáveis e pede confirmação de divergência',
    (tester) async {
      SavedAddress? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddressForm(
              title: 'Endereço',
              cepService: TestCep(),
              onSaved: (a) => saved = a,
            ),
          ),
        ),
      );
      await fill(tester, 'CEP', '01001000');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(field('Endereço')).controller!.text,
        'Praça da Sé',
      );
      expect(
        tester.widget<TextFormField>(field('Cidade')).controller!.text,
        'São Paulo',
      );
      await fill(tester, 'Endereço', 'Rua editada');
      await fill(tester, 'Número', '15');
      await tester.ensureVisible(find.text('Salvar endereço'));
      await tester.tap(find.text('Salvar endereço'));
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text('Corrigir'), findsOneWidget);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(saved?.street, 'Rua editada');
      expect(saved?.complement, '');
    },
  );
  for (final mode in ['inexistente', 'rede']) {
    testWidgets('CEP $mode permite preenchimento manual', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddressForm(
              title: 'Endereço',
              cepService: TestCep(
                missing: mode == 'inexistente',
                fail: mode == 'rede',
              ),
              onSaved: (_) {},
            ),
          ),
        ),
      );
      await fill(tester, 'CEP', '99999999');
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          mode == 'rede' ? 'Não foi possível consultar' : 'CEP não encontrado',
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field('Endereço'),
                matching: find.byType(TextField),
              ),
            )
            .readOnly,
        isFalse,
      );
    });
  }
  testWidgets('Agenda normal abre mês atual e data específica é respeitada', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.pumpWidget(const MaterialApp(home: AgendaScreen()));
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    expect(find.text('${months[now.month - 1]} ${now.year}'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: AgendaScreen(initialDate: DateTime(now.year + 1, 7, 8)),
      ),
    );
    expect(find.text('Julho ${now.year + 1}'), findsOneWidget);
  });
  testWidgets('Novo agendamento exibe nome atual por ID e avatar canônico', (
    tester,
  ) async {
    final original = VetRepository.pets.first;
    await tester.runAsync(() async {
      VetRepository.updatePet(
        original,
        original.copyWith(name: 'Pet renomeado'),
      );
      await VetRepository.flush();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(
          pet: original,
          service: 'V10',
          plan: 'Particular',
        ),
      ),
    );
    expect(find.text('Pet renomeado'), findsOneWidget);
    expect(
      tester.widget<PetAvatar>(find.byType(PetAvatar)).image,
      original.imagePath,
    );
    expect(find.text('Vacina: V10'), findsOneWidget);
  });
  test(
    'início passado ou fim inválido não cria evento; fim válido persiste',
    () async {
      final now = DateTime.now(), pet = VetRepository.pets.first;
      final start = now.add(const Duration(days: 1));
      final before = VetRepository.realAppointments(pet.id).length;
      for (final end in [start, start.subtract(const Duration(hours: 1))]) {
        expect(
          tryScheduleAppointment(
            petId: pet.id,
            appointment: Agendamento(
              data: start,
              endDate: end,
              tipo: 'Teste',
              veterinario: 'Teste',
              local: 'Teste',
              status: StatusAgendamento.pendente,
            ),
            now: now,
          ),
          isFalse,
        );
      }
      expect(VetRepository.realAppointments(pet.id).length, before);
      expect(
        tryScheduleAppointment(
          petId: pet.id,
          appointment: Agendamento(
            data: start,
            endDate: start.add(const Duration(hours: 1)),
            tipo: 'Teste',
            veterinario: 'Teste',
            local: 'Teste',
            status: StatusAgendamento.pendente,
          ),
          now: now,
        ),
        isTrue,
      );
      await VetRepository.initialize();
      expect(
        VetRepository.realAppointments(pet.id).single.endDate,
        start.add(const Duration(hours: 1)),
      );
    },
  );
  testWidgets('hoje desabilita horários passados no seletor real', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NovaConsultaPage(
          pet: VetRepository.pets.first,
          service: 'Teste',
          plan: 'Particular',
        ),
      ),
    );
    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();
    final now = DateTime.now(), today = DateTime(now.year, now.month, now.day);
    tester
        .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
        .onDateChanged(today);
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Horário inicial'));
    await tester.tap(find.text('Horário inicial'));
    await tester.pumpAndSettle();
    for (final hour in [12, 13, 14, 15, 16]) {
      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '$hour:00'),
      );
      expect(
        chip.onSelected != null,
        isFutureAppointmentTime(
          DateTime(today.year, today.month, today.day, hour),
          DateTime.now(),
        ),
      );
    }
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });
  testWidgets('Detalhes não apresenta agendamento mock como futuro real', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: DetalhesPetPage(pet: VetRepository.pets.first)),
    );
    expect(find.text('Nenhum agendamento futuro'), findsOneWidget);
    expect(find.text('Remover pet'), findsNothing);
  });
  testWidgets('Meus Endereços vazio apresenta ação de cadastro', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddressesPage()));
    expect(find.text('Nenhum endereço cadastrado'), findsOneWidget);
    expect(find.text('Novo endereço'), findsOneWidget);
  });
  testWidgets('Serviços e Convênio preservam pet, vacina e plano na rota', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    VetRepository.selectedPetId = pet.id;
    Map? received;
    await tester.pumpWidget(
      MaterialApp(
        home: const ServicosScreen(),
        routes: {
          '/convenio': (_) => const ConvenioScreen(),
          '/nova-consulta': (context) {
            received = ModalRoute.of(context)!.settings.arguments as Map;
            return const Scaffold(body: Text('Consulta selecionada'));
          },
        },
      ),
    );
    await tester.tap(find.text('Vacinas'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('V10'));
    await tester.tap(find.text('V10'));
    await tester.pumpAndSettle();
    expect(find.byType(ConvenioScreen), findsOneWidget);
    expect(find.text('Continuar'), findsNothing);
    await tester.tap(find.text('Particular'));
    await tester.pumpAndSettle();
    expect(received, {'petId': pet.id, 'service': 'V10', 'plan': 'Particular'});
  });
  testWidgets('Perfil mascara nascimento e rejeita data inválida', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mudar Data de Nascimento'));
    await tester.pumpAndSettle();
    await fill(tester, 'Data de nascimento', '35192020');
    expect(
      tester
          .widget<TextFormField>(field('Data de nascimento'))
          .controller!
          .text,
      '35/19/2020',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe uma data válida'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });
  testWidgets(
    'boas-vindas com zero pets navega automaticamente sem Continuar',
    (tester) async {
      await tester.runAsync(() async {
        for (final pet in [...VetRepository.pets]) {
          VetRepository.removePet(pet);
        }
        await VetRepository.flush();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: const SucessoScreen(),
          routes: {'/pets': (_) => const PetsPage()},
        ),
      );
      expect(find.text('Bem-vindo!'), findsOneWidget);
      expect(find.text('Continuar'), findsNothing);
      await tester.pump(const Duration(milliseconds: 950));
      expect(
        find.text('Você pode cadastrar seu pet quando quiser.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(find.byType(PetsPage), findsOneWidget);
      expect(VetRepository.pets, isEmpty);
    },
  );
  testWidgets('telas ativas cabem em 320px sem overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final page in [
      const CadastroScreen(),
      const CadastroPetScreen(),
      const PetsPage(),
      DetalhesPetPage(pet: VetRepository.pets.first),
      const EscolhaPetScreen(),
      const ServicosScreen(),
      const ConvenioScreen(),
      NovaConsultaPage(
        pet: VetRepository.pets.first,
        service: 'Hemograma',
        plan: 'Particular',
      ),
      const ConfigScreen(),
      const PerfilPage(),
      const EnderecoScreen(),
      const AddressesPage(),
      const SobreScreen(),
    ]) {
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: page));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: page.runtimeType.toString(),
      );
    }
  });
}
