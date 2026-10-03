import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_page_scaffold.dart';
import '../widgets/vet_card.dart';

class EditarPetPage extends StatefulWidget {
  const EditarPetPage({required this.pet, this.modal = false, super.key});

  final PetModel pet;
  final bool modal;

  @override
  State<EditarPetPage> createState() => _EditarPetPageState();
}

class _EditarPetPageState extends State<EditarPetPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.pet.name);
  late final _species = TextEditingController(
    text: widget.pet.species ?? 'Cachorro',
  );
  late final _sex = TextEditingController(text: widget.pet.sex ?? '');
  late final _weight = TextEditingController(
    text: widget.pet.weightKg?.toString() ?? '',
  );
  late final _birth = TextEditingController(
    text: widget.pet.birthDate == null
        ? ''
        : _formatDate(widget.pet.birthDate!),
  );
  late final _breed = TextEditingController(text: widget.pet.breed ?? '');

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _sex.dispose();
    _weight.dispose();
    _birth.dispose();
    _breed.dispose();
    super.dispose();
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    final date = DateTime(year, month, day);
    if (date.day != day ||
        date.month != month ||
        date.year != year ||
        date.isAfter(DateTime.now())) {
      return null;
    }
    return date;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final birthDate = _parseDate(_birth.text)!;
    final weight = double.parse(_weight.text.replaceAll(',', '.'));
    final species = _species.text.trim();
    final updated = widget.pet.copyWith(
      name: _name.text.trim(),
      imagePath: species.toLowerCase().contains('gato')
          ? PetsTheme.imgCachorroegatoPng36x32
          : PetsTheme.imgCachorroegatoPng,
      description: '$species • ${DateTime.now().year - birthDate.year} anos',
      species: species,
      sex: _sex.text.trim(),
      weightKg: weight,
      birthDate: birthDate,
      breed: _breed.text.trim(),
      neutered: widget.pet.neutered,
    );
    VetRepository.updatePet(widget.pet, updated);
    Navigator.pop(context, updated);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir pet?'),
        content: Text('Deseja excluir ${widget.pet.name} da sua lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    VetRepository.removePet(widget.pet);
    Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    final scale = PetsTheme.scaleOf(context);
    final form = VetCard(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(
              _name,
              'Nome do pet',
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return 'Preencha este campo';
                if (VetRepository.petNameExists(
                  name,
                  except: widget.pet.name,
                )) {
                  return 'Já existe um pet com esse nome';
                }
                return null;
              },
            ),
            SizedBox(height: 12 * scale),
            _field(_species, 'Espécie', validator: _required),
            SizedBox(height: 12 * scale),
            _field(_sex, 'Sexo', validator: _required),
            SizedBox(height: 12 * scale),
            _field(
              _weight,
              'Peso (kg)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final number = double.tryParse(
                  (value ?? '').replaceAll(',', '.'),
                );
                return number == null || number <= 0
                    ? 'Informe um peso válido'
                    : null;
              },
            ),
            SizedBox(height: 12 * scale),
            _field(
              _birth,
              'Nascimento (DD/MM/AAAA)',
              validator: (value) => _parseDate(value ?? '') == null
                  ? 'Informe uma data válida'
                  : null,
            ),
            SizedBox(height: 12 * scale),
            _field(_breed, 'Raça', validator: _required),
          ],
        ),
      ),
    );

    if (widget.modal) {
      return Dialog(
        backgroundColor: VetColors.pink,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(18 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Editar pet',
                  style: TextStyle(
                    color: VetColors.brown,
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.bold,
                    fontFamily: PetsTheme.fontComfortaa,
                  ),
                ),
                SizedBox(height: 12 * scale),
                form,
                SizedBox(height: 12 * scale),
                Row(
                  children: [
                    TextButton(
                      onPressed: _delete,
                      child: const Text('Excluir'),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    SizedBox(width: 8 * scale),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VetColors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return VetPageScaffold(
      title: 'Editar pet',
      pet: widget.pet,
      selectedIndex: 0,
      children: [
        form,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: VetColors.brown,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar alterações'),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Preencha este campo' : null;
}
