import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/utils/form_fields.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import 'pages/teste_page.dart';
import 'theme.dart';
import 'widgets/vet/vet_bottom_nav.dart';

BoxDecoration insetBox({
  required Color color,
  double radius = VH.radiusCard,
  Gradient? gradient,
}) {
  return inset_shadow.BoxDecoration(
    color: color,
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      inset_shadow.BoxShadow(
        color: VH.shadowSubtle,
        offset: Offset(2, 2),
        blurRadius: 2,
        inset: true,
      ),
    ],
  );
}

class VHField extends StatefulWidget {
  const VHField(
    this.label,
    this.icon, {
    super.key,
    this.value,
    this.password = false,
    this.controller,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.choices,
    this.choiceDisplayLabel,
    this.semanticsValue,
    this.suffixText,
    this.suggestions = const [],
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.figmaContentPaddingLeft,
    this.figmaContentPaddingRight,
    this.figmaForm = false,
    this.showChoiceIndicator = true,
    this.compact = false,
    this.labelAbove = false,
    this.labelHorizontalPadding,
    this.labelBottomPadding,
    this.labelFitSingleLine = false,
    this.fitSingleLine = false,
  });
  final bool figmaForm;
  final bool showChoiceIndicator;
  final bool compact;
  final bool labelAbove;
  final double? labelHorizontalPadding;
  final double? labelBottomPadding;
  final bool labelFitSingleLine;
  final bool fitSingleLine;
  final String label;
  final IconData icon;
  final String? value;
  final bool password;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<String>? choices;
  final String Function(String)? choiceDisplayLabel;
  final String? Function(String)? semanticsValue;
  final String? suffixText;
  final List<String> suggestions;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final double? figmaContentPaddingLeft;
  final double? figmaContentPaddingRight;
  @override
  State<VHField> createState() => _VHFieldState();
}

