import 'package:flutter/material.dart';
import '../data/cep_service.dart';
import '../models/saved_address.dart';
import '../core/utils/form_fields.dart';
import '../widgets.dart';
import '../theme.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({
    super.key,
    required this.title,
    required this.onSaved,
    this.onSkip,
    this.initial,
    this.cepService = const CepService(),
  });
  final String title;
  final ValueChanged<SavedAddress> onSaved;
  final VoidCallback? onSkip;
  final SavedAddress? initial;
  final CepService cepService;
  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _key = GlobalKey<FormState>();
  late final _cep = TextEditingController(text: widget.initial?.cep ?? '');
  late final _street = TextEditingController(
    text: widget.initial?.street ?? '',
  );
  late final _city = TextEditingController(text: widget.initial?.city ?? '');
  late final _number = TextEditingController(
    text: widget.initial?.number ?? '',
  );
  late final _complement = TextEditingController(
    text: widget.initial?.complement ?? '',
  );
  CepResult? _result;
  String _status = '';
  int _request = 0;
  bool _loading = false;
  @override
  void dispose() {
    for (final c in [_cep, _street, _city, _number, _complement]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _lookup(String text) async {
    final request = ++_request;
    _result = null;
    if (text.replaceAll(RegExp(r'\D'), '').length != 8) {
      setState(() {
        _status = '';
        _loading = false;
      });
      return;
    }
    final streetBefore = _street.text, cityBefore = _city.text;
    setState(() {
      _loading = true;
      _status = 'Consultando CEP…';
    });
    try {
      final result = await widget.cepService.lookup(text);
      if (!mounted || request != _request) return;
      setState(() {
        _result = result;
        _loading = false;
        _status = result == null
            ? 'CEP não encontrado. Confira ou preencha manualmente.'
            : 'CEP consultado.';
        if (result != null) {
          if (_street.text == streetBefore) _street.text = result.street;
          if (_city.text == cityBefore) _city.text = result.city;
        }
      });
    } catch (_) {
      if (mounted && request == _request) {
        setState(() {
          _loading = false;
          _status = 'Não foi possível consultar o CEP. Preencha manualmente.';
        });
      }
    }
  }

  Future<void> _save() async {
    if (_loading || !_key.currentState!.validate()) return;
    final result = _result;
    if (result != null &&
        (normalizedText(_street.text) != normalizedText(result.street) ||
            normalizedText(_city.text) != normalizedText(result.city))) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: const Text(
            'O endereço informado não corresponde ao CEP consultado. Deseja continuar mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Corrigir'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (!mounted || proceed != true) return;
    }
    widget.onSaved(
      SavedAddress(
        id:
            widget.initial?.id ??
            'address-${DateTime.now().microsecondsSinceEpoch}',
        street: _street.text.trim(),
        city: _city.text.trim(),
        number: _number.text.trim(),
        complement: _complement.text.trim(),
        cep: _cep.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          49 * (MediaQuery.sizeOf(context).width / 390).clamp(.8, 1.0),
          31,
          49 * (MediaQuery.sizeOf(context).width / 390).clamp(.8, 1.0),
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: VH.secondary, width: 3),
              ),
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    VHField(
                      'CEP',
                      Icons.local_post_office_outlined,
                      figmaForm: true,
                      controller: _cep,
                      onChanged: _lookup,
                      validator: (v) =>
                          (v ?? '').replaceAll(RegExp(r'\D'), '').length == 8
                          ? null
                          : 'Informe um CEP com 8 números',
                    ),
                    if (_status.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _status,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 14),
                    VHField(
                      'Endereço',
                      Icons.location_on_outlined,
                      figmaForm: true,
                      controller: _street,
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    VHField(
                      'Cidade',
                      Icons.location_city,
                      figmaForm: true,
                      controller: _city,
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    VHField(
                      'Número',
                      Icons.tag,
                      figmaForm: true,
                      controller: _number,
                      keyboardType: TextInputType.number,
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    VHField(
                      'Complemento',
                      Icons.home_outlined,
                      figmaForm: true,
                      controller: _complement,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 181,
                height: 65,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VH.secondary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: VH.headingFontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    widget.onSkip == null ? 'Salvar endereço' : 'Cadastrar',
                  ),
                ),
              ),
            ),
            if (widget.onSkip != null)
              TextButton(
                onPressed: widget.onSkip,
                child: const Text('Pular por enquanto'),
              ),
          ],
        ),
      ),
    ),
  );
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Preencha este campo' : null;
}
