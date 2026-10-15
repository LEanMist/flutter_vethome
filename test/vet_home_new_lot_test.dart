import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/core/utils/form_fields.dart';
import 'package:flutter_vethome/core/utils/formatters.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/pages/saude_page.dart';
import 'package:flutter_vethome/pages/vacinacao_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/screens/auth.dart';
import 'package:flutter_vethome/screens/outros.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/address_form.dart';
import 'package:flutter_vethome/widgets/appointment_card.dart';
import 'package:flutter_vethome/widgets/pet_form.dart';
import 'package:flutter_vethome/widgets/pet_photo_button.dart';
import 'package:flutter_vethome/widgets/pet_summary.dart';

// Widget flows use immediate storage; unit tests above exercise the real
// shared_preferences API and reload separately.
class _WidgetStorage extends LocalStorage {
  LocalState? state;
  @override
  Future<LocalState?> load() async => state;
  @override
  Future<void> save(LocalState value) async {
    state = LocalState.fromJson(value.toJson());
  }
}

void realWidgetTest(String name, Future<void> Function(WidgetTester) body) {
  testWidgets(name, (tester) async {
    await tester.runAsync(() => body(tester));
  });
}

void main() {
  late _WidgetStorage widgetStorage;
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('MontserratAlternates')
      ..addFont(rootBundle.load('assets/fonts/MontserratAlternatesBold.ttf'));
    await fonts.load();
  });
  setUp(() async {
    widgetStorage = _WidgetStorage();
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });
  tearDown(() async => VetRepository.flush());
  Finder field(String label) => find.descendant(
    of: find.byWidgetPredicate((w) => w is VHField && w.label == label),
    matching: find.byType(TextFormField),
  );
  Future<void> fill(WidgetTester t, String label, String value) async {
    await t.ensureVisible(field(label));
    final input = t.widget<TextFormField>(field(label));
    if (input.controller != null &&
        t
            .widget<TextField>(
              find.descendant(
                of: field(label),
                matching: find.byType(TextField),
              ),
            )
            .readOnly) {
      await t.tap(field(label));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(ListTile, value));
      await t.pumpAndSettle();
    } else {
      await t.enterText(field(label), value);
      await t.pump();
    }
  }

  void viewport(WidgetTester t, Size size) {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
  }

  final now = DateUtils.dateOnly(DateTime.now());
  testWidgets(
    'seletor próximo ao rodapé fica na viewport e última opção é acessível',
    (t) async {
      viewport(t, const Size(320, 640));
      final controller = TextEditingController(text: 'Outro');
      addTearDown(controller.dispose);
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
              child: Column(
                children: [
                  const Spacer(),
                  VHField(
                    'Gênero/Sexo',
                    Icons.wc,
                    controller: controller,
                    choices: const [
                      'Masculino',
                      'Feminino',
                      'Outro',
                      'Prefiro não informar',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await t.tap(field('Gênero/Sexo'));
      await t.pumpAndSettle();
      expect(
        t.getBottomRight(find.byType(ListView)).dy,
        closeTo(t.getTopLeft(field('Gênero/Sexo')).dy, 1),
      );
      expect(
        t.getBottomRight(find.byType(ListView)).dy,
        lessThanOrEqualTo(632),
      );
      await t.drag(find.byType(ListView), const Offset(0, -180));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(ListTile, 'Prefiro não informar'));
      await t.pumpAndSettle();
      expect(controller.text, 'Prefiro não informar');
      expect(find.byType(ListView), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
  Vacina vaccine(String name, {String? id, DateTime? next}) => Vacina(
    id: id,
    nome: name,
    aplicada: now.subtract(const Duration(days: 60)),
    proxima: next,
  );

  test(
    'vacinas reais CRUD, ID por pet, renomeação, persistência e exclusão em cascata',
    () async {
      final pet = VetRepository.pets.first, other = VetRepository.pets[1];
      expect(VetRepository.realVaccines(pet.id), isEmpty);
      expect(VetRepository.vacinas(pet.id).every((v) => v.id == null), isTrue);
      VetRepository.saveVaccine(
        pet.id,
        vaccine('Vacina real', next: now.add(const Duration(days: 100))),
      );
      final real = VetRepository.realVaccines(pet.id).single;
      expect(VetRepository.vacinas(pet.id).length, 1);
      expect(
        VetRepository.vacinas(other.id).every((v) => v.id == null),
        isTrue,
      );
      expect(
        () => VetRepository.saveVaccine(
          other.id,
          vaccine('Outro pet', id: real.id),
        ),
        throwsFormatException,
      );
      VetRepository.saveVaccine(pet.id, vaccine('Dose editada', id: real.id));
      VetRepository.updatePet(pet, pet.copyWith(name: 'Nome novo'));
      await VetRepository.initialize();
      expect(VetRepository.realVaccines(pet.id).single.nome, 'Dose editada');
      expect(VetRepository.realVaccines(pet.id).single.id, real.id);
      expect(VetRepository.realVaccines(pet.id).single.proxima, isNull);
      expect(
        jsonDecode(
          (await SharedPreferences.getInstance()).getString(
            LocalStorage.stateKey,
          )!,
        )['schemaVersion'],
        1,
      );
      VetRepository.removeVaccine(pet.id, real.id!);
      await VetRepository.initialize();
      expect(VetRepository.realVaccines(pet.id), isEmpty);
      expect(VetRepository.vacinas(pet.id).length, 3);
      VetRepository.saveVaccine(pet.id, vaccine('Outra dose'));
      VetRepository.removePet(VetRepository.petById(pet.id)!);
      await VetRepository.initialize();
      expect(VetRepository.petById(pet.id), isNull);
      expect(VetRepository.realVaccines(pet.id), isEmpty);
    },
  );
  test(
    'snapshot anterior sem vacinas/castração carrega sem migração',
    () async {
      VetRepository.updateClient(name: 'Cliente antigo');
      await VetRepository.flush();
      final prefs = await SharedPreferences.getInstance();
      final json =
          jsonDecode(prefs.getString(LocalStorage.stateKey)!)
              as Map<String, dynamic>;
      json.remove('vaccinations');
      for (final pet in json['pets'] as List) {
        (pet as Map).remove('neutered');
      }
      await prefs.setString(LocalStorage.stateKey, jsonEncode(json));
      await VetRepository.initialize();
      expect(VetRepository.clientName, 'Cliente antigo');
      expect(VetRepository.pets.length, 4);
      expect(
        VetRepository.perfil(VetRepository.pets.first.id).castrado,
        isNull,
      );
      expect(VetRepository.realVaccines(VetRepository.pets.first.id), isEmpty);
    },
  );
  test('castração opcional é salva/restaurada em ambas opções', () async {
    for (final value in [null, true, false]) {
      final pet = VetRepository.addPet(
        name: 'Castração $value',
        species: 'Gato',
        sex: 'Macho',
        weightKg: 4.2,
        birthDate: DateTime(2020),
        breed: 'SRD',
        neutered: value,
      );
      await VetRepository.initialize();
      expect(VetRepository.petById(pet.id)!.neutered, value);
    }
  });
  test(
    'peso decimal não vira 1424; criação/edição recusam valor absurdo sem mutação',
    () {
      expect(parsePetWeight('14,24'), 14.24);
      expect(parsePetWeight('14.24'), 14.24);
      for (final text in ['1424', '1,424.0', '14,,24', '-2', '0', 'NaN']) {
        expect(parsePetWeight(text), isNull);
      }
      final pet = VetRepository.pets.first, count = VetRepository.pets.length;
      expect(
        () => VetRepository.updatePet(pet, pet.copyWith(weightKg: 1424)),
        throwsFormatException,
      );
      expect(VetRepository.petById(pet.id)!.weightKg, pet.weightKg);
      expect(
        () => VetRepository.addPet(
          name: 'Peso inválido',
          species: 'Gato',
          sex: 'Fêmea',
          weightKg: 1424,
          birthDate: DateTime(2020),
          breed: 'SRD',
        ),
        throwsFormatException,
      );
      expect(VetRepository.pets.length, count);
    },
  );
  test(
    'datas de vacina inválidas não criam registros; status e plural são derivados',
    () {
      final id = VetRepository.pets.first.id;
      expect(
        () => VetRepository.saveVaccine(
          id,
          Vacina(nome: 'Futura', aplicada: now.add(const Duration(days: 1))),
        ),
        throwsFormatException,
      );
      expect(
        () => VetRepository.saveVaccine(
          id,
          vaccine(
            'Dose inválida',
            next: now.subtract(const Duration(days: 61)),
          ),
        ),
        throwsFormatException,
      );
      expect(VetRepository.realVaccines(id), isEmpty);
      expect(vaccine('Sem dose').status, VacinaStatus.semPrevisao);
      expect(
        contagemVacinas([vaccine('Sem dose')]),
        '0 em dia · 1 precisa de atenção',
      );
      expect(
        contagemVacinas([vaccine('A'), vaccine('B')]),
        '0 em dia · 2 precisam de atenção',
      );
    },
  );
  test('calendário completa semanas sem vazio e sem lacunas', () {
    final days = calendarMonthDays(DateTime(2026, 10));
    expect(days.first, DateTime(2026, 9, 27));
    expect(days.last, DateTime(2026, 11, 7));
    expect(days.length % 7, 0);
    for (var i = 1; i < days.length; i++) {
      expect(
        days[i],
        DateTime(days[i - 1].year, days[i - 1].month, days[i - 1].day + 1),
      );
    }
    expect(fmtHorario(DateTime(2026, 10, 9, 14, 30), null), '14:30');
  });

  realWidgetTest(
    'adicionar pet dentro do app retorna à lista, sem onboarding',
    (t) async {
      await VetRepository.initialize(storage: widgetStorage);
      await t.pumpWidget(
        MaterialApp(
          home: const PetsPage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/cadastroPet') {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => CadastroPetScreen(
                  initialData: Map<String, String>.from(
                    settings.arguments as Map,
                  ),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) =>
                  const Scaffold(body: Text('BOAS-VINDAS INDEVIDAS')),
            );
          },
        ),
      );
      await t.tap(find.byTooltip('Adicionar pet'));
      await t.pumpAndSettle();
      await fill(t, 'Nome do Pet', 'Novo do app');
      await fill(t, 'Tipo de Animal', 'Gato');
      await fill(t, 'Gênero/Sexo', 'Fêmea');
      await fill(t, 'Peso', '4,2');
      await fill(t, 'Data de Nascimento', '02/04/2020');
      await fill(t, 'Raça', 'SRD');
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(ListTile, 'SRD / Sem raça definida'));
      await t.pumpAndSettle();
      await t.tap(find.text('Cadastrar'));
      await t.pump();
      await VetRepository.flush();
      await t.pumpAndSettle();
      await t.pumpAndSettle();
      expect(find.byType(PetsPage), findsOneWidget);
      expect(find.text('BOAS-VINDAS INDEVIDAS'), findsNothing);
      expect(VetRepository.pets.last.name, 'Novo do app');
    },
  );
  realWidgetTest('Outro aparece, salva, reabre na edição e some na troca', (
    t,
  ) async {
    await VetRepository.initialize(storage: widgetStorage);
    await t.pumpWidget(const MaterialApp(home: PerfilPage()));
    await t.ensureVisible(find.text('Mudar gênero'));
    await t.tap(find.text('Mudar gênero'));
    await t.pumpAndSettle();
    await t.ensureVisible(field('Gênero/Sexo'));
    await t.tap(field('Gênero/Sexo'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(ListTile, 'Outro'));
    await t.pumpAndSettle();
    await fill(t, 'Como deseja informar? (opcional)', 'Identificação Teste');
    await t.ensureVisible(find.text('Salvar gênero'));
    await t.tap(find.text('Salvar gênero'));
    await t.pump();
    await VetRepository.flush();
    await t.pumpAndSettle();
    await t.pumpAndSettle();
    await VetRepository.initialize(storage: widgetStorage);
    await t.pumpWidget(
      const MaterialApp(key: ValueKey('reopen'), home: PerfilPage()),
    );
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Mudar gênero'));
    await t.tap(find.text('Mudar gênero'));
    await t.pumpAndSettle();
    expect(
      t
          .widget<TextFormField>(field('Como deseja informar? (opcional)'))
          .controller!
          .text,
      'Identificação Teste',
    );
    await t.ensureVisible(field('Gênero/Sexo'));
    await t.tap(field('Gênero/Sexo'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(ListTile, 'Feminino'));
    await t.pumpAndSettle();
    expect(field('Como deseja informar? (opcional)'), findsNothing);
    await t.ensureVisible(find.text('Salvar gênero'));
    await t.tap(find.text('Salvar gênero'));
    await t.pump();
    await VetRepository.flush();
    await t.pumpAndSettle();
    await t.pumpAndSettle();
    expect(VetRepository.clientGenderCustom, isEmpty);
  });
  realWidgetTest(
    'vacinação CRUD pela interface confirma exclusão e não mistura mocks',
    (t) async {
      await VetRepository.initialize(storage: widgetStorage);
      await t.pumpWidget(
        MaterialApp(home: VacinacaoPage(pet: VetRepository.pets.first)),
      );
      await t.tap(find.text('Adicionar vacina'));
      await t.pumpAndSettle();
      await fill(t, 'Nome da vacina', 'Dose teste');
      await fill(
        t,
        'Data aplicada',
        fmtData(now.subtract(const Duration(days: 100))),
      );
      await t.tap(find.text('Salvar vacina'));
      await t.pump();
      await VetRepository.flush();
      await t.pumpAndSettle();
      await t.pumpAndSettle();
      expect(find.text('Dose teste'), findsOneWidget);
      expect(find.text('V10'), findsNothing);
      expect(find.text('Dados demonstrativos'), findsNothing);
      await t.ensureVisible(find.byTooltip('Opções da vacina Dose teste'));
      await t.tap(find.byTooltip('Opções da vacina Dose teste'));
      await t.pumpAndSettle();
      await t.tap(find.text('Editar'));
      await t.pumpAndSettle();
      await fill(t, 'Nome da vacina', 'Dose editada');
      await t.tap(find.text('Salvar vacina'));
      await t.pump();
      await VetRepository.flush();
      await t.pumpAndSettle();
      await t.pumpAndSettle();
      expect(find.text('Dose editada'), findsOneWidget);
      await t.tap(find.byTooltip('Opções da vacina Dose editada'));
      await t.pumpAndSettle();
      await t.tap(find.text('Excluir'));
      await t.pumpAndSettle();
      expect(VetRepository.realVaccines(VetRepository.pets.first.id).length, 1);
      await t.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Opções da vacina Dose editada'));
      await t.pumpAndSettle();
      await t.tap(find.text('Excluir'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(TextButton, 'Excluir'));
      await t.pump();
      await VetRepository.flush();
      await t.pumpAndSettle();
      await t.pumpAndSettle();
      expect(find.text('Dose editada'), findsNothing);
      expect(find.text('Dados demonstrativos'), findsOneWidget);
    },
  );
  for (final size in [const Size(390, 844), const Size(320, 640)]) {
    realWidgetTest('endereço legível inteiro, botão uma linha em $size', (
      t,
    ) async {
      await VetRepository.initialize(storage: widgetStorage);
      viewport(t, size);
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'MontserratAlternates'),
          home: Scaffold(
            body: AddressForm(
              title: 'Novo endereço',
              initial: const SavedAddress(
                id: 'test',
                street: 'Avenida das Palmeiras',
                number: '1234',
                complement: 'Apartamento 102 bloco B',
                city: 'São José dos Campos',
                cep: '01001-000',
              ),
              onSaved: (_) {},
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final button = t.widget<Text>(find.text('Salvar endereço'));
      expect(button.maxLines, 1);
      expect(button.softWrap, false);
      expect(
        t.getBottomRight(find.text('Salvar endereço')).dy,
        lessThan(size.height),
      );
      for (final label in ['Endereço', 'Complemento (opcional)', 'Cidade']) {
        final editable = find.descendant(
          of: field(label),
          matching: find.byType(EditableText),
        );
        final render = t.state<EditableTextState>(editable).renderEditable;
        final w = t.widget<EditableText>(editable);
        final painter = TextPainter(
          text: TextSpan(text: w.controller.text, style: w.style),
          textDirection: TextDirection.ltr,
        )..layout();
        expect(
          painter.width,
          lessThanOrEqualTo(render.size.width),
          reason: label,
        );
        expect(w.style.fontSize, greaterThanOrEqualTo(12));
      }
      expect(t.takeException(), isNull);
    });
    realWidgetTest(
      'castração inline conectada e badge 26 com toque40 em $size',
      (t) async {
        await VetRepository.initialize(storage: widgetStorage);
        viewport(t, size);
        PetFormValue? value;
        final old = PetModel(
          id: 'old',
          name: 'Antigo',
          imagePath: '',
          description: '',
          species: 'Gato',
          sex: 'Fêmea',
          weightKg: 4.2,
          birthDate: DateTime(2020),
          breed: 'SRD',
        );
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PetForm(
                title: 'Editar Pet',
                pet: old,
                onSaved: (v) => value = v,
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(
          t.getSize(find.byKey(const ValueKey('pet-camera-badge'))),
          const Size(26, 26),
        );
        expect(t.getSize(find.byType(PetPhotoButton)), const Size(40, 40));
        expect(
          t.widget<TextFormField>(field('Peso (kg)')).controller!.text,
          '4.2',
        );
        await t.tap(field('Castração'));
        await t.pumpAndSettle();
        final choice = find.widgetWithText(ListTile, 'Castrado');
        expect(
          t.getTopLeft(choice).dy,
          closeTo(t.getBottomRight(field('Castração')).dy, 1),
        );
        expect(
          t.getSize(choice).width,
          closeTo(t.getSize(field('Castração')).width, 1),
        );
        await t.tap(choice);
        await t.pumpAndSettle();
        expect(choice, findsNothing);
        await t.tap(find.text('Salvar alterações'));
        await t.pumpAndSettle();
        expect(value!.neutered, isTrue);
        expect(t.takeException(), isNull);
      },
    );
    realWidgetTest(
      'Saúde usa peso atual e telas alteradas sem overflow em $size',
      (t) async {
        await VetRepository.initialize(storage: widgetStorage);
        viewport(t, size);
        final old = VetRepository.pets.first;
        await (() async {
          VetRepository.updatePet(old, old.copyWith(weightKg: 14.24));
          await VetRepository.flush();
        })();
        VetRepository.selectedPetId = old.id;
        for (final page in [
          SaudePage(pet: old),
          VacinacaoPage(pet: old),
          NovaConsultaPage(pet: old, service: 'V10', plan: 'Particular'),
          const ServicosScreen(),
          const ConvenioScreen(),
        ]) {
          await t.pumpWidget(MaterialApp(key: UniqueKey(), home: page));
          await t.pumpAndSettle();
          if (page is SaudePage) expect(find.text('14,2 kg'), findsOneWidget);
          expect(
            t.takeException(),
            isNull,
            reason: page.runtimeType.toString(),
          );
        }
      },
    );
    realWidgetTest(
      'Agenda adjacentes clicáveis e horários reais e legados em $size',
      (t) async {
        await VetRepository.initialize(storage: widgetStorage);
        viewport(t, size);
        final pet = VetRepository.pets.first;
        final event = Agendamento(
          data: DateTime(2026, 10, 9, 14, 30),
          endDate: DateTime(2026, 10, 9, 15, 30),
          tipo: 'Consulta teste',
          veterinario: 'Teste',
          local: 'Particular',
          status: StatusAgendamento.pendente,
        );
        await (() async {
          VetRepository.addAgendamento(pet.id, event);
          await VetRepository.flush();
        })();
        await t.pumpWidget(
          const MaterialApp(home: AgendaScreen(initialDate: null)),
        );
        await t.pumpAndSettle();
        await t.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            home: AgendaScreen(initialDate: DateTime(2026, 10, 9)),
          ),
        );
        await t.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('calendar-2026-9-27')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('calendar-2026-11-7')),
          findsOneWidget,
        );
        expect(find.text('14:30 — 15:30'), findsOneWidget);
        await t.tap(find.byKey(const ValueKey('calendar-2026-9-27')));
        await t.pumpAndSettle();
        expect(find.text('Setembro 2026'), findsOneWidget);
        expect(find.text('27 - Domingo'), findsOneWidget);
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppointmentCard(pet: pet, event: event),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(find.textContaining('14:30 — 15:30'), findsOneWidget);
        final legacy = Agendamento(
          data: event.data,
          tipo: 'Antigo',
          veterinario: 'Teste',
          local: 'Teste',
          status: event.status,
        );
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppointmentCard(pet: pet, event: legacy),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(find.textContaining('14:30'), findsOneWidget);
        expect(find.textContaining('15:30'), findsNothing);
        expect(t.takeException(), isNull);
      },
    );
  }
  realWidgetTest('pet antigo expandido mostra castração não informada', (
    t,
  ) async {
    await VetRepository.initialize(storage: widgetStorage);
    final old = PetModel(
      id: 'legacy',
      name: 'Antigo',
      imagePath: '',
      description: '',
      species: 'Gato',
    );
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetSummary(pet: old, size: PetSummarySize.detailed),
        ),
      ),
    );
    await t.tap(find.text('Antigo'));
    await t.pumpAndSettle();
    expect(find.text('Castração'), findsOneWidget);
    expect(find.text('Não informado'), findsWidgets);
    expect(find.text('Castrado'), findsNothing);
  });
}
