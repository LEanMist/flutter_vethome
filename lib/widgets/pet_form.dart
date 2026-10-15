import 'dart:async';
import 'package:flutter/material.dart';
import '../core/utils/form_fields.dart';
import '../core/utils/pet_photo.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';
import 'pet_avatar.dart';
import 'pet_photo_button.dart';

class PetFormValue {
  const PetFormValue(
    this.name,
    this.species,
    this.sex,
    this.weight,
    this.birth,
    this.breed,
    this.photo,
    this.neutered,
  );
  final String name, species, sex, breed;
  final double weight;
  final DateTime birth;
  final String? photo;
  final bool? neutered;
}

/// The same compact form for registration and editing, including modal editing.
class PetForm extends StatefulWidget {
  const PetForm({
    super.key,
    required this.title,
    required this.onSaved,
    this.pet,
    this.onSkip,
    this.onDelete,
    this.onCancel,
    this.modal = false,
  });
  final String title;
  final PetModel? pet;
  final FutureOr<void> Function(PetFormValue) onSaved;
  final VoidCallback? onSkip, onDelete, onCancel;
  final bool modal;
  @override
  State<PetForm> createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final key = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.pet?.name ?? '');
  late final species = TextEditingController(text: widget.pet?.species ?? '');
  late final sex = TextEditingController(text: widget.pet?.sex ?? '');
  late final weight = TextEditingController(
    text: widget.pet?.weightKg?.toString() ?? '',
  );
  late final birth = TextEditingController(
    text: widget.pet?.birthDate == null
        ? ''
        : '${widget.pet!.birthDate!.day.toString().padLeft(2, '0')}/${widget.pet!.birthDate!.month.toString().padLeft(2, '0')}/${widget.pet!.birthDate!.year}',
  );
  late final breed = TextEditingController(text: widget.pet?.breed ?? '');
  late final neutered = TextEditingController(
    text: widget.pet?.neutered == null
        ? ''
        : widget.pet!.neutered!
        ? 'Castrado'
        : 'Não castrado',
  );
  late String? photo = widget.pet?.photoBase64;
  bool busy = false;
  bool validationFailed = false;
  @override
  void dispose() {
    for (final c in [name, species, sex, weight, birth, breed, neutered]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> choosePhoto() async {
    setState(() => busy = true);
    try {
      final value = await PetPhoto.choose(context);
      if (mounted && value != null) setState(() => photo = value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is FormatException
                  ? e.message
                  : 'Não foi possível abrir a imagem.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String? requiredValue(String? v) =>
      v == null || v.trim().isEmpty ? 'Obrigatório' : null;
  Widget field(
    String label,
    IconData icon,
    TextEditingController c, {
    List<String>? choices,
    List<String> suggestions = const [],
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) => VHField(
    label,
    icon,
    compact: true,
    controller: c,
    value: label == 'Castração' ? 'Não informado' : null,
    choices: choices,
    suggestions: suggestions,
    onChanged: onChanged,
    validator: validator ?? requiredValue,
  );
  Future<void> save() async {
    if (!key.currentState!.validate()) {
      setState(() => validationFailed = true);
      return;
    }
    setState(() => busy = true);
    try {
      await widget.onSaved(
        PetFormValue(
          name.text.trim(),
          species.text,
          sex.text,
          parsePetWeight(weight.text)!,
          parseBirthDate(birth.text)!,
          breed.text.trim(),
          photo,
          neutered.text.isEmpty ? null : neutered.text == 'Castrado',
        ),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final small = MediaQuery.sizeOf(context).height < 720;
      final editing = widget.pet != null;
      final content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.bold,
                fontSize: small ? 22 : 26,
                color: VetColors.brown,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: SizedBox(
                width: small ? 80 : 96,
                height: small ? 72 : 90,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: PetAvatar(
                        image: widget.pet?.imagePath ?? '',
                        species: species.text.isEmpty
                            ? 'Cachorro'
                            : species.text,
                        photoBase64: photo,
                        size: small ? 60 : 76,
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: PetPhotoButton(onPressed: choosePhoto, busy: busy),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Form(
              key: key,
              child: Column(
                children: [
                  field(
                    editing ? 'Nome do pet' : 'Nome do Pet',
                    Icons.pets,
                    name,
                    validator: (v) {
                      final error = requiredValue(v);
                      if (error != null) return error;
                      return VetRepository.petNameExists(
                            v!,
                            except: widget.pet?.name,
                          )
                          ? 'Já existe um pet com esse nome'
                          : null;
                    },
                  ),
                  const SizedBox(height: 8),
                  field(
                    editing ? 'Espécie' : 'Tipo de Animal',
                    Icons.pets_outlined,
                    species,
                    choices: const ['Cachorro', 'Gato'],
                    onChanged: (_) => setState(() => breed.clear()),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    key: const ValueKey('pet-sex-weight'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: field(
                          editing ? 'Sexo' : 'Gênero/Sexo',
                          Icons.wc,
                          sex,
                          choices: const ['Macho', 'Fêmea'],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: field(
                          editing ? 'Peso (kg)' : 'Peso',
                          Icons.scale_outlined,
                          weight,
                          validator: (v) {
                            return parsePetWeight(v ?? '') == null
                                ? 'Peso inválido (kg)'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  field(
                    'Castração',
                    Icons.health_and_safety_outlined,
                    neutered,
                    choices: const ['Castrado', 'Não castrado'],
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 8),
                  field(
                    editing ? 'Nascimento (DD/MM/AAAA)' : 'Data de Nascimento',
                    Icons.cake_outlined,
                    birth,
                    validator: (v) => parseBirthDate(v ?? '') == null
                        ? 'Data inválida'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  field(
                    'Raça',
                    Icons.pets,
                    breed,
                    suggestions: breedsFor(species.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: busy ? null : save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VetColors.brown,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      editing
                          ? widget.modal
                                ? 'Salvar'
                                : 'Salvar alterações'
                          : 'Cadastrar',
                    ),
                  ),
                ),
              ],
            ),
            if (widget.onSkip != null)
              TextButton(
                onPressed: widget.onSkip,
                child: const Text('Pular por enquanto'),
              ),
            if (widget.onDelete != null)
              TextButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text(widget.modal ? 'Excluir' : 'Excluir pet'),
              ),
          ],
        ),
      );
      // Normal 320x640/390x844 uses the compact column. Only keyboard/validation
      // messages or unusually short windows need a scrollable fallback.
      return constraints.maxHeight < 560 ||
              validationFailed ||
              MediaQuery.viewInsetsOf(context).bottom > 0
          ? SingleChildScrollView(child: content)
          : Align(alignment: Alignment.topCenter, child: content);
    },
  );
}
