import 'package:flutter/material.dart';
import '../core/utils/formatters.dart';
import '../models/pet_model.dart';
import '../data/vet_repository.dart';
import '../theme/vet_colors.dart';
import 'pet_avatar.dart';

enum PetSummarySize { compact, medium, detailed }

class PetSummary extends StatefulWidget {
  const PetSummary({
    super.key,
    required this.pet,
    this.size = PetSummarySize.compact,
    this.onPhoto,
    this.onEdit,
  });
  final PetModel pet;
  final PetSummarySize size;
  final VoidCallback? onPhoto, onEdit;
  @override
  State<PetSummary> createState() => _PetSummaryState();
}

class _PetSummaryState extends State<PetSummary> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final pet = VetRepository.petById(widget.pet.id) ?? widget.pet;
    final detailed = widget.size == PetSummarySize.detailed;
    final avatarSize = switch (widget.size) {
      PetSummarySize.compact => 48.0,
      PetSummarySize.medium => 64.0,
      PetSummarySize.detailed => 76.0,
    };
    final secondary = TextStyle(
      color: VetColors.brown.withValues(alpha: .75),
      fontSize: 12,
    );
    final profile = VetRepository.perfil(pet.id);
    Widget datum(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: secondary)),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: VetColors.brown,
              ),
            ),
          ),
        ],
      ),
    );
    return Material(
      color: VetColors.rose.withValues(alpha: .3),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: detailed ? () => setState(() => expanded = !expanded) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: avatarSize + (widget.onPhoto == null ? 0 : 8),
                    height: avatarSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        PetAvatar(
                          image: pet.imagePath,
                          photoBase64: pet.photoBase64,
                          species: pet.species,
                          size: avatarSize,
                        ),
                        if (widget.onPhoto != null)
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: IconButton.filled(
                              tooltip: 'Alterar foto do pet',
                              onPressed: widget.onPhoto,
                              style: IconButton.styleFrom(
                                backgroundColor: VetColors.brown,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(
                                Icons.photo_camera_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                            color: VetColors.brown,
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [pet.species, pet.breed]
                              .whereType<String>()
                              .where((v) => v.isNotEmpty)
                              .join(' · '),
                          style: secondary,
                        ),
                        if (detailed) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${profile.idadeAnos} ${profile.idadeAnos == 1 ? 'ano' : 'anos'} · ${pet.weightKg == null ? 'Peso não informado' : fmtPeso(pet.weightKg!)}',
                            style: secondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.onEdit != null)
                    IconButton(
                      tooltip: 'Editar',
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                    ),
                ],
              ),
              if (detailed) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: VetColors.brown,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? Column(
                          children: [
                            const Divider(),
                            datum('Sexo', pet.sex ?? 'Não informado'),
                            datum(
                              'Nascimento',
                              pet.birthDate == null
                                  ? 'Não informado'
                                  : fmtData(pet.birthDate!),
                            ),
                            datum('Espécie', pet.species ?? 'Não informada'),
                            datum('Raça', pet.breed ?? 'Não informada'),
                            datum(
                              'Peso',
                              pet.weightKg == null
                                  ? 'Não informado'
                                  : fmtPeso(pet.weightKg!),
                            ),
                            if (pet.neutered != null)
                              datum(
                                'Castração',
                                pet.neutered! ? 'Castrado' : 'Não castrado',
                              ),
                          ],
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
