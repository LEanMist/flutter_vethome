import 'dart:async';
import 'package:flutter/material.dart';
import '../core/utils/form_fields.dart';
import '../core/utils/pet_photo.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets.dart';
import 'pets/pet_avatar.dart';
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
  final FutureOr<void> Function()? onSkip, onDelete;
  final VoidCallback? onCancel;
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
  bool editExtrasExpanded = false;
  @override
  void dispose() {
    for (final c in [name, species, sex, weight, birth, breed, neutered]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> choosePhoto() async {
    if (busy) return;
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
    bool figmaStyle = false,
    double figmaLabelBottomPadding = 1,
    double figmaLabelHorizontalPadding = 5,
    double? figmaContentPaddingLeft,
    double? figmaContentPaddingRight,
    TextAlign figmaTextAlign = TextAlign.start,
  }) {
    final size = MediaQuery.sizeOf(context);
    final figmaRegistration =
        widget.onSkip != null &&
        widget.pet == null &&
        size.height >= 720 &&
        size.width < 600 &&
        MediaQuery.textScalerOf(context).scale(14) <= 15.4;
    final useFigmaStyle = figmaRegistration || figmaStyle;
    return VHField(
      label,
      icon,
      compact: true,
      textAlign: figmaTextAlign,
      figmaContentPaddingLeft: figmaContentPaddingLeft,
      figmaContentPaddingRight: figmaContentPaddingRight,
      figmaForm: useFigmaStyle,
      showChoiceIndicator: !figmaStyle,
      labelAbove: useFigmaStyle || size.width >= 900,
      labelHorizontalPadding: useFigmaStyle
          ? figmaStyle
                ? figmaLabelHorizontalPadding
                : 5
          : null,
      labelBottomPadding: figmaRegistration
          ? 0
          : figmaStyle
          ? figmaLabelBottomPadding
          : null,
      labelFitSingleLine: useFigmaStyle,
      fitSingleLine: figmaStyle && label == 'Raça',
      controller: c,
      value: label == 'Castração' ? 'Não informado' : null,
      choices: choices,
      suggestions: suggestions,
      onChanged: onChanged,
      validator: validator ?? requiredValue,
    );
  }

  Future<void> save() async {
    if (busy) return;
    if (widget.modal && widget.pet != null && species.text.trim().isEmpty) {
      setState(() {
        editExtrasExpanded = true;
        validationFailed = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) key.currentState?.validate();
      });
      return;
    }
    if (!key.currentState!.validate()) {
      setState(() => validationFailed = true);
      return;
    }
    await _runAction(() async {
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
      }
    });
  }

  Future<void> _runAction(FutureOr<void> Function()? action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action?.call();
    } on PersistenceBlockedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'O armazenamento local está protegido. Nenhuma alteração foi feita.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final small = MediaQuery.sizeOf(context).height < 720;
      final desktop = constraints.maxWidth >= 700 && !widget.modal;
      final editing = widget.pet != null;
      final petRegistration = widget.onSkip != null && !editing;
      final registration = petRegistration && !desktop;
      final figmaRegistration =
          registration &&
          !small &&
          constraints.maxWidth < 600 &&
          MediaQuery.textScalerOf(context).scale(14) <= 15.4;
      final figmaEditModal =
          editing &&
          widget.modal &&
          constraints.maxWidth >= 310 &&
          constraints.maxHeight >= 470 &&
          MediaQuery.textScalerOf(context).scale(14) <= 15.4;
      final saveButton = ElevatedButton(
        onPressed: busy ? null : save,
        style: figmaEditModal
            ? ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68442E),
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                elevation: 3,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              )
            : ElevatedButton.styleFrom(
                backgroundColor: editing ? VetColors.brown : VetColors.rose,
                foregroundColor: editing
                    ? Colors.white
                    : VetColors.calendarTextOnRose,
                minimumSize: const Size.fromHeight(48),
                shape: registration ? const StadiumBorder() : null,
                textStyle: registration
                    ? const TextStyle(
                        fontFamily: VH.headingFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
        child: Text(
          registration
              ? 'Continuar'
              : editing
              ? widget.modal
                    ? 'Salvar'
                    : 'Salvar alterações'
              : 'Cadastrar',
        ),
      );
      final standardContent = Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          figmaRegistration
              ? 36
              : registration
              ? 5
              : 7,
          16,
          registration ? 0 : 7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: figmaRegistration ? 1 : null,
              softWrap: !figmaRegistration,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.bold,
                fontSize: small
                    ? 22
                    : registration
                    ? 30
                    : 26,
                color: VetColors.brown,
              ),
            ),
            SizedBox(height: figmaRegistration ? 36 : 6),
            if (!petRegistration) ...[
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
                        child: PetPhotoButton(
                          onPressed: choosePhoto,
                          busy: busy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              key: figmaRegistration
                  ? const ValueKey('pet-registration-slot')
                  : null,
              height: registration && !small ? 480 : null,
              child: Center(
                child: Transform.translate(
                  offset: figmaRegistration ? const Offset(-1, 0) : Offset.zero,
                  child: SizedBox(
                    width: registration ? 290 : double.infinity,
                    height: registration && !small ? 480 : null,
                    child: Container(
                      key: registration
                          ? const ValueKey('pet-registration-panel')
                          : null,
                      padding: registration && !small
                          ? const EdgeInsets.fromLTRB(12, 11, 13, 12)
                          : EdgeInsets.symmetric(
                              horizontal: registration ? 12 : 12,
                              vertical: 12,
                            ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: registration ? .2 : .16,
                        ),
                        borderRadius: BorderRadius.circular(
                          registration ? 30 : 28,
                        ),
                        border: Border.all(
                          color: registration
                              ? VetColors.rose
                              : VetColors.rose.withValues(alpha: .7),
                          width: registration ? 3 : 2,
                        ),
                      ),
                      child: Form(
                        key: key,
                        child: desktop
                            ? LayoutBuilder(
                                builder: (context, fieldConstraints) {
                                  final width =
                                      (fieldConstraints.maxWidth - 12) / 2;
                                  return Wrap(
                                    key: const ValueKey(
                                      'pet-form-desktop-grid',
                                    ),
                                    spacing: 12,
                                    runSpacing: 10,
                                    children: [
                                      for (final item in _formFields(
                                        editing,
                                        registration: petRegistration,
                                      ))
                                        SizedBox(width: width, child: item),
                                    ],
                                  );
                                },
                              )
                            : Column(
                                key: const ValueKey('pet-form-mobile-grid'),
                                children: _mobileFields(
                                  editing,
                                  registration: registration,
                                  figmaRegistration: figmaRegistration,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: registration ? 44 : 12),
            registration
                ? Center(
                    child: SizedBox(width: 181, height: 65, child: saveButton),
                  )
                : Row(
                    children: [
                      if (widget.onCancel != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy ? null : widget.onCancel,
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(child: saveButton),
                    ],
                  ),
            if (widget.onSkip != null)
              if (registration) const SizedBox(height: 8),
            if (widget.onSkip != null)
              TextButton(
                onPressed: busy ? null : () => _runAction(widget.onSkip),
                child: const Text('Pular'),
              ),
            if (widget.onDelete != null)
              TextButton.icon(
                onPressed: busy ? null : () => _runAction(widget.onDelete),
                icon: const Icon(Icons.delete_outline),
                label: Text(widget.modal ? 'Excluir' : 'Excluir pet'),
              ),
          ],
        ),
      );
      final content = figmaEditModal
          ? _buildFigmaEditModal(
              fields: _formFields(editing, figmaEdit: true),
              saveButton: saveButton,
            )
          : standardContent;
      return PopScope(
        canPop: !busy,
        child:
            widget.modal ||
                small ||
                constraints.maxHeight < 560 ||
                validationFailed ||
                MediaQuery.viewInsetsOf(context).bottom > 0
            ? SingleChildScrollView(child: content)
            : Align(alignment: Alignment.topCenter, child: content),
      );
    },
  );

  Widget _buildFigmaEditModal({
    required List<Widget> fields,
    required Widget saveButton,
  }) {
    final cancelButton = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SizedBox(
        width: 98,
        height: 34,
        child: OutlinedButton(
          onPressed: busy ? null : widget.onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF68442E),
            backgroundColor: const Color(0xFFFFF4F3),
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const StadiumBorder(),
            side: const BorderSide(color: Colors.white),
            textStyle: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: const Text('Cancelar'),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 31, 26, 0),
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              container: true,
              header: true,
              label: widget.title,
              child: const SizedBox.shrink(),
            ),
            fields[0],
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 122, child: fields[2]),
                const SizedBox(width: 13),
                Expanded(flex: 124, child: fields[3]),
              ],
            ),
            const SizedBox(height: 17),
            fields[5],
            const SizedBox(height: 16),
            fields[6],
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cancelButton,
                  SizedBox(width: 90, height: 34, child: saveButton),
                ],
              ),
            ),
            SizedBox(
              height: 22,
              child: TextButton(
                key: const ValueKey('edit-pet-extra-fields-toggle'),
                onPressed: busy
                    ? null
                    : () => setState(
                        () => editExtrasExpanded = !editExtrasExpanded,
                      ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF68442E),
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: 11,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(editExtrasExpanded ? 'Menos opções' : 'Mais opções'),
                    Icon(
                      editExtrasExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
            if (editExtrasExpanded) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  PetAvatar(
                    image: widget.pet?.imagePath ?? '',
                    species: species.text.isEmpty ? 'Cachorro' : species.text,
                    photoBase64: photo,
                    size: 60,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Foto do pet',
                      style: TextStyle(color: Color(0xFF68442E)),
                    ),
                  ),
                  PetPhotoButton(onPressed: choosePhoto, busy: busy),
                ],
              ),
              const SizedBox(height: 8),
              fields[1],
              const SizedBox(height: 8),
              fields[4],
              if (widget.onDelete != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: busy ? null : () => _runAction(widget.onDelete),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(widget.modal ? 'Excluir' : 'Excluir pet'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _formFields(
    bool editing, {
    bool registration = false,
    bool figmaEdit = false,
  }) {
    final registrationNameLabel = switch (species.text) {
      'Cachorro' => 'Nome do Cachorro(a)',
      'Gato' => 'Nome do Gato(a)',
      _ => 'Nome do Pet',
    };
    final nameField = field(
      figmaEdit
          ? registrationNameLabel
          : editing
          ? 'Nome do pet'
          : registration
          ? registrationNameLabel
          : 'Nome do Pet',
      Icons.person_outline,
      name,
      figmaStyle: figmaEdit,
      figmaContentPaddingRight: figmaEdit ? 30 : null,
      figmaTextAlign: figmaEdit ? TextAlign.center : TextAlign.start,
      figmaLabelBottomPadding: 0,
      validator: (v) {
        final error = requiredValue(v);
        if (error != null) return error;
        return VetRepository.petNameExists(v!, except: widget.pet?.name)
            ? 'Já existe um pet com esse nome'
            : null;
      },
    );
    final speciesField = field(
      editing ? 'Espécie' : 'Tipo de Animal',
      Icons.pets_outlined,
      species,
      choices: const ['Cachorro', 'Gato'],
      onChanged: (_) => setState(() => breed.clear()),
    );
    final sexField = field(
      editing && !figmaEdit ? 'Sexo' : 'Gênero/Sexo',
      Icons.wc,
      sex,
      choices: const ['Macho', 'Fêmea'],
      figmaStyle: figmaEdit,
      figmaContentPaddingLeft: figmaEdit ? 18 : null,
      figmaLabelBottomPadding: 0,
    );
    final weightField = field(
      editing && !figmaEdit ? 'Peso (kg)' : 'Peso',
      Icons.scale_outlined,
      weight,
      figmaStyle: figmaEdit,
      figmaLabelHorizontalPadding: 7,
      figmaContentPaddingLeft: figmaEdit ? 15 : null,
      figmaLabelBottomPadding: 0,
      validator: (v) =>
          parsePetWeight(v ?? '') == null ? 'Peso inválido (kg)' : null,
    );
    final neuteredField = field(
      'Castração',
      Icons.health_and_safety_outlined,
      neutered,
      choices: const ['Castrado', 'Não castrado'],
      validator: (_) => null,
    );
    final birthField = field(
      editing && !figmaEdit ? 'Nascimento (DD/MM/AAAA)' : 'Data de Nascimento',
      Icons.cake_outlined,
      birth,
      figmaStyle: figmaEdit,
      figmaContentPaddingRight: figmaEdit ? 30 : null,
      figmaTextAlign: figmaEdit ? TextAlign.center : TextAlign.start,
      validator: (v) =>
          parseBirthDate(v ?? '') == null ? 'Data inválida' : null,
    );
    final breedField = field(
      'Raça',
      Icons.pets,
      breed,
      suggestions: breedsFor(species.text),
      figmaStyle: figmaEdit,
      figmaContentPaddingLeft: figmaEdit ? 18 : null,
    );
    return [
      if (registration) speciesField,
      nameField,
      if (!registration) speciesField,
      sexField,
      weightField,
      if (!registration) neuteredField,
      birthField,
      breedField,
    ];
  }

  List<Widget> _mobileFields(
    bool editing, {
    required bool registration,
    required bool figmaRegistration,
  }) {
    final fields = _formFields(editing, registration: registration);
    final children = <Widget>[];
    for (var i = 0; i < fields.length; i++) {
      if (i == 2) {
        children.add(
          Row(
            key: const ValueKey('pet-sex-weight'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: figmaRegistration ? 122 : 1, child: fields[2]),
              SizedBox(width: figmaRegistration ? 13 : 10),
              Expanded(flex: figmaRegistration ? 124 : 1, child: fields[3]),
            ],
          ),
        );
        i = 3;
      } else {
        children.add(fields[i]);
      }
      if (i < fields.length - 1) {
        children.add(SizedBox(height: figmaRegistration ? 16.8 : 8));
      }
    }
    return children;
  }
}
