import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import '../theme/vet_tones.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/vet_card.dart';
import '../widgets/vet_page_scaffold.dart';

class SaudePage extends StatelessWidget {
  const SaudePage({required this.pet, super.key});

  final PetModel pet;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final perfil = VetRepository.perfil(pet.name);
    final historico = VetRepository.consultas(pet.name);
    final vacinas = VetRepository.vacinas(pet.name);

    final vermif = historico
        .where((c) => c.tipo == 'Vermifugação')
        .map((c) => fmtDiaMes(c.data))
        .firstOrNull;
    final emDia = vacinasEmDia(vacinas);

    return VetPageScaffold(
      title: 'Saúde',
      pet: pet,
      selectedIndex: 0,
      headerBottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PetAvatar(image: pet.imagePath, size: 72, radius: 18),
          SizedBox(height: 8 * s),
          Text(
            pet.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22 * s,
              fontWeight: FontWeight.w700,
              fontFamily: PetsTheme.fontComfortaa,
              color: Colors.white,
            ),
          ),
        ],
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStatus(
                icon: emDia ? Icons.check_circle : Icons.warning_amber,
                title: 'Vacinação',
                value: emDia ? 'Em dia' : 'Atenção',
                color: emDia ? VetTones.success : VetTones.warning,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _MiniStatus(
                icon: Icons.monitor_weight,
                title: 'Peso',
                value: fmtPeso(perfil.pesoKg),
                color: VetTones.warning,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: _MiniStatus(
                icon: Icons.medical_services,
                title: 'Vermif.',
                value: vermif ?? '—',
                color: VetTones.info,
              ),
            ),
          ],
        ),
        const VetSectionTitle('Histórico'),
        for (final c in historico) _ConsultaCard(c),
      ],
    );
  }
}

class _MiniStatus extends StatelessWidget {
  const _MiniStatus({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return VetCard(
      padding: EdgeInsets.symmetric(vertical: 12 * s, horizontal: 6 * s),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24 * s),
          SizedBox(height: 6 * s),
          Text(
            title,
            style: TextStyle(fontSize: 11 * s, color: VetColors.brown),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                color: VetColors.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultaCard extends StatelessWidget {
  const _ConsultaCard(this.c);
  final Consulta c;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return VetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fmtData(c.data),
                style: TextStyle(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: VetColors.brown,
                ),
              ),
              const Spacer(),
              const StatusChip('Concluído', VetTones.success),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            c.tipo,
            style: TextStyle(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: VetColors.brown,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Veterinário: ${c.veterinario}',
            style: TextStyle(fontSize: 12 * s, color: VetColors.brown),
          ),
          SizedBox(height: 8 * s),
          Text(
            c.descricao,
            style: TextStyle(
              fontSize: 12 * s,
              color: VetColors.brown.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
