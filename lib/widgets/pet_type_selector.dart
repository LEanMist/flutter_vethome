import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/pet.dart';

class PetTypeSelector extends StatelessWidget {
  const PetTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PetType? value;
  final ValueChanged<PetType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PetType>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Tipo de animal',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: PetType.cachorro,
          child: Text('Cachorro'),
        ),
        DropdownMenuItem(
          value: PetType.gato,
          child: Text('Gato'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
