import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/form_fields.dart';
import '../../theme.dart';
import '../../widgets.dart';

class VHForm extends StatefulWidget {
  const VHForm({
    super.key,
    required this.title,
    required this.fields,
    required this.next,
    this.initialData = const {},
    this.dataPrefix = '',
  });

  final String title;
  final List<VHField> fields;
  final String next;
  final Map<String, String> initialData;
  final String dataPrefix;

  @override
  State<VHForm> createState() => _VHFormState();
}

class _VHFormState extends State<VHForm> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _makeControllers();
  }

  @override
  void didUpdateWidget(covariant VHForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.initialData, widget.initialData) ||
        !listEquals(
          oldWidget.fields.map((f) => f.label).toList(),
          widget.fields.map((f) => f.label).toList(),
        )) {
      for (final controller in _controllers) {
        controller.dispose();
      }
      _controllers = _makeControllers();
    }
  }

  List<TextEditingController> _makeControllers() => [
    for (final field in widget.fields)
      TextEditingController(
        text: widget.initialData['${widget.dataPrefix}${field.label}'] ?? '',
      ),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validate(VHField field, String? rawValue) {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) {
      return field.label == 'Complemento' ? null : 'Preencha este campo';
    }
    if (field.label == 'E-mail' &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Informe um e-mail válido';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (field.label == 'CPF' && digits.length != 11) {
      return 'Informe um CPF com 11 dígitos';
    }
    if (field.label == 'Telefone/Celular' &&
        digits.length != 10 &&
        digits.length != 11) {
      return 'Informe um telefone com 10 ou 11 dígitos';
    }
    if (field.label == 'Senha' && value.length < 6) {
      return 'Use ao menos 6 caracteres';
    }
    if (field.label == 'Confirmar Senha' &&
        widget.fields.any((item) => item.label == 'Senha') &&
        value !=
            _controllers[widget.fields.indexWhere(
                  (item) => item.label == 'Senha',
                )]
                .text) {
      return 'As senhas não coincidem';
    }
    if (field.label.contains('Nascimento') && !_isValidDate(value)) {
      return 'Use uma data válida (DD/MM/AAAA)';
    }
    return null;
  }

  bool _isValidDate(String value) => parseBirthDate(value) != null;

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final data = <String, String>{
      ...widget.initialData,
      for (var i = 0; i < widget.fields.length; i++)
        '${widget.dataPrefix}${widget.fields[i].label}': _controllers[i].text
            .trim(),
    };
    Navigator.pushNamed(context, widget.next, arguments: data);
  }

  Widget _buildField(int i) {
    final field = widget.fields[i];
    return VHField(
      field.label,
      field.icon,
      password: field.password,
      figmaForm: true,
      controller: _controllers[i],
      keyboardType: field.keyboardType,
      choices: field.choices,
      onChanged: (value) {
        setState(() {});
      },
      validator: (value) => _validate(field, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                39 * (MediaQuery.sizeOf(context).width / 390).clamp(.8, 1.0),
                38,
                39 * (MediaQuery.sizeOf(context).width / 390).clamp(.8, 1.0),
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Comfortaa',
                      color: VH.foreground,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: VH.secondary, width: 3),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          for (var i = 0; i < widget.fields.length; i++) ...[
                            _buildField(i),
                            if (i != widget.fields.length - 1)
                              const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: PillButton(
                      color: VH.secondary,
                      padding: EdgeInsets.zero,
                      onTap: _continue,
                      child: SizedBox(
                        width: 181,
                        height: 71,
                        child: const Center(
                          child: Text(
                            'Cadastrar',
                            style: TextStyle(
                              fontFamily: VH.headingFontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
