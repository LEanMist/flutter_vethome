import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/theme.dart';
import 'package:flutter_vethome/theme/vet_colors.dart';
import 'package:flutter_vethome/widgets/appointment_card.dart';

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  testWidgets('detalhes do agendamento mantêm contraste AA no cartão rosa', (
    tester,
  ) async {
    final pet = PetModel(
      id: 'pet-contrast',
      name: 'Luna',
      imagePath: '',
      description: '',
      species: 'Cão',
    );
    final event = Agendamento(
      data: DateTime(2026, 11, 6, 9),
      tipo: 'Consulta',
      veterinario: 'Dra. Teste',
      local: 'Clínica Teste',
      status: StatusAgendamento.confirmado,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: VetTheme.light(VH.primary),
        home: Scaffold(
          body: AppointmentCard(pet: pet, event: event),
        ),
      ),
    );

    for (final label in [
      'Veterinário: Dra. Teste',
      'Local/convênio: Clínica Teste',
    ]) {
      expect(
        tester.widget<Text>(find.text(label)).style?.color,
        VetColors.brown,
      );
    }

    for (final alpha in [.18, .28]) {
      final surface = Color.alphaBlend(
        VetColors.rose.withValues(alpha: alpha),
        VH.background,
      );
      expect(
        _contrastRatio(VetColors.brown, surface),
        greaterThanOrEqualTo(4.5),
      );
    }
    expect(tester.takeException(), isNull);
  });
}
