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
    await tester.ensureVisible(field('Gênero/Sexo'));
    await tester.pumpAndSettle();
    await tester.tap(field('Gênero/Sexo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prefiro não informar').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.tap(find.text('Cadastrar'));
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
    await signup(tester, '12345678901', '119');
    expect(
      find.text('Informe um telefone com 10 ou 11 dígitos'),
      findsOneWidget,
    );
    expect(find.text('Informe um CPF com 11 dígitos'), findsNothing);
    expect(find.text('Etapa endereço'), findsNothing);
  });
  for (final phone in ['1133334444', '11999999999']) {
    testWidgets('CPF completo e telefone ${phone.length} dígitos continuam', (
      tester,
    ) async {
      await signup(tester, '12345678901', phone);
      expect(find.text('Etapa endereço'), findsOneWidget);
    });
  }
  testWidgets(
    'Histórico ordena outubro antes de novembro sem mudar os registros',
    (tester) async {
      final pet = VetRepository.pets.first;
      final year = DateTime.now().year + 1;
      final dates = [DateTime(year, 11, 10, 12), DateTime(year, 10, 5, 12)];
      await tester.runAsync(() async {
        for (var i = 0; i < dates.length; i++) {
          VetRepository.addAgendamento(
            pet.id,
            Agendamento(
              data: dates[i],
              tipo: i == 0 ? 'Consulta novembro' : 'Consulta outubro',
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
      final list = tester.widget<ListView>(
        find.descendant(of: history, matching: find.byType(ListView)),
      );
      final children =
          (list.childrenDelegate as SliverChildListDelegate).children;
      final cards = children
          .whereType<Padding>()
          .map((p) => p.child)
          .whereType<AppointmentCard>()
          .toList();
      expect(cards.map((c) => c.event.tipo).toList(), [
        'Consulta outubro',
        'Consulta novembro',
      ]);
      await tester.scrollUntilVisible(
        find.text('Consulta novembro'),
        100,
        scrollable: find.descendant(
          of: history,
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('Consulta novembro'), findsOneWidget);
      expect(
        VetRepository.realAppointments(pet.id).map((a) => a.data).toList(),
        before,
      );
    },
  );
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
    'Agenda desktop mantém células compactas e a ação inicial visível',
    (tester) async {
      viewport(tester, const Size(1280, 800));
      await tester.pumpWidget(
        MaterialApp(home: AgendaScreen(initialDate: DateTime(2026, 10, 5))),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('agenda-calendar'))).height,
        lessThanOrEqualTo(344),
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
