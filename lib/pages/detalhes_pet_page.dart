import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../core/utils/vet_nav.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../pages/editar_pet_page.dart';
import '../theme/vet_colors.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_card.dart';
import '../widgets/vet_page_scaffold.dart';
import 'saude_page.dart';
import 'vacinacao_page.dart';

class DetalhesPetPage extends StatefulWidget {
  const DetalhesPetPage({required this.pet, super.key});

  final PetModel pet;

  @override
  State<DetalhesPetPage> createState() => _DetalhesPetPageState();
}

class _DetalhesPetPageState extends State<DetalhesPetPage> {
  late PetModel pet = widget.pet;

  void _open(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _edit() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => EditarPetPage(pet: pet, modal: true),
    );
    if (!mounted) return;
    if (result is PetModel) {
      setState(() => pet = result);
    } else if (result == 'deleted') {
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover pet?'),
        content: Text('Deseja remover ${pet.name} da sua lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      VetRepository.removePet(pet);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final PetProfile perfil = VetRepository.perfil(pet.id);
    final consultas = VetRepository.consultas(pet.id);
    final vacinas = VetRepository.vacinas(pet.id);
    final proximo = proximoAgendamento(VetRepository.agendamentos(pet.id));

    return VetPageScaffold(
      title: 'Detalhes',
      pet: pet,
      selectedIndex: 0,
      children: [
        VetCard(
          padding: EdgeInsets.all(18 * s),
          child: Row(
            children: [
              PetAvatar(image: pet.imagePath, size: 76),
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
        VetCard(
          child: Column(
            children: [
              _PetInfoRow(
                icon: Icons.person_outline,
                label: 'Gênero/Sexo',
                value: pet.sex ?? 'Não informado',
              ),
              const Divider(height: 18),
              _PetInfoRow(
                icon: Icons.scale_outlined,
                label: 'Peso',
                value: fmtPeso(pet.weightKg ?? perfil.pesoKg),
              ),
              const Divider(height: 18),
              _PetInfoRow(
                icon: Icons.cake_outlined,
                label: 'Data de Nascimento',
                value: pet.birthDate == null
                    ? 'Não informado'
                    : fmtData(pet.birthDate!),
              ),
              const Divider(height: 18),
              _PetInfoRow(
                icon: Icons.pets_outlined,
                label: 'Raça',
                value: pet.breed ?? 'Não informada',
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _edit,
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
                onPressed: () {
                  final index = VetRepository.pets.indexWhere(
                    (item) => item.id == pet.id,
                  );
                  if (index >= 0) {
                    VetRepository.selectedPetIndex = index;
                  }
                  Navigator.pushNamed(context, '/servicos');
                },
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remover pet'),
            style: TextButton.styleFrom(foregroundColor: VetColors.brown),
          ),
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

class _PetInfoRow extends StatelessWidget {
  const _PetInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scale = PetsTheme.scaleOf(context);
    return Row(
      children: [
        Icon(icon, color: VetColors.roseDark, size: 20 * scale),
        SizedBox(width: 10 * scale),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: VetColors.brown.withValues(alpha: 0.75),
              fontSize: 13 * scale,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: VetColors.brown,
            fontWeight: FontWeight.w700,
            fontSize: 13 * scale,
          ),
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
