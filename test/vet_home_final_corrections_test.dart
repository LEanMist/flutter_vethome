import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/pages/pets_page.dart';
import 'package:flutter_vethome/pages/saude_page.dart';
import 'package:flutter_vethome/pages/nova_consulta_page.dart';
import 'package:flutter_vethome/screens/auth.dart';
import 'package:flutter_vethome/screens/outros.dart';
import 'package:flutter_vethome/screens/pets.dart';
import 'package:flutter_vethome/widgets.dart';
import 'package:flutter_vethome/widgets/appointment_card.dart';
import 'package:flutter_vethome/widgets/pet_avatar.dart';
import 'package:flutter_vethome/widgets/pets/pet_card_widget.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });
  tearDown(() async => VetRepository.flush());

  Finder field(String label) => find.descendant(
    of: find.byWidgetPredicate((w) => w is VHField && w.label == label),
    matching: find.byType(TextFormField),
  );
  Future<void> fill(WidgetTester tester, String label, String value) async {
    await tester.ensureVisible(field(label));
    await tester.enterText(field(label), value);
    await tester.pump();
  }

  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> signup(WidgetTester tester, String cpf, String phone) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const CadastroScreen(),
        routes: {
          '/endereco': (_) => const Scaffold(body: Text('Etapa endereço')),
        },
      ),
    );
    for (final entry in {
      'Nome Completo': 'Cliente Teste',
      'Data de Nascimento': '01/01/2000',
      'CPF': cpf,
      'Telefone/Celular': phone,
      'E-mail': 'teste@example.com',
      'Senha': 'teste123',
      'Confirmar Senha': 'teste123',
    }.entries) {
      await fill(tester, entry.key, entry.value);
    }
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
  }

  testWidgets('CPF curto é bloqueado independentemente do telefone válido', (
    tester,
  ) async {
    await signup(tester, '123', '11999999999');
    expect(find.text('Informe um CPF com 11 dígitos'), findsOneWidget);
    expect(find.text('Informe um telefone com 10 ou 11 dígitos'), findsNothing);
    expect(find.text('Etapa endereço'), findsNothing);
  });
  testWidgets('telefone curto é bloqueado independentemente do CPF válido', (
    tester,
  ) async {
    await signup(tester, '52998224725', '119');
    expect(
      find.text('Informe um telefone com 10 ou 11 dígitos'),
      findsOneWidget,
    );
    expect(find.text('Informe um CPF válido'), findsNothing);
    expect(find.text('Etapa endereço'), findsNothing);
  });
  testWidgets('CPF com dígitos verificadores inválidos é bloqueado', (
    tester,
  ) async {
    await signup(tester, '52998224724', '11999999999');
    expect(find.text('Informe um CPF válido'), findsOneWidget);
    expect(find.text('Etapa endereço'), findsNothing);
  });
  for (final phone in ['1133334444', '11999999999']) {
    testWidgets('CPF completo e telefone ${phone.length} dígitos continuam', (
      tester,
    ) async {
      await signup(tester, '52998224725', phone);
      expect(find.text('Etapa endereço'), findsOneWidget);
    });
  }
  testWidgets('Histórico separa próximos agendamentos e registros anteriores', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    final now = DateTime.now();
    final dates = [
      DateTime(now.year + 1, 11, 10, 12),
      DateTime(now.year + 1, 10, 5, 12),
      DateTime(now.year - 1, 11, 10, 12),
      DateTime(now.year - 1, 10, 5, 12),
    ];
    await tester.runAsync(() async {
      for (var i = 0; i < dates.length; i++) {
        VetRepository.addAgendamento(
          pet.id,
          Agendamento(
            data: dates[i],
            tipo: switch (i) {
              0 => 'Consulta novembro futura',
              1 => 'Consulta outubro futura',
              2 => 'Consulta novembro passada',
              _ => 'Consulta outubro passada',
            },
            veterinario: 'Teste',
            local: 'Teste',
            status: StatusAgendamento.pendente,
          ),
        );
      }
      await VetRepository.flush();
    });
    final before = VetRepository.realAppointments(
      pet.id,
    ).map((a) => a.data).toList();
    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
    await tester.ensureVisible(find.text('Histórico'));
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    final history = find.byType(BottomSheet);
    expect(find.text('Outros agendamentos futuros'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Histórico de agendamentos'),
      100,
      scrollable: find.descendant(
        of: history,
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Histórico de agendamentos'), findsOneWidget);
    final list = tester.widget<ListView>(
      find.descendant(of: history, matching: find.byType(ListView)),
    );
    final children =
        (list.childrenDelegate as SliverChildListDelegate).children;
    final cards = <(int, AppointmentCard)>[];
    for (final (index, child) in children.indexed) {
      if (child is AppointmentCard) cards.add((index, child));
      if (child is Padding) {
        if (child.child is AppointmentCard) {
          cards.add((index, child.child as AppointmentCard));
        } else if (child.child is Column) {
          for (final nested
              in (child.child as Column).children
                  .whereType<AppointmentCard>()) {
            cards.add((index, nested));
          }
        }
      }
    }
    expect(cards.map((entry) => entry.$2.event.tipo).toList(), [
      'Consulta outubro futura',
      'Consulta novembro futura',
      'Consulta outubro passada',
      'Consulta novembro passada',
    ]);
    final otherFutureHeading = children.indexWhere(
      (child) =>
          child is Semantics &&
          child.key == const ValueKey('settings-other-future-heading'),
    );
    final historyHeading = children.indexWhere(
      (child) =>
          child is Semantics &&
          child.key == const ValueKey('settings-history-heading'),
    );
    expect(cards[0].$1, lessThan(otherFutureHeading));
    expect(cards[1].$1, greaterThan(otherFutureHeading));
    expect(cards[1].$1, lessThan(historyHeading));
    expect(cards[2].$1, greaterThan(historyHeading));
    expect(cards[3].$1, greaterThan(cards[2].$1));
    await tester.scrollUntilVisible(
      find.text('Consulta novembro passada'),
      100,
      scrollable: find.descendant(
        of: history,
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Consulta novembro passada'), findsOneWidget);
    expect(
      VetRepository.realAppointments(pet.id).map((a) => a.data).toList(),
      before,
    );
  });
  testWidgets('Histórico diferencia carteira vazia de consultas futuras', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma consulta registrada.'), findsOneWidget);
    expect(find.text('Nenhuma consulta anterior registrada.'), findsNothing);
    expect(find.text('Nenhum agendamento futuro'), findsNothing);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    final pet = VetRepository.pets.first;
    await tester.runAsync(() async {
      VetRepository.addAgendamento(
        pet.id,
        Agendamento(
          data: DateTime(DateTime.now().year + 1, 5, 10, 12),
          tipo: 'Consulta futura',
          veterinario: 'Teste',
          local: 'Teste',
          status: StatusAgendamento.pendente,
        ),
      );
      await VetRepository.flush();
    });

    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.text('Consulta futura'), findsOneWidget);
    expect(find.text('Nenhuma consulta anterior registrada.'), findsOneWidget);
    expect(find.text('Nenhuma consulta registrada.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Histórico mantém consultas passadas sem próximos agendamentos', (
    tester,
  ) async {
    final pet = VetRepository.pets.first;
    await tester.runAsync(() async {
      VetRepository.addAgendamento(
        pet.id,
        Agendamento(
          data: DateTime(DateTime.now().year - 1, 5, 10, 12),
          tipo: 'Consulta anterior',
          veterinario: 'Teste',
          local: 'Teste',
          status: StatusAgendamento.confirmado,
        ),
      );
      await VetRepository.flush();
    });

    await tester.pumpWidget(const MaterialApp(home: ConfigScreen()));
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum agendamento futuro'), findsOneWidget);
    expect(find.text('Consulta anterior'), findsOneWidget);
    expect(find.text('Nenhuma consulta anterior registrada.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Saúde identifica o conteúdo clínico demonstrativo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: SaudePage(pet: VetRepository.pets.first)),
    );
    expect(find.text('Dados demonstrativos'), findsOneWidget);
    expect(find.text(VetRepository.pets.first.name), findsWidgets);
    final scope = VetRepository.pets.first.weightKg == null
        ? 'Vacinação, peso, vermifugação e histórico.'
        : 'Vacinação, vermifugação e histórico.';
    expect(find.text(scope), findsOneWidget);
  });
  testWidgets(
    'pets novos e demonstrativos compartilham silhuetas sem círculo na lista',
    (tester) async {
      await tester.runAsync(() async {
        for (final species in ['Cachorro', 'Gato']) {
          VetRepository.addPet(
            name: 'Novo $species',
            species: species,
            sex: 'Macho',
            weightKg: 4,
            birthDate: DateTime(2020),
            breed: 'SRD',
          );
        }
        await VetRepository.flush();
      });
      for (final pet in VetRepository.pets) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PetCardWidget(pet: pet)),
          ),
        );
        final avatar = find.byType(PetAvatar);
        expect(
          find.descendant(of: avatar, matching: find.byType(ColoredBox)),
          findsNothing,
        );
        expect(
          find.descendant(of: avatar, matching: find.byType(ClipRRect)),
          findsNothing,
        );
        final image = tester.widget<Image>(
          find.descendant(of: avatar, matching: find.byType(Image)),
        );
        final asset = ((image.image as ResizeImage).imageProvider as AssetImage)
            .assetName;
        expect(
          asset,
          pet.species == 'Gato'
              ? 'assets/imagens/figma/cachorroegatopng-3.png'
              : 'assets/imagens/figma/cachorroegatopng-2.png',
        );
      }
    },
  );
  testWidgets('foto existente continua tendo prioridade sobre a silhueta', (
    tester,
  ) async {
    const photo = 'assets/imagens/figma/vethomepng-2.png';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PetAvatar(image: photo, species: 'Gato', listSilhouette: true),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      ((image.image as ResizeImage).imageProvider as AssetImage).assetName,
      photo,
    );
    expect(find.byType(ClipRRect), findsOneWidget);
  });
  testWidgets(
    'Agenda desktop mantém semanas completas e a ação inicial visível',
    (tester) async {
      viewport(tester, const Size(1280, 800));
      await tester.pumpWidget(
        MaterialApp(home: AgendaScreen(initialDate: DateTime(2026, 10, 5))),
      );
      final calendar = find.byKey(const ValueKey('agenda-calendar'));
      final dayCells = find.byWidgetPredicate(
        (widget) =>
            widget is InkWell &&
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('calendar-'),
      );
      expect(dayCells, findsNWidgets(35));
      expect(
        tester
            .getRect(find.byKey(const ValueKey('calendar-2026-10-31-surface')))
            .bottom,
        lessThan(tester.getRect(calendar).bottom),
      );
      expect(
        tester.getBottomRight(find.text('Nova Consulta')).dy,
        lessThan(500),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('320 px preserva ações e evita overflow nas telas críticas', (
    tester,
  ) async {
    viewport(tester, const Size(320, 640));
    final pet = VetRepository.pets.first;
    for (final screen in [
      const LoginPage(),
      const CadastroScreen(),
      const CadastroPetScreen(),
      const PetsPage(),
      const EscolhaPetScreen(),
      NovaConsultaPage(pet: pet, service: 'Hemograma', plan: 'Particular'),
      AgendaScreen(initialDate: DateTime(2026, 8, 1)),
    ]) {
      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: screen.runtimeType.toString(),
      );
    }
  });
}
