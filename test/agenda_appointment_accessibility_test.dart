import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/agenda_page.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';

class _MemoryStorage extends LocalStorage {
  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) async {}
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + .05) / (darker + .05);
}

void main() {
  testWidgets('Agenda mobile identifica consultas demonstrativas', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await VetRepository.initialize(storage: _MemoryStorage());

      final now = DateTime.now();
      final demoDate = DateTime(now.year, now.month, now.day + 5);
      final realAppointment = Agendamento(
        data: demoDate.add(const Duration(hours: 14)),
        tipo: 'Consulta real de teste',
        veterinario: 'Dra. Exemplo',
        local: 'Clínica VetHome',
        status: StatusAgendamento.confirmado,
      );
      await tester.runAsync(() async {
        VetRepository.addAgendamento(
          VetRepository.pets.first.id,
          realAppointment,
        );
        expect(await VetRepository.flush(), isTrue);
      });
      await tester.pumpWidget(
        MaterialApp(home: AgendaScreen(initialDate: demoDate)),
      );
      await tester.pumpAndSettle();

      final demoSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label?.startsWith(
                  'Demonstração, Consulta Geral,',
                ) ==
                true,
      );
      expect(demoSemantics, findsNWidgets(VetRepository.pets.length));
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == 'Demonstração',
        ),
        findsNWidgets(VetRepository.pets.length),
      );
      for (var index = 0; index < VetRepository.pets.length; index++) {
        final node = tester.getSemantics(demoSemantics.at(index));
        final data = node.getSemanticsData();
        expect(data.label, startsWith('Demonstração, Consulta Geral,'));
        expect('Demonstração'.allMatches(data.label).length, 1);
        expect('Consulta Geral'.allMatches(data.label).length, 1);
        expect(data.label, contains(VetRepository.pets[index].name));
        expect(data.flagsCollection.isButton, isFalse);
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        expect(node.childrenCountInTraversalOrder, 0);
      }

      final realSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label?.startsWith('Consulta real de teste,') ==
                true,
      );
      expect(realSemantics, findsOneWidget);
      final realNode = tester.getSemantics(realSemantics);
      final realData = realNode.getSemanticsData();
      expect(realData.flagsCollection.isButton, isTrue);
      expect(realData.hasAction(SemanticsAction.tap), isTrue);
      expect(realNode.childrenCountInTraversalOrder, 0);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('texto dos exames nos cartões da Agenda tem contraste AA', (
    tester,
  ) async {
    for (final size in const [Size(390, 844), Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          theme: VetTheme.light(VH.primary),
          home: AgendaScreen(initialDate: DateTime(2026, 1, 13)),
        ),
      );
      await tester.pumpAndSettle();

      final labels = ['Hemograma', 'Urina', 'Creatinina'];
      for (final label in labels) {
        final text = tester.widget<Text>(find.text(label));
        final foreground = text.style!.color!;
        expect(foreground, VetColors.calendarTextOnRose);
        expect(
          _contrastRatio(foreground, VetColors.rose),
          greaterThanOrEqualTo(4.5),
          reason: '$label em ${size.width} px',
        );
      }
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
