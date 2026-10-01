import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../core/utils/vet_nav.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_card.dart';
import '../widgets/vet_page_scaffold.dart';
import 'saude_page.dart';
import 'vacinacao_page.dart';

class DetalhesPetPage extends StatelessWidget {
  const DetalhesPetPage({required this.pet, super.key});

  final PetModel pet;

  void _open(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final PetProfile perfil = VetRepository.perfil(pet.name);
    final consultas = VetRepository.consultas(pet.name);
    final vacinas = VetRepository.vacinas(pet.name);
    final proximo = proximoAgendamento(VetRepository.agendamentos(pet.name));

    return VetPageScaffold(
      title: 'Detalhes',
      pet: pet,
      selectedIndex: 0,
      children: [
        VetCard(
          padding: EdgeInsets.all(18 * s),
          child: Row(
            children: [
              PetAvatar(image: pet.imagePath, size: 76, radius: 20),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: TextStyle(
                        fontSize: 22 * s,
                        fontWeight: FontWeight.w700,
                        fontFamily: PetsTheme.fontComfortaa,
                        color: VetColors.brown,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      '${perfil.resumo} • ${fmtPeso(perfil.pesoKg)}',
                      style: TextStyle(
                        fontSize: 13 * s,
                        color: VetColors.brown.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => vetSoon(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: VetColors.brown,
                  side: const BorderSide(color: VetColors.roseDark),
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 14 * s),
                ),
                child: const Text('Editar'),
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: ElevatedButton(
                onPressed: () => vetNavigate(context, 3, pet: pet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VetColors.brown,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 14 * s),
                ),
                child: const Text('Nova Consulta'),
              ),
            ),
          ],
        ),
        _Atalho(
          icon: Icons.favorite,
          title: 'Saúde',
          value: 'Última consulta: ${fmtData(consultas.first.data)}',
          onTap: () => _open(context, SaudePage(pet: pet)),
        ),
        _Atalho(
          icon: Icons.vaccines,
          title: 'Vacinação',
          value: vacinasEmDia(vacinas) ? 'Em dia' : resumoVacinas(vacinas),
          onTap: () => _open(context, VacinacaoPage(pet: pet)),
        ),
        _Atalho(
          icon: Icons.calendar_month,
          title: 'Próximo agendamento',
          value: proximo == null
              ? 'Nenhum agendamento'
              : '${fmtDiaMes(proximo.data)} às ${fmtHora(proximo.data)}',
          onTap: () => vetNavigate(context, 3, pet: pet),
        ),
      ],
    );
  }
}

class _Atalho extends StatelessWidget {
  const _Atalho({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    return VetCard(
      onTap: onTap,
      padding: EdgeInsets.all(16 * s),
      child: Row(
        children: [
          Container(
            width: 42 * s,
            height: 42 * s,
            decoration: BoxDecoration(
              color: VetColors.rose,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(icon, color: Colors.white, size: 22 * s),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: VetColors.brown,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13 * s,
                    color: VetColors.brown.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: VetColors.brown, size: 24 * s),
        ],
      ),
    );
  }
}
