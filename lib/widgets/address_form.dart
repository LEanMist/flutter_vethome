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
import 'auth/registration_actions_footer.dart';

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
    this.saveErrorMessage,
    this.pinSaveAction = false,
    this.routeButton,
  });
  final String title;
  final FutureOr<void> Function(SavedAddress) onSaved;
  final FutureOr<void> Function()? onSkip;
  final ButtonStyle? skipButtonStyle;
  final FutureOr<void> Function(SavedAddress)? onDelete;
  final SavedAddress? initial;
  final CepService cepService;
  final bool figmaEditLayout;
  final String Function(Object error)? saveErrorMessage;
  final bool pinSaveAction;
  final Widget? routeButton;
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
  CepResult? _autofilled;
  String _status = '';
  int _request = 0;
  bool _loading = false;
  bool _saving = false;
  bool _validationAttempted = false;
  bool get _registering => widget.onSkip != null;
  late final _registrationFocus = <TextEditingController, FocusNode>{
    for (final field in [_cep, _street, _number, _complement, _city])
      field: FocusNode(),
  };
  @override
  void dispose() {
    for (final focus in _registrationFocus.values) {
      focus.dispose();
    }
    for (final c in [_cep, _street, _city, _number, _complement]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _lookup(String text) async {
    final request = ++_request;
    _result = null;
    if (_autofilled case final previous? when _registering) {
      if (_street.text == previous.street) _street.clear();
      if (_city.text == previous.city) _city.clear();
      _autofilled = null;
    }
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
        _status = switch (result) {
          null => 'CEP não encontrado. Confira ou preencha manualmente.',
          CepResult(street: '', city: _) when _registering =>
            'Informe o logradouro.',
          _ when _registering => '',
          _ => 'CEP consultado.',
        };
        if (result != null) {
          final fillStreet =
              _street.text == streetBefore &&
              (!_registering ||
                  (_street.text.isEmpty && result.street.isNotEmpty));
          final fillCity =
              _city.text == cityBefore &&
              (!_registering || (_city.text.isEmpty && result.city.isNotEmpty));
          if (fillStreet) _street.text = result.street;
          if (fillCity) _city.text = result.city;
          if (_registering) {
            _autofilled = CepResult(
              fillStreet ? result.street : '',
              fillCity ? result.city : '',
            );
          }
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
    if (_loading || _saving) return;
    final invalidFields = _key.currentState!.validateGranularly();
    if (invalidFields.isNotEmpty) {
      if (mounted && !_validationAttempted) {
        setState(() => _validationAttempted = true);
      }
      if (_registering) {
        final invalid = _cepError(_cep.text) != null
            ? _cep
            : [
                _street,
                _number,
                _city,
              ].firstWhere((field) => _required(field.text) != null);
        _registrationFocus[invalid]?.requestFocus();
      } else if (widget.initial == null && widget.onSkip == null) {
        final firstInvalid = invalidFields.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (firstInvalid.mounted) {
            // Mantenha o rótulo acima do campo dentro da área visível.
            Scrollable.ensureVisible(firstInvalid.context, alignment: .12);
          }
        });
      }
      return;
    }
    setState(() => _saving = true);
    try {
      final result = _result;
      final currentCep = _cep.text.replaceAll(RegExp(r'\D'), '');
      final initialCep = widget.initial?.cep.replaceAll(RegExp(r'\D'), '');
      final changedCepWithoutResult =
          widget.initial != null && initialCep != currentCep && result == null;
      final addressDoesNotMatchResult =
          result != null &&
          ((!_registering || result.street.isNotEmpty) &&
                  normalizedText(_street.text) !=
                      normalizedText(result.street) ||
              (!_registering || result.city.isNotEmpty) &&
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
          name: widget.initial?.name ?? '',
          city: _city.text.trim(),
          number: _number.text.trim(),
          complement: _complement.text.trim(),
          cep: _cep.text.trim(),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message =
          widget.saveErrorMessage?.call(error) ??
          (widget.onSkip != null
              ? 'Não foi possível continuar. Os dados digitados continuam no '
                    'formulário; confira e tente novamente.'
              : 'Não foi possível confirmar o salvamento. Os dados digitados '
                    'continuam no formulário; confira a lista antes de tentar '
                    'novamente.');
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            widget.onSkip != null
                ? 'Não foi possível continuar'
                : 'Endereço não salvo',
          ),
          content: Semantics(
            liveRegion: true,
            child: Text(
              message,
              key: const ValueKey('address-save-error-message'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendi'),
            ),
          ],
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
      key: ValueKey(label),
      compact: true,
      figmaForm: _registering || editingLayout,
      circularPrefix: _registering,
      figmaFillColor: editingLayout
          ? VH.secondary.withValues(alpha: .25)
          : null,
      textAlign: editingLayout ? TextAlign.center : TextAlign.start,
      figmaContentPaddingRight: editingLayout ? 34 : null,
      labelAbove: true,
      showErrorBelowSurface: _registering,
      focusNode: _registering ? _registrationFocus[controller] : null,
      textInputAction: !_registering
          ? null
          : identical(controller, _city)
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: _registering && identical(controller, _city)
          ? (_) => _save()
          : null,
      labelHorizontalPadding: registrationLayout || editingLayout ? 5 : null,
      labelBottomPadding: registrationLayout || editingLayout ? 0 : null,
      fitSingleLine: true,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
    );
  }

  String? _cepError(String? value) =>
      (value ?? '').replaceAll(RegExp(r'\D'), '').length == 8
      ? null
      : 'Informe um CEP com 8 números';

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
    final saveBackgroundColor = editing || _registering
        ? VH.primary
        : VH.secondary;
    final saveForegroundColor = editing || _registering
        ? Colors.white
        : VetColors.calendarTextOnRose;
    final saveText = Text(
      _saving ? 'Salvando…' : saveLabel,
      maxLines: 1,
      softWrap: false,
    );
    final saveButton = ElevatedButton(
      onPressed: _loading || _saving ? null : _save,
      style: _registering
          ? VH.continueButtonStyle
          : ElevatedButton.styleFrom(
              backgroundColor: saveBackgroundColor,
              foregroundColor: saveForegroundColor,
              padding: figmaEditing
                  ? const EdgeInsets.symmetric(horizontal: 5)
                  : null,
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontFamily: VH.headingFontFamily,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
      child: figmaEditing
          ? FittedBox(fit: BoxFit.scaleDown, child: saveText)
          : saveText,
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
              child: figmaEditing
                  ? const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Excluir'),
                    )
                  : const Text('Excluir'),
            ),
          )
        : null;

    if (figmaEditing) {
      return _figmaEditorContent(
        saveButton,
        deleteButton!,
        routeButton: widget.routeButton,
      );
    }

    return Align(
      alignment: registration ? Alignment.topCenter : Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: desktop ? 900 : 440),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeight = !registration && constraints.maxHeight < 680;
            final textScale = MediaQuery.textScalerOf(context).scale(15) / 15;
            final compactRegistration =
                _registering &&
                constraints.maxHeight <
                    (desktop ? 570 : 793) + (textScale - 1).clamp(0, 3) * 150;
            final pinRegistrationActions =
                constraints.maxHeight >= 190 &&
                (compactRegistration ||
                    (_registering &&
                        constraints.maxHeight <
                            (desktop ? 570 : 793) +
                                (_validationAttempted ? 80 : 0) +
                                (_status.isNotEmpty ? 40 : 0)));
            final skipButton = TextButton(
              style: widget.skipButtonStyle,
              onPressed: _saving ? null : _skip,
              child: const Text('Pular'),
            );
            final registrationActions = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 181 + (textScale - 1).clamp(0, 3).toDouble() * 80,
                  height: constraints.maxHeight < 320 ? 54 : 65,
                  child: saveButton,
                ),
                if (pinRegistrationActions) const SizedBox(height: 8),
                skipButton,
              ],
            );
            final pinPrimaryAction =
                widget.pinSaveAction &&
                !desktop &&
                !registration &&
                !editing &&
                widget.onSkip == null &&
                constraints.maxHeight < 680;
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
                registration || pinRegistrationActions ? 0 : 16,
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
                      color: VH.foreground,
                    ),
                  ),
                  SizedBox(
                    height: registration
                        ? (compactRegistration ? 16 : 70)
                        : compactHeight
                        ? 12
                        : 16,
                  ),
                  Align(
                    alignment: Alignment(registrationPanelAlignment, 0),
                    child: SizedBox(
                      width: registration ? 290 : double.infinity,
                      child: Container(
                        key: registration
                            ? const ValueKey('address-registration-panel')
                            : null,
                        constraints: registration
                            ? const BoxConstraints(minHeight: 473)
                            : null,
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
                        decoration: _registering
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
                          autovalidateMode: _registering && _validationAttempted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final half = (constraints.maxWidth - 12) / 2;
                              Widget slot(Widget child, {bool full = false}) =>
                                  SizedBox(
                                    key: child.key,
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
                                      _registering
                                          ? Icons.location_on
                                          : Icons.home_outlined,
                                      _cep,
                                      onChanged: _lookup,
                                      validator: _cepError,
                                    ),
                                  ),
                                  if (_status.isNotEmpty)
                                    slot(
                                      Semantics(
                                        key: const ValueKey(
                                          'address-cep-status',
                                        ),
                                        liveRegion: true,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            12,
                                            _registering ? 0 : 28,
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
                                      _registering || editing
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
                                      _registering ? 'Número' : 'Numero',
                                      Icons.numbers,
                                      _number,
                                      validator: _required,
                                    ),
                                  ),
                                  slot(
                                    _field(
                                      'Complemento',
                                      _registering
                                          ? Icons.meeting_room_outlined
                                          : Icons.home_outlined,
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
                                    full: true,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_registering && !pinRegistrationActions) ...[
                    SizedBox(height: registration ? 53 : 16),
                    Center(child: registrationActions),
                  ],
                  if (!pinPrimaryAction && !_registering) ...[
                    SizedBox(height: compactHeight ? 12 : 16),
                    editing
                        ? Center(
                            child: SizedBox(
                              width: 259,
                              height: 34,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                        : SizedBox(height: 48, child: saveButton),
                  ],
                ],
              ),
            );

            if (pinRegistrationActions) {
              return Column(
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        bottom: RegistrationActionsFooter.contentSpacing,
                      ),
                      child: content,
                    ),
                  ),
                  RegistrationActionsFooter(
                    child: Center(child: registrationActions),
                  ),
                ],
              );
            }
            if (pinPrimaryAction) {
              return Column(
                children: [
                  Expanded(child: SingleChildScrollView(child: content)),
                  Padding(
                    key: const ValueKey('address-form-pinned-save-footer'),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: saveButton,
                    ),
                  ),
                ],
              );
            }

            return _registering ||
                    !desktop ||
                    constraints.maxHeight < 700 ||
                    MediaQuery.viewInsetsOf(context).bottom > 0
                ? SingleChildScrollView(child: content)
                : Align(alignment: Alignment.topCenter, child: content);
          },
        ),
      ),
    );
  }

  Widget _figmaEditorContent(
    ElevatedButton saveButton,
    Widget deleteButton, {
    Widget? routeButton,
  }) {
    Widget field(
      String label,
      IconData icon,
      TextEditingController controller, {
      FormFieldValidator<String>? validator,
      ValueChanged<String>? onChanged,
      double minHeight = 92,
      Widget? status,
    }) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              label,
              icon,
              controller,
              validator: validator,
              onChanged: onChanged,
            ),
            ?status,
          ],
        ),
      ),
    );

    return Form(
      key: _key,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 14, 16, 23),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              status: _status.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _status,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
            ),
            field(
              'Logradouro',
              Icons.home_outlined,
              _street,
              validator: _required,
              minHeight: 93,
            ),
            field('Numero', Icons.numbers, _number, validator: _required),
            field('Complemento', Icons.home_outlined, _complement),
            field(
              'Cidade',
              Icons.location_city_outlined,
              _city,
              validator: _required,
            ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8,
              children: [
                FigmaActionTarget(
                  key: const ValueKey('address-delete-target'),
                  width: 90,
                  label: 'Excluir endereço',
                  onPressed: _saving ? null : _delete,
                  child: deleteButton,
                ),
                ?routeButton,
                FigmaActionTarget(
                  key: const ValueKey('address-save-target'),
                  width: 90,
                  label: 'Salvar endereço',
                  onPressed: _loading || _saving ? null : _save,
                  child: SizedBox(width: 90, height: 34, child: saveButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Preencha este campo' : null;
}
