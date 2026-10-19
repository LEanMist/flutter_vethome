import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import '../core/utils/pet_images.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import '../widgets/pet_form.dart';

class EditarPetPage extends StatelessWidget {
  const EditarPetPage({super.key, required this.pet, this.modal = false});
  final PetModel pet;
  final bool modal;
  Future<void> _delete(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir pet?'),
        content: Text('Deseja excluir ${pet.name} da sua lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!context.mounted || yes != true) return;
    VetRepository.removePet(pet);
    Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    final current = VetRepository.petById(pet.id) ?? pet;
    final form = PetForm(
      title: 'Editar pet',
      pet: current,
      modal: modal,
      onCancel: modal ? () => Navigator.pop(context) : null,
      onDelete: () => _delete(context),
      onSaved: (v) async {
        final updated = current.copyWith(
          name: v.name,
          species: v.species,
          sex: v.sex,
          weightKg: v.weight,
          birthDate: v.birth,
          breed: v.breed,
          photoBase64: v.photo,
          neutered: v.neutered,
          imagePath:
              v.species == current.species ||
                  PetImages.hasImage(current.imagePath)
              ? current.imagePath
              : PetImages.forSpecies(v.species) ?? '',
          description:
              '${v.species} • ${DateTime.now().year - v.birth.year} anos',
        );
        VetRepository.updatePet(current, updated);
        final saved = await VetRepository.flush();
        if (!context.mounted) return;
        if (!saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
              ),
            ),
          );
        }
        Navigator.pop(context, updated);
      },
    );
    if (modal) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(12),
        child: Container(
          key: const ValueKey('edit-pet-modal-surface'),
          width: 310,
          height: 480,
          clipBehavior: Clip.antiAlias,
          decoration: inset_shadow.BoxDecoration(
            color: const Color(0xFFFBDCDD),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              inset_shadow.BoxShadow(
                inset: true,
                color: VetColors.shadowDark,
                offset: Offset(2, 2),
                blurRadius: 5,
              ),
            ],
          ),
          child: form,
        ),
      );
    }
    return Scaffold(
      backgroundColor: VetColors.pink,
      appBar: AppBar(backgroundColor: VetColors.pink, toolbarHeight: 44),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: form,
          ),
        ),
      ),
    );
  }
}
