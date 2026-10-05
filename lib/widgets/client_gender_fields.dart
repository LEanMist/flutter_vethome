import 'package:flutter/material.dart';
import '../widgets.dart';

/// The same inline gender/custom description for signup and profile editing.
class ClientGenderFields extends StatefulWidget {
  const ClientGenderFields({
    super.key,
    required this.gender,
    required this.custom,
    this.figmaForm = false,
    this.validator,
  });
  final TextEditingController gender, custom;
  final bool figmaForm;
  final FormFieldValidator<String>? validator;
  @override
  State<ClientGenderFields> createState() => _ClientGenderFieldsState();
}

class _ClientGenderFieldsState extends State<ClientGenderFields> {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      VHField(
        'Gênero/Sexo',
        Icons.wc,
        controller: widget.gender,
        figmaForm: widget.figmaForm,
        choices: const [
          'Masculino',
          'Feminino',
          'Outro',
          'Prefiro não informar',
        ],
        validator: widget.validator,
        onChanged: (_) => setState(() {}),
      ),
      if (widget.gender.text == 'Outro') ...[
        const SizedBox(height: 8),
        VHField(
          'Como deseja informar? (opcional)',
          Icons.person_outline,
          controller: widget.custom,
          figmaForm: widget.figmaForm,
        ),
      ],
    ],
  );
}
