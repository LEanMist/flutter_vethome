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

  Widget _field(
    String label,
    IconData icon,
    TextEditingController controller, {
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) => VHField(
    label,
    icon,
    compact: true,
    figmaForm:
        widget.onSkip != null &&
        MediaQuery.sizeOf(context).width < VH.desktopBreakpoint,
    labelAbove: true,
    fitSingleLine: true,
    controller: controller,
    validator: validator,
    onChanged: onChanged,
  );

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint;
    final registration = widget.onSkip != null && !desktop;
    final saveButton = ElevatedButton(
      onPressed: _loading ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: VH.secondary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        textStyle: TextStyle(
          fontFamily: VH.headingFontFamily,
          fontSize: registration ? 18 : 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(
        widget.onSkip == null ? 'Salvar endereço' : 'Cadastrar',
        maxLines: 1,
        softWrap: false,
      ),
    );
    return Align(
      alignment: registration ? Alignment.topCenter : Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: desktop ? 900 : 440),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                registration ? 24 : 16,
                16,
                registration ? 0 : 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: registration ? 30 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: registration ? 21 : 16),
                  Center(
                    child: SizedBox(
                      width: registration ? 290 : double.infinity,
                      height: registration ? 565 : null,
                      child: Container(
                        key: registration
                            ? const ValueKey('address-registration-panel')
                            : null,
                        padding: EdgeInsets.symmetric(
                          horizontal: registration ? 15.5 : 10,
                          vertical: registration ? 12 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: registration
                              ? Colors.white.withValues(alpha: .2)
                              : VH.secondary.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(
                            registration ? 30 : 22,
                          ),
                          border: Border.all(
                            color: registration
                                ? VH.secondary
                                : VH.secondary.withValues(alpha: .3),
                            width: registration ? 3 : 1,
                          ),
                        ),
                        child: Form(
                          key: _key,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final half = (constraints.maxWidth - 12) / 2;
                              Widget slot(Widget child, {bool full = false}) =>
                                  SizedBox(
                                    width: desktop && !full
                                        ? half
                                        : constraints.maxWidth,
                                    child: child,
                                  );
                              return Wrap(
                                key: ValueKey(
                                  desktop
                                      ? 'address-form-desktop-grid'
                                      : 'address-form-mobile-grid',
                                ),
                                spacing: 12,
                                runSpacing: 10,
                                children: [
                                  slot(
                                    _field(
                                      'CEP',
                                      Icons.pin_drop_outlined,
                                      _cep,
                                      onChanged: _lookup,
                                      validator: (v) =>
                                          (v ?? '')
                                                  .replaceAll(RegExp(r'\D'), '')
                                                  .length ==
                                              8
                                          ? null
                                          : 'Informe um CEP com 8 números',
                                    ),
                                  ),
                                  if (_status.isNotEmpty)
                                    slot(
                                      Semantics(
                                        liveRegion: true,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            12,
                                            28,
                                            12,
                                            0,
                                          ),
                                          child: Text(
                                            _status,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  slot(
                                    _field(
                                      'Endereço',
                                      Icons.location_on_outlined,
                                      _street,
                                      validator: _required,
                                    ),
                                    full: true,
                                  ),
                                  slot(
                                    _field(
                                      'Número',
                                      Icons.tag,
                                      _number,
                                      validator: _required,
                                    ),
                                  ),
                                  slot(
                                    _field(
                                      'Complemento (opcional)',
                                      Icons.home_outlined,
                                      _complement,
                                    ),
                                  ),
                                  slot(
                                    _field(
                                      'Cidade',
                                      Icons.location_city_outlined,
                                      _city,
                                      validator: _required,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: registration ? 30 : 16),
                  registration
                      ? Center(
                          child: SizedBox(
                            width: 181,
                            height: 65,
                            child: saveButton,
                          ),
                        )
                      : SizedBox(height: 48, child: saveButton),
                  if (widget.onSkip != null)
                    TextButton(
                      onPressed: widget.onSkip,
                      child: const Text('Pular por enquanto'),
                    ),
                ],
              ),
            );
            return !desktop ||
                    constraints.maxHeight < 700 ||
                    MediaQuery.viewInsetsOf(context).bottom > 0
                ? SingleChildScrollView(child: content)
                : Align(alignment: Alignment.topCenter, child: content);
          },
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Preencha este campo' : null;
}