class _VHFieldState extends State<VHField> {
  late final _owned = TextEditingController(text: widget.value ?? '');
  late FocusNode _focus;
  bool _ownsFocus = false;
  int _activeChoiceIndex = 0;
  bool _keyboardChoiceInteraction = false;
  final ScrollController _choiceScrollController = ScrollController();
  final ValueNotifier<String?> _validationError = ValueNotifier(null);
  final _link = LayerLink();
  OverlayEntry? _options;
  bool _openAbove = false;
  static _VHFieldState? _opened;
  bool get isOpen => _options != null;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _ownsFocus = widget.focusNode == null;
    _focus.addListener(_handleChoiceFocusChange);
  }

  @override
  void didUpdateWidget(covariant VHField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) return;
    _focus.removeListener(_handleChoiceFocusChange);
    if (_ownsFocus) _focus.dispose();
    _focus = widget.focusNode ?? FocusNode();
    _ownsFocus = widget.focusNode == null;
    _focus.addListener(_handleChoiceFocusChange);
  }

  void _handleChoiceFocusChange() {
    if (!mounted) return;
    if (!_focus.hasFocus && isOpen) {
      _closeChoices();
      return;
    }
    setState(() {});
  }

  String? _validateChoice(String? value) {
    final error = widget.validator?.call(value);
    if (_validationError.value != error) _validationError.value = error;
    return error;
  }

  void _closeChoices({bool rebuild = true}) {
    _options?.remove();
    _options?.dispose();
    _options = null;
    if (_opened == this) _opened = null;
    _keyboardChoiceInteraction = false;
    if (mounted && rebuild) setState(() {});
  }

  void _toggleChoices({bool keyboard = false}) {
    if (isOpen) {
      _closeChoices();
      return;
    }
    _opened?._closeChoices();
    _opened = this;
    final selectedIndex = widget.choices!.indexOf(controller.text);
    _activeChoiceIndex = selectedIndex < 0 ? 0 : selectedIndex;
    _keyboardChoiceInteraction = keyboard;
    final box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
    final media = MediaQuery.of(context);
    final availableBelow =
        media.size.height -
        media.padding.bottom -
        media.viewInsets.bottom -
        bottom;
    final availableAbove = top - media.padding.top;
    final desiredHeight =
        (widget.choices!.length * 48.0 + widget.choices!.length - 1)
            .clamp(48.0, 192.0)
            .toDouble();
    _openAbove =
        availableBelow < desiredHeight && availableAbove > availableBelow;
    final availableHeight = (_openAbove ? availableAbove : availableBelow)
        .clamp(0.0, desiredHeight)
        .toDouble();
    _options = OverlayEntry(
      builder: (ctx) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: _openAbove ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor: _openAbove ? Alignment.bottomLeft : Alignment.topLeft,
          offset: Offset.zero,
          child: TapRegion(
            groupId: this,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 160),
              builder: (_, value, child) =>
                  Opacity(opacity: value, child: child),
              child: Material(
                color: VH.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: _openAbove
                      ? const BorderRadius.vertical(top: Radius.circular(20))
                      : const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                  side: BorderSide(color: VH.secondary.withValues(alpha: .65)),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: availableHeight,
                  child: ListView.separated(
                    controller: _choiceScrollController,
                    padding: EdgeInsets.zero,
                    itemCount: widget.choices!.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: .5,
                      color: VH.secondary.withValues(alpha: .35),
                    ),
                    itemBuilder: (_, index) {
                      final value = widget.choices![index];
                      return ListTile(
                        minTileHeight: 48,
                        dense: true,
                        title: Text(
                          widget.choiceDisplayLabel?.call(value) ?? value,
                        ),
                        selected: controller.text == value,
                        tileColor:
                            _keyboardChoiceInteraction &&
                                _activeChoiceIndex == index
                            ? Theme.of(ctx).focusColor
                            : null,
                        onTap: () => _selectChoice(index),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_options!);
    setState(() {});
  }

  void _selectChoice(int index) {
    final choices = widget.choices;
    if (choices == null || index < 0 || index >= choices.length) return;
    controller.text = choices[index];
    _validateChoice(controller.text);
    _closeChoices();
    _focus.requestFocus();
    widget.onChanged?.call(controller.text);
  }

  void _moveActiveChoice(int delta) {
    final choices = widget.choices;
    if (choices == null || choices.isEmpty) return;
    setState(() {
      _activeChoiceIndex =
          (_activeChoiceIndex + delta + choices.length) % choices.length;
      _keyboardChoiceInteraction = true;
    });
    _options?.markNeedsBuild();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !isOpen || !_choiceScrollController.hasClients) return;
      final position = _choiceScrollController.position;
      const itemHeight = 48.0;
      const separatorHeight = 1.0;
      final itemTop = _activeChoiceIndex * (itemHeight + separatorHeight);
      final itemBottom = itemTop + itemHeight;
      var targetOffset = position.pixels;
      if (itemTop < position.pixels) {
        targetOffset = itemTop;
      } else if (itemBottom > position.pixels + position.viewportDimension) {
        targetOffset = itemBottom - position.viewportDimension;
      }
      targetOffset = targetOffset
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      if ((targetOffset - position.pixels).abs() > 0.5) {
        _choiceScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  KeyEventResult _handleChoiceKeyEvent(FocusNode node, KeyEvent event) {
    final choices = widget.choices;
    if (choices == null || event is! KeyDownEvent || choices.isEmpty) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      if (isOpen) {
        _selectChoice(_activeChoiceIndex);
      } else {
        _toggleChoices(keyboard: true);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final delta = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
      if (!isOpen) {
        _toggleChoices(keyboard: true);
        if (delta < 0) _moveActiveChoice(delta);
      } else {
        _moveActiveChoice(delta);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape && isOpen) {
      _closeChoices();
      _focus.requestFocus();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.tab && isOpen) {
      _closeChoices();
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  TextEditingController get controller => widget.controller ?? _owned;
  @override
  void dispose() {
    _focus.removeListener(_handleChoiceFocusChange);
    _closeChoices(rebuild: false);
    _validationError.dispose();
    _owned.dispose();
    _choiceScrollController.dispose();
    if (_ownsFocus) _focus.dispose();
    super.dispose();
  }

  List<TextInputFormatter>? get formatters =>
      widget.inputFormatters ??
      switch (widget.label) {
        'Data de nascimento' ||
        'Data de Nascimento' ||
        'Nascimento (DD/MM/AAAA)' => [const DigitsMask('##/##/####')],
        'CPF' => [const DigitsMask('###.###.###-##')],
        'CEP' => [const DigitsMask('#####-###')],
        'Telefone/Celular' => [const PhoneMask()],
        'Peso' ||
        'Peso (kg)' => [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
        _ => null,
      };
  Widget _prefix() {
    if (widget.compact && !widget.figmaForm) {
      return Icon(widget.icon, color: VH.foreground, size: 18);
    }
    final asset = widget.figmaForm
        ? switch (widget.label) {
            'Tipo de Animal' => 'register-pet-species.png',
            'Nome do Pet' ||
            'Nome do Cachorro(a)' ||
            'Nome do Gato(a)' => 'frame-6.png',
            'Gênero/Sexo' => 'frame-7.png',
            'Peso' => 'frame-7-2.png',
            'Data de Nascimento' => 'frame-7-3.png',
            'Raça' => 'frame-7-4.png',
            'CEP' ||
            'Logradouro' ||
            'Endereço' ||
            'Complemento' ||
            'Nome' => 'address-prefix-home.png',
            'Numero' => 'address-prefix-number.png',
            _ => null,
          }
        : null;
    if (asset != null) {
      return Image.asset(
        'assets/imagens/figma/$asset',
        width: 58,
        height: 56,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      );
    }
    if (widget.figmaForm && widget.label == 'Cidade') {
      return SizedBox(
        width: 58,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/imagens/figma/address-prefix-city-circle.png',
              width: 58,
              height: 56,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            Image.asset(
              'assets/imagens/figma/address-prefix-city.png',
              width: 29,
              height: 25,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ],
        ),
      );
    }
    return Container(
      width: widget.figmaForm ? 58 : 44,
      height: widget.figmaForm ? 56 : 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: VH.background,
        border: Border.all(
          color: VH.secondary,
          width: widget.figmaForm ? 4 : 2,
        ),
      ),
      child: Icon(widget.icon, color: VH.foreground, size: 22),
    );
  }

  BorderRadius get fieldRadius => !isOpen
      ? VH.pillBorderRadius
      : _openAbove
      ? const BorderRadius.vertical(bottom: Radius.circular(24))
      : const BorderRadius.vertical(top: Radius.circular(24));

  double _fontSize(double? width) {
    final base = widget.figmaForm
        ? 15.0
        : widget.compact
        ? 13.0
        : 14.0;
    if (!widget.fitSingleLine || width == null || controller.text.isEmpty) {
      return base;
    }
    final style = Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(fontSize: base);
    final painter = TextPainter(
      text: TextSpan(text: controller.text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final available =
        width -
        (widget.figmaForm
            ? 58
            : widget.compact
            ? 32
            : 58) -
        20;
    return (base * available / painter.width).clamp(12.0, base);
  }

  Widget input(
    TextEditingController c,
    FocusNode focus, {
    double? width,
  }) => TextFormField(
    controller: c,
    focusNode: focus,
    textInputAction: widget.textInputAction,
    onFieldSubmitted: widget.onFieldSubmitted,
    autovalidateMode: widget.choices == null
        ? null
        : AutovalidateMode.onUserInteraction,
    textAlign: widget.textAlign,
    obscureText: widget.password,
    readOnly: widget.choices != null,
    onTap: widget.choices == null ? null : _toggleChoices,
    onChanged: (value) {
      widget.onChanged?.call(value);
      if (widget.fitSingleLine) setState(() {});
    },
    selectAllOnFocus: const ['Peso', 'Peso (kg)'].contains(widget.label),
    inputFormatters: formatters,
    keyboardType:
        widget.keyboardType ??
        (widget.label == 'Telefone/Celular'
            ? TextInputType.phone
            : widget.label == 'E-mail'
            ? TextInputType.emailAddress
            : formatters != null
            ? TextInputType.number
            : TextInputType.text),
    validator: widget.choices == null ? widget.validator : _validateChoice,
    style: widget.figmaForm
        ? VH.figmaFieldValueStyle.copyWith(fontSize: _fontSize(width))
        : TextStyle(fontSize: _fontSize(width), color: VH.foreground),
    decoration: InputDecoration(
      labelText: widget.compact && !widget.labelAbove
          ? switch (widget.label) {
              'Gênero/Sexo' => 'Sexo',
              'Tipo de Animal' => 'Espécie',
              'Data de Nascimento' || 'Nascimento (DD/MM/AAAA)' => 'Nascimento',
              _ => widget.label,
            }
          : null,
      labelStyle: const TextStyle(fontSize: 12, color: VH.foreground),
      isDense: widget.compact,
      hintText: widget.value,
      suffix: widget.suffixText == null
          ? null
          : Text(
              widget.suffixText!,
              style: widget.figmaForm
                  ? VH.figmaFieldValueStyle.copyWith(fontSize: _fontSize(width))
                  : null,
            ),
      filled: true,
      fillColor: Colors.transparent,
      prefixIconConstraints: BoxConstraints.tightFor(
        width: widget.figmaForm
            ? 58
            : widget.compact
            ? 32
            : 58,
        height: widget.figmaForm
            ? 56
            : widget.compact
            ? 48
            : 52,
      ),
      prefixIcon: Padding(
        padding: widget.compact || widget.figmaForm
            ? EdgeInsets.zero
            : const EdgeInsets.only(left: 3, right: 10),
        child: _prefix(),
      ),
      suffixIcon: widget.choices == null || !widget.showChoiceIndicator
          ? null
          : AnimatedRotation(
              turns: isOpen ? .5 : 0,
              duration: const Duration(milliseconds: 160),
              child: const Icon(Icons.expand_more, size: 18),
            ),
      contentPadding: EdgeInsets.only(
        left: widget.figmaForm
            ? widget.figmaContentPaddingLeft ?? 8
            : widget.compact
            ? 8
            : 14,
        right: widget.figmaForm
            ? widget.figmaContentPaddingRight ?? 8
            : widget.compact
            ? 8
            : 14,
        top: widget.figmaForm
            ? 16
            : widget.compact
            ? 14
            : 16,
        bottom: widget.figmaForm
            ? 16
            : widget.compact
            ? 14
            : 16,
      ),
      suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 48),
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: widget.figmaForm
            ? BorderSide.none
            : const BorderSide(color: VH.secondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: widget.figmaForm
            ? BorderSide.none
            : BorderSide(
                color: VH.secondary.withValues(alpha: isOpen ? .65 : .5),
              ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: VH.foreground, width: 2),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final choices = widget.choices ?? const <String>[];
    final hasChoices = choices.isNotEmpty;
    final activeRawChoice = hasChoices
        ? choices[_activeChoiceIndex % choices.length]
        : '';
    final activeChoice =
        widget.choiceDisplayLabel?.call(activeRawChoice) ?? activeRawChoice;
    final fieldInput = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleChoiceKeyEvent,
      child: widget.fitSingleLine
          ? LayoutBuilder(
              builder: (context, constraints) =>
                  input(controller, _focus, width: constraints.maxWidth),
            )
          : widget.suggestions.isEmpty
          ? input(controller, _focus)
          : RawAutocomplete<String>(
              textEditingController: controller,
              focusNode: _focus,
              optionsBuilder: (value) => value.text.isEmpty
                  ? const Iterable<String>.empty()
                  : widget.suggestions.where(
                      (s) => normalizedText(
                        s,
                      ).contains(normalizedText(value.text)),
                    ),
              onSelected: (value) => widget.onChanged?.call(value),
              fieldViewBuilder: (context, c, f, submit) => input(c, f),
              optionsViewBuilder: (context, choose, options) => Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 3,
                  color: VH.background,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 280,
                      maxHeight: 180,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        for (final option in options)
                          ListTile(
                            title: Text(option),
                            onTap: () => choose(option),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
    final accessibleField = hasChoices
        ? ValueListenableBuilder<String?>(
            valueListenable: _validationError,
            builder: (context, error, child) => Semantics(
              label: widget.label,
              button: true,
              value: error == null
                  ? controller.text.isEmpty
                        ? 'Nenhuma opção selecionada'
                        : widget.semanticsValue?.call(controller.text) ??
                              controller.text
                  : '${controller.text.isEmpty ? 'Nenhuma opção selecionada' : widget.semanticsValue?.call(controller.text) ?? controller.text}. Erro: $error',
              hint: error != null
                  ? 'Erro: $error. Selecione uma opção para corrigir. ${isOpen ? 'Opção destacada: $activeChoice.' : ''}'
                  : isOpen
                  ? 'Lista aberta. Opção destacada: $activeChoice. Use as setas para navegar, Enter ou Espaço para selecionar, ou Escape para fechar.'
                  : 'Pressione Enter ou Espaço para abrir a lista e use as setas para escolher.',
              onTap: () => _toggleChoices(),
              onTapHint: isOpen ? 'Fechar opções' : 'Abrir opções',
              focusable: true,
              focused: _focus.hasFocus,
              expanded: isOpen,
              liveRegion: isOpen || error != null,
              validationResult: error == null
                  ? ui.SemanticsValidationResult.none
                  : ui.SemanticsValidationResult.invalid,
              child: ExcludeSemantics(child: child!),
            ),
            child: fieldInput,
          )
        : fieldInput;
    final fieldContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.compact || widget.labelAbove)
          Padding(
            padding: EdgeInsets.only(
              left:
                  widget.labelHorizontalPadding ??
                  (widget.compact
                      ? 12
                      : widget.figmaForm
                      ? 14
                      : 58),
              bottom: widget.labelBottomPadding ?? 5,
            ),
            child: ExcludeSemantics(
              excluding: hasChoices,
              child: widget.labelFitSingleLine
                  ? SizedBox(
                      height: 20,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          softWrap: false,
                          style: VH.figmaFieldLabelStyle,
                        ),
                      ),
                    )
                  : Text(
                      widget.label,
                      style: widget.figmaForm
                          ? VH.figmaFieldLabelStyle
                          : const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: VH.foreground,
                            ),
                    ),
            ),
          ),
        TapRegion(
          groupId: this,
          onTapOutside: (_) => _closeChoices(),
          child: CompositedTransformTarget(
            link: _link,
            child: DecoratedBox(
              decoration: widget.figmaForm
                  ? inset_shadow.BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VH.secondary.withValues(alpha: .25),
                          VH.background,
                        ],
                      ),
                      borderRadius: fieldRadius,
                      boxShadow: const [
                        inset_shadow.BoxShadow(
                          color: VH.shadowSubtle,
                          offset: Offset(2, 2),
                          blurRadius: 2,
                          inset: true,
                        ),
                      ],
                    )
                  : widget.compact
                  ? inset_shadow.BoxDecoration(
                      color: VH.secondary.withValues(alpha: .25),
                      borderRadius: fieldRadius,
                      boxShadow: const [
                        inset_shadow.BoxShadow(
                          color: VH.shadowSubtle,
                          offset: Offset(2, 2),
                          blurRadius: 2,
                          inset: true,
                        ),
                      ],
                    )
                  : BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VH.secondary.withValues(alpha: .25),
                          VH.background,
                        ],
                      ),
                      borderRadius: fieldRadius,
                    ),
              child: accessibleField,
            ),
          ),
        ),
      ],
    );
    return widget.labelAbove && widget.suffixText == null
        ? MergeSemantics(child: fieldContent)
        : fieldContent;
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    this.label,
    this.child,
    this.color = VH.primary,
    this.textColor = VH.onSecondary,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.onTap,
  }) : assert(label != null || child != null);

  final String? label;
  final Widget? child;
  final Color color;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: VH.pillBorderRadius,
        boxShadow: const [
          BoxShadow(
            color: VH.shadowSubtle,
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: VH.pillBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: VH.pillBorderRadius,
          child: Padding(
            padding: padding,
            child:
                child ??
                Text(
                  label!,
                  style: VH.figmaButtonTextStyle.copyWith(color: textColor),
                ),
          ),
        ),
      ),
    );
  }
}

