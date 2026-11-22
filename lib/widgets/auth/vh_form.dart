import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/utils/form_fields.dart';
import '../../theme.dart';
import '../../widgets.dart';
import 'demo_mode_notice.dart';
import 'registration_actions_footer.dart';

const _registerScrollIndicatorAsset =
    'assets/imagens/figma/register-scroll-indicator.svg';

class VHForm extends StatefulWidget {
  const VHForm({
    super.key,
    required this.title,
    required this.fields,
    required this.next,
    this.initialData = const {},
    this.dataPrefix = '',
    this.guidance,
  });

  final String title;
  final List<VHField> fields;
  final String next;
  final Map<String, String> initialData;
  final String dataPrefix;
  final String? guidance;

  @override
  State<VHForm> createState() => _VHFormState();
}

class _VHFormState extends State<VHForm> {
  final _formKey = GlobalKey<FormState>();
  bool _hasAttemptedSubmit = false;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<GlobalKey<State<StatefulWidget>>> _fieldKeys;

  @override
  void initState() {
    super.initState();
    _controllers = _makeControllers();
    _focusNodes = _makeFocusNodes();
    _fieldKeys = _makeFieldKeys();
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
      for (final focusNode in _focusNodes) {
        focusNode.dispose();
      }
      _controllers = _makeControllers();
      _focusNodes = _makeFocusNodes();
      _fieldKeys = _makeFieldKeys();
    }
  }

  List<TextEditingController> _makeControllers() => [
    for (final field in widget.fields)
      TextEditingController(
        text: widget.initialData['${widget.dataPrefix}${field.label}'] ?? '',
      ),
  ];

  List<FocusNode> _makeFocusNodes() => [
    for (final field in widget.fields) FocusNode(debugLabel: field.label),
  ];

  List<GlobalKey<State<StatefulWidget>>> _makeFieldKeys() => [
    for (var i = 0; i < widget.fields.length; i++)
      GlobalKey<State<StatefulWidget>>(),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String? _validate(VHField field, String? rawValue) {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) {
      return field.label == 'Complemento' ? null : 'Preencha este campo';
    }
    if (field.label == 'E-mail' && !isValidTutorEmail(value)) {
      return 'Informe um e-mail válido';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (field.label == 'CPF') {
      if (digits.length != 11) return 'Informe um CPF com 11 dígitos';
      if (!isValidCpf(value)) return 'Informe um CPF válido';
    }
    if (field.label == 'Telefone/Celular' &&
        digits.length != 10 &&
        digits.length != 11) {
      return 'Informe um telefone com 10 ou 11 dígitos';
    }
    if (field.label == 'Senha' && (rawValue ?? '').length < 6) {
      return 'Use ao menos 6 caracteres';
    }
    if (field.label == 'Confirmar Senha' &&
        widget.fields.any((item) => item.label == 'Senha') &&
        (rawValue ?? '') !=
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

  void _focusFirstInvalidField() {
    for (var i = 0; i < widget.fields.length; i++) {
      if (_validate(widget.fields[i], _controllers[i].text) == null) continue;

      final focusNode = _focusNodes[i];
      final fieldContext = _fieldKeys[i].currentContext;
      focusNode.requestFocus();
      if (fieldContext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !fieldContext.mounted) return;
          Scrollable.ensureVisible(
            fieldContext,
            duration: const Duration(milliseconds: 250),
            alignment: .2,
            curve: Curves.easeOut,
          );
        });
      }
      return;
    }
  }

  void _continue() {
    if (ModalRoute.isCurrentOf(context) != true) return;
    if (!_hasAttemptedSubmit) {
      setState(() => _hasAttemptedSubmit = true);
    }
    if (!_formKey.currentState!.validate()) {
      _focusFirstInvalidField();
      return;
    }
    final data = withoutRegistrationPasswords(<String, String>{
      ...widget.initialData,
      for (var i = 0; i < widget.fields.length; i++)
        if (!widget.fields[i].password)
          '${widget.dataPrefix}${widget.fields[i].label}': _controllers[i].text
              .trim(),
    });
    Navigator.pushNamed(context, widget.next, arguments: data);
  }

  Widget _buildField(int i) {
    final field = widget.fields[i];
    final mobileRegistration =
        widget.dataPrefix == 'client.' &&
        MediaQuery.sizeOf(context).width < VH.desktopBreakpoint;
    final registrationIcon = switch (field.label) {
      'Nome Completo' => 'name',
      'Data de Nascimento' => 'birth',
      'CPF' => 'cpf',
      'Telefone/Celular' => 'phone',
      'E-mail' => 'email',
      'Senha' => 'password',
      'Confirmar Senha' => 'confirm',
      _ => null,
    };
    return VHField(
      field.label,
      field.icon,
      key: _fieldKeys[i],
      focusNode: _focusNodes[i],
      password: field.password,
      figmaForm: true,
      circularPrefix: widget.dataPrefix == 'client.',
      circularPrefixDiameter: widget.dataPrefix == 'client.' ? 56 : null,
      circularPrefixWidth: widget.dataPrefix == 'client.' ? 71 : null,
      labelAbove: true,
      showErrorBelowSurface: true,
      labelHorizontalPadding: mobileRegistration ? 7 : null,
      labelBottomPadding: mobileRegistration ? 0 : null,
      figmaPrefixIconAsset:
          widget.dataPrefix == 'client.' && registrationIcon != null
          ? 'assets/imagens/figma/register-$registrationIcon.svg'
          : null,
      controller: _controllers[i],
      value: field.value,
      keyboardType: field.keyboardType,
      inputFormatters: field.label == 'Telefone/Celular'
          ? const [PhoneMask(acceptBrazilCountryCode: true)]
          : null,
      textInputAction: widget.dataPrefix == 'client.'
          ? i == widget.fields.length - 1
                ? TextInputAction.done
                : TextInputAction.next
          : null,
      onFieldSubmitted: widget.dataPrefix != 'client.'
          ? null
          : (_) {
              if (i + 1 < _focusNodes.length) {
                _focusNodes[i + 1].requestFocus();
              } else {
                _continue();
              }
            },
      choices: field.choices,
      onChanged: (value) {
        setState(() {});
      },
      validator: (value) => _validate(field, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final desktop = viewport.width >= VH.desktopBreakpoint;
    final mobileRegistration = widget.dataPrefix == 'client.' && !desktop;
    final usableHeight =
        viewport.height - MediaQuery.viewInsetsOf(context).bottom;
    final textScaler = MediaQuery.textScalerOf(context);
    final fieldRows = desktop
        ? (widget.fields.length + 1) ~/ 2
        : widget.fields.length;
    final scaledTextGrowth = (textScaler.scale(28) - 28).clamp(
      0,
      double.infinity,
    );
    final formHeight =
        (desktop ? 640 : 860) +
        fieldRows *
            (scaledTextGrowth +
                (_hasAttemptedSubmit ? textScaler.scale(20) : 0));
    final pinContinue =
        widget.dataPrefix == 'client.' && usableHeight < formHeight;
    final showRegisterScrollIndicator =
        mobileRegistration &&
        !pinContinue &&
        viewport.width <= 430 &&
        viewport.height >= 700;
    final centeredFormOffset = ((viewport.width - 390) / 2)
        .clamp(0.0, double.infinity)
        .toDouble();
    final continueButton = Center(
      child: PillButton(
        color: VH.primary,
        padding: EdgeInsets.zero,
        onTap: _continue,
        child: SizedBox(
          width:
              181 + (textScaler.scale(18) - 18).clamp(0, 54).toDouble() * 4.5,
          height: usableHeight < 320 ? 54 : 71,
          child: const Center(
            child: Text('Continuar', style: VH.figmaButtonTextStyle),
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: VH.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: desktop ? 900 : 390,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          desktop
                              ? 32
                              : 33 *
                                    (MediaQuery.sizeOf(context).width / 390)
                                        .clamp(.8, 1.0),
                          widget.dataPrefix == 'client.' ? 8 : 38,
                          desktop
                              ? 32
                              : 33 *
                                    (MediaQuery.sizeOf(context).width / 390)
                                        .clamp(.8, 1.0),
                          RegistrationActionsFooter.contentSpacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.dataPrefix == 'client.') ...[
                              const Center(
                                child: DemoModeNotice(
                                  compact: true,
                                  message: 'Demonstração · dados fictícios',
                                  semanticLabel:
                                      'Protótipo demonstrativo. Não há contas individuais. As informações ficam neste dispositivo; use apenas dados fictícios.',
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
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
                            SizedBox(height: mobileRegistration ? 14 : 25),
                            if (widget.guidance case final guidance?) ...[
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  guidance,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: VH.foreground),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Container(
                              padding: mobileRegistration
                                  ? const EdgeInsets.fromLTRB(13, 11, 13, 17)
                                  : const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: VH.secondary,
                                  width: 3,
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: _hasAttemptedSubmit
                                    ? AutovalidateMode.onUserInteraction
                                    : AutovalidateMode.disabled,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final fieldWidth = desktop
                                        ? (constraints.maxWidth - 14) / 2
                                        : constraints.maxWidth;
                                    return Wrap(
                                      key: ValueKey(
                                        desktop
                                            ? 'vh-form-desktop-grid'
                                            : 'vh-form-mobile-grid',
                                      ),
                                      spacing: 14,
                                      runSpacing: mobileRegistration ? 0 : 14,
                                      children: [
                                        for (
                                          var i = 0;
                                          i < widget.fields.length;
                                          i++
                                        )
                                          SizedBox(
                                            width: fieldWidth,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                top:
                                                    !mobileRegistration ||
                                                        i == 0
                                                    ? 0
                                                    : widget.fields[i].label ==
                                                          'CPF'
                                                    ? 4
                                                    : 16,
                                              ),
                                              child: _buildField(i),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (!pinContinue) ...[
                              const SizedBox(height: 32),
                              continueButton,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showRegisterScrollIndicator)
                    Positioned(
                      right: centeredFormOffset + 15.5,
                      top: 369,
                      child: IgnorePointer(
                        child: ExcludeSemantics(
                          child: RotatedBox(
                            key: const ValueKey('register-scroll-indicator'),
                            quarterTurns: 1,
                            child: SizedBox(
                              width: 328.001,
                              height: 3,
                              child: SvgPicture.asset(
                                _registerScrollIndicatorAsset,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (pinContinue) RegistrationActionsFooter(child: continueButton),
          ],
        ),
      ),
    );
  }
}
