import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import '../data/cep_service.dart';
import '../models/saved_address.dart';
import '../core/utils/form_fields.dart';
import '../widgets/figma_action_target.dart';
import '../widgets.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({
    super.key,
    required this.title,
    required this.onSaved,
    this.onSkip,
    this.skipButtonStyle,
    this.onDelete,
    this.initial,
    this.cepService = const CepService(),
    this.figmaEditLayout = false,
  });
  final String title;
  final FutureOr<void> Function(SavedAddress) onSaved;
  final FutureOr<void> Function()? onSkip;
  final ButtonStyle? skipButtonStyle;
  final FutureOr<void> Function(SavedAddress)? onDelete;
  final SavedAddress? initial;
  final CepService cepService;
  final bool figmaEditLayout;
  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
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
  bool _saving = false;
  @override
  void dispose() {
    for (final c in [_name, _cep, _street, _city, _number, _complement]) {
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
    if (_loading || _saving || !_key.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final result = _result;
      final currentCep = _cep.text.replaceAll(RegExp(r'\D'), '');
      final initialCep = widget.initial?.cep.replaceAll(RegExp(r'\D'), '');
      final changedCepWithoutResult =
          widget.initial != null && initialCep != currentCep && result == null;
      final addressDoesNotMatchResult =
          result != null &&
          (normalizedText(_street.text) != normalizedText(result.street) ||
              normalizedText(_city.text) != normalizedText(result.city));
      if (changedCepWithoutResult || addressDoesNotMatchResult) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(
              changedCepWithoutResult
                  ? 'O CEP mudou e não foi possível confirmar o novo endereço. '
                        'O logradouro e a cidade podem ser os do CEP anterior. '
                        'Deseja salvar mesmo assim?'
                  : 'O endereço informado não corresponde ao CEP consultado. '
                        'Deseja continuar mesmo assim?',
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
      await widget.onSaved(
        SavedAddress(
          id:
              widget.initial?.id ??
              'address-${DateTime.now().microsecondsSinceEpoch}',
          street: _street.text.trim(),
          name: _name.text.trim(),
          city: _city.text.trim(),
          number: _number.text.trim(),
          complement: _complement.text.trim(),
          cep: _cep.text.trim(),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _skip() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSkip?.call();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final initial = widget.initial;
    final onDelete = widget.onDelete;
    if (_saving || initial == null || onDelete == null) return;
    setState(() => _saving = true);
    try {
      await onDelete(initial);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    String label,
    IconData icon,
    TextEditingController controller, {
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) {
    final registrationLayout =
        widget.onSkip != null &&
        MediaQuery.sizeOf(context).width < VH.desktopBreakpoint;
    final editingLayout =
        widget.initial != null &&
        widget.onDelete != null &&
        MediaQuery.sizeOf(context).width < VH.desktopBreakpoint;
    return VHField(
      label,
      icon,
      compact: true,
      figmaForm: registrationLayout || editingLayout,
      labelAbove: true,
      labelHorizontalPadding: registrationLayout || editingLayout ? 5 : null,
      labelBottomPadding: registrationLayout || editingLayout ? 0 : null,
      fitSingleLine: true,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint;
    final registration = widget.onSkip != null && !desktop;
    final editing =
        widget.initial != null && widget.onDelete != null && !desktop;
    final figmaEditing = widget.figmaEditLayout && editing;
    final saveLabel = widget.onSkip != null
        ? 'Continuar'
        : editing
        ? 'Salvar'
        : 'Salvar endereço';
    final saveBackgroundColor = editing ? VH.primary : VH.secondary;
    final saveForegroundColor = editing
        ? Colors.white
        : VetColors.calendarTextOnRose;
    final saveButton = ElevatedButton(
      onPressed: _loading || _saving ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: saveBackgroundColor,
        foregroundColor: saveForegroundColor,
        shape: const StadiumBorder(),
        textStyle: TextStyle(
          fontFamily: VH.headingFontFamily,
          fontSize: registration ? 18 : 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(
        _saving ? 'Salvando…' : saveLabel,
        maxLines: 1,
        softWrap: false,
      ),
    );
    final deleteButton = editing
        ? SizedBox(
            width: 90,
            height: 34,
            child: OutlinedButton(
              onPressed: _saving ? null : _delete,
              style: OutlinedButton.styleFrom(
                backgroundColor: VH.background,
                foregroundColor: VH.foreground,
                side: BorderSide(color: Colors.white.withValues(alpha: .8)),
                elevation: 2,
                shadowColor: VH.foreground.withValues(alpha: .2),
                padding: EdgeInsets.zero,
                shape: const StadiumBorder(),
                textStyle: TextStyle(
                  fontFamily: VH.headingFontFamily,
                  fontSize: figmaEditing ? 15 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('Excluir'),
            ),
          )
        : null;

    if (figmaEditing) return _figmaEditorContent(saveButton, deleteButton!);

    return Align(
      alignment: registration ? Alignment.topCenter : Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: desktop ? 900 : 440),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeight = !registration && constraints.maxHeight < 680;
            // Align halves its -1..1 range; this places the panel at x=49.
            final registrationPanelAlignment =
                registration && constraints.maxWidth > 322
                ? -2 / (constraints.maxWidth - 32 - 290)
                : 0.0;
            final content = Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                registration
                    ? 31
                    : compactHeight
                    ? 12
                    : 16,
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
                      height: registration ? 1.2 : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: registration
                        ? 21
                        : compactHeight
                        ? 12
                        : 16,
                  ),
                  Align(
                    alignment: Alignment(registrationPanelAlignment, 0),
                    child: SizedBox(
                      width: registration ? 290 : double.infinity,
                      height: registration ? 565 : null,
                      child: Container(
                        key: registration
                            ? const ValueKey('address-registration-panel')
                            : null,
                        clipBehavior: registration ? Clip.antiAlias : Clip.none,
                        padding: EdgeInsets.fromLTRB(
                          registration ? 11 : 10,
                          registration
                              ? 11
                              : compactHeight
                              ? 8
                              : 10,
                          registration ? 14 : 10,
                          registration
                              ? 9
                              : compactHeight
                              ? 8
                              : 10,
                        ),
                        decoration: registration
                            ? inset_shadow.BoxDecoration(
                                color: Colors.white.withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: VH.secondary,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  inset_shadow.BoxShadow(
                                    color: VetColors.shadowDark,
                                    offset: Offset(2, 2),
                                    blurRadius: 5,
                                    inset: true,
                                  ),
                                ],
                              )
                            : BoxDecoration(
                                color: VH.secondary.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: VH.secondary.withValues(alpha: .3),
                                  width: 1,
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
                                runSpacing: registration
                                    ? 16.25
                                    : compactHeight
                                    ? 8
                                    : 10,
                                children: [
                                  slot(
                                    _field(
                                      'CEP',
                                      Icons.home_outlined,
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
                                      registration || editing
                                          ? 'Logradouro'
                                          : 'Endereço',
                                      Icons.home_outlined,
                                      _street,
                                      validator: _required,
                                    ),
                                    full: true,
                                  ),
                                  slot(
                                    _field(
                                      'Numero',
                                      Icons.numbers,
                                      _number,
                                      validator: _required,
                                    ),
                                  ),
                                  slot(
                                    _field(
                                      'Complemento',
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
                                  slot(
                                    _field('Nome', Icons.home_outlined, _name),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: registration
                        ? 30
                        : compactHeight
                        ? 12
                        : 16,
                  ),
                  editing
                      ? Center(
                          child: SizedBox(
                            width: 259,
                            height: 34,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                deleteButton!,
                                SizedBox(
                                  width: 90,
                                  height: 34,
                                  child: saveButton,
                                ),
                              ],
                            ),
                          ),
                        )
                      : registration
                      ? Center(
                          child: SizedBox(
                            width: 181,
                            height: 65,
                            child: saveButton,
                          ),
                        )
                      : SizedBox(height: 48, child: saveButton),
                  if (widget.onSkip != null) ...[
                    const SizedBox(height: 2),
                    TextButton(
                      style: widget.skipButtonStyle,
                      onPressed: _saving ? null : _skip,
                      child: Text(_saving ? 'Salvando…' : 'Pular'),
                    ),
                  ],
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

  Widget _figmaEditorContent(ElevatedButton saveButton, Widget deleteButton) {
    Widget field(
      String label,
      IconData icon,
      TextEditingController controller, {
      FormFieldValidator<String>? validator,
      ValueChanged<String>? onChanged,
      required double top,
    }) => Positioned(
      left: 15,
      top: top,
      width: 259,
      child: _field(
        label,
        icon,
        controller,
        validator: validator,
        onChanged: onChanged,
      ),
    );

    return SizedBox.expand(
      child: Form(
        key: _key,
        child: Stack(
          children: [
            field(
              'CEP',
              Icons.home_outlined,
              _cep,
              onChanged: _lookup,
              validator: (value) =>
                  (value ?? '').replaceAll(RegExp(r'\D'), '').length == 8
                  ? null
                  : 'Informe um CEP com 8 números',
              top: 14,
            ),
            field(
              'Logradouro',
              Icons.home_outlined,
              _street,
              validator: _required,
              top: 106,
            ),
            field(
              'Numero',
              Icons.numbers,
              _number,
              validator: _required,
              top: 199,
            ),
            field('Complemento', Icons.home_outlined, _complement, top: 291),
            field(
              'Cidade',
              Icons.location_city_outlined,
              _city,
              validator: _required,
              top: 383,
            ),
            field('Nome', Icons.home_outlined, _name, top: 475),
            if (_status.isNotEmpty)
              Positioned(
                left: 20,
                top: 90,
                width: 254,
                height: 14,
                child: Semantics(
                  liveRegion: true,
                  label: _status,
                  child: ExcludeSemantics(
                    child: Text(
                      _status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 15,
              top: 562,
              child: FigmaActionTarget(
                key: const ValueKey('address-delete-target'),
                width: 90,
                label: 'Excluir endereço',
                onPressed: _saving ? null : _delete,
                child: deleteButton,
              ),
            ),
            Positioned(
              left: 184,
              top: 562,
              width: 90,
              height: 48,
              child: FigmaActionTarget(
                key: const ValueKey('address-save-target'),
                width: 90,
                label: 'Salvar endereço',
                onPressed: _loading || _saving ? null : _save,
                child: SizedBox(width: 90, height: 34, child: saveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Preencha este campo' : null;
}