class VHHeader extends StatelessWidget {
  const VHHeader(
    this.title, {
    super.key,
    this.sub,
    this.showBack = true,
    this.bottom,
    this.settingsStyle = false,
  });

  final String title;
  final String? sub;
  final bool showBack;
  final Widget? bottom;
  final bool settingsStyle;

  @override
  Widget build(BuildContext context) {
    final adaptTitle =
        sub == null &&
        bottom == null &&
        MediaQuery.textScalerOf(context).scale(30) > 30;
    final titleInsets = settingsStyle ? 24.0 : 50.0;
    final titleTop = settingsStyle || (sub == null && bottom == null)
        ? 46.0
        : 18.0;
    const titleStyle = TextStyle(
      color: VH.onSecondary,
      fontSize: 30,
      fontWeight: FontWeight.bold,
      fontFamily: VH.headingFontFamily,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      height: adaptTitle ? null : VH.headerHeight,
      constraints: adaptTitle
          ? const BoxConstraints(minHeight: VH.headerHeight)
          : null,
      decoration: BoxDecoration(
        color: VH.secondary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          if (adaptTitle)
            Padding(
              padding: EdgeInsets.fromLTRB(
                titleInsets,
                titleTop,
                titleInsets,
                16,
              ),
              child: Center(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                ),
              ),
            )
          else
            Positioned(
              top: titleTop,
              left: titleInsets,
              right: titleInsets,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
              ),
            ),
          if (showBack && Navigator.of(context).canPop())
            Positioned(
              top: 8,
              left: 10,
              child: IconButton(
                tooltip: 'Voltar',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: VH.onSecondary),
              ),
            ),
          if (!settingsStyle && kDebugMode)
            Positioned(
              top: 8,
              right: 10,
              child: IconButton(
                tooltip: 'Telas de teste',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TestePage()),
                  );
                },
                icon: const Icon(
                  Icons.dashboard_outlined,
                  color: VH.onSecondary,
                ),
              ),
            ),
          if (sub != null)
            Positioned(
              top: 54,
              left: 0,
              right: 0,
              child: Text(
                sub!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: VH.onSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (bottom != null)
            Positioned(
              top: 72,
              left: 94,
              right: 94,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  color: VH.background.withValues(alpha: 0.16),
                  borderRadius: VH.headerInsetBorderRadius,
                  boxShadow: const [
                    BoxShadow(
                      color: VH.shadowSubtle,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: bottom,
              ),
            ),
        ],
      ),
    );
  }
}

class VHPage extends StatelessWidget {
  const VHPage({
    super.key,
    required this.tab,
    required this.children,
    this.footer,
    this.showPetsTab = true,
    this.showBottomNav = true,
  });

  final String tab;
  final List<Widget> children;
  final Widget? footer;
  final bool showPetsTab;
  final bool showBottomNav;

  static const _tabRoutes = ['/pets', '/perfil', '/chat', '/agenda', '/config'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: VH.desktopShellMaxWidth),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
                ?footer,
                if (showBottomNav)
                  VetBottomNav(
                    selectedIndex: _tabRoutes.indexOf(tab).clamp(0, 4),
                    showPetsTab: showPetsTab,
                    onSelected: (index) {
                      final route = _tabRoutes[index];
                      if (route != tab) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          route,
                          (route) => route.isFirst,
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
