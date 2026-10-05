import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/utils/form_fields.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import 'data/vet_repository.dart';
import 'models/pet_model.dart';
import 'pages/teste_page.dart';
import 'theme.dart';
import 'widgets/vet_bottom_nav.dart';

BoxDecoration insetBox({required Color color, double radius = VH.radiusCard}) {
  return inset_shadow.BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      inset_shadow.BoxShadow(
        color: VH.shadowSubtle,
        offset: Offset(2, 3),
        blurRadius: 7,
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
    this.validator,
    this.keyboardType,
    this.choices,
    this.suggestions = const [],
    this.onChanged,
    this.inputFormatters,
    this.figmaForm = false,
    this.compact = false,
    this.fitSingleLine = false,
  });
  final bool figmaForm;
  final bool compact;
  final bool fitSingleLine;
  final String label;
  final IconData icon;
  final String? value;
  final bool password;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<String>? choices;
  final List<String> suggestions;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  @override
  State<VHField> createState() => _VHFieldState();
}

class _VHFieldState extends State<VHField> {
  late final _owned = TextEditingController(text: widget.value ?? '');
  final _focus = FocusNode();
  final _link = LayerLink();
  OverlayEntry? _options;
  static _VHFieldState? _opened;
  bool get isOpen => _options != null;
  void _closeChoices({bool rebuild = true}) {
    _options?.remove();
    _options?.dispose();
    _options = null;
    if (_opened == this) _opened = null;
    if (mounted && rebuild) setState(() {});
  }

  void _toggleChoices() {
    if (isOpen) {
      _closeChoices();
      return;
    }
    _opened?._closeChoices();
    _opened = this;
    _focus.unfocus();
    final box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
    final availableHeight = (MediaQuery.sizeOf(context).height - bottom - 8)
        .clamp(0.0, 192.0);
    _options = OverlayEntry(
      builder: (ctx) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
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
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  side: BorderSide(color: VH.secondary.withValues(alpha: .65)),
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: availableHeight),
                  child: ListView.separated(
                    shrinkWrap: true,
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
                        title: Text(value),
                        selected: controller.text == value,
                        onTap: () {
                          controller.text = value;
                          _closeChoices();
                          widget.onChanged?.call(value);
                        },
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

  TextEditingController get controller => widget.controller ?? _owned;
  @override
  void dispose() {
    _closeChoices(rebuild: false);
    _owned.dispose();
    _focus.dispose();
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
    if (widget.compact) {
      return Icon(widget.icon, color: VH.foreground, size: 18);
    }
    final asset = widget.figmaForm
        ? switch (widget.label) {
            'Gênero/Sexo' => 'frame-7.png',
            'Peso' => 'frame-7-2.png',
            'Data de Nascimento' => 'frame-7-3.png',
            'Raça' => 'frame-7-4.png',
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

  BorderRadius get fieldRadius => isOpen
      ? const BorderRadius.vertical(top: Radius.circular(24))
      : VH.pillBorderRadius;

  double _fontSize(double? width) {
    final base = widget.compact
        ? 13.0
        : widget.figmaForm
        ? 15.0
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
    final available = width - (widget.compact ? 32 : 58) - 20;
    return (base * available / painter.width).clamp(12.0, base);
  }

  Widget input(
    TextEditingController c,
    FocusNode focus, {
    double? width,
  }) => TextFormField(
    controller: c,
    focusNode: focus,
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
    validator: widget.validator,
    style: TextStyle(
      fontSize: _fontSize(width),
      fontFamily: widget.figmaForm ? VH.headingFontFamily : null,
      fontWeight: widget.figmaForm ? FontWeight.w500 : null,
      color: VH.foreground,
    ),
    decoration: InputDecoration(
      labelText: widget.compact
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
      filled: true,
      fillColor: Colors.transparent,
      prefixIconConstraints: BoxConstraints.tightFor(
        width: widget.compact ? 32 : 58,
        height: widget.compact
            ? 48
            : widget.figmaForm
            ? 56
            : 52,
      ),
      prefixIcon: Padding(
        padding: widget.compact || widget.figmaForm
            ? EdgeInsets.zero
            : const EdgeInsets.only(left: 3, right: 10),
        child: _prefix(),
      ),
      suffixIcon: widget.choices == null
          ? null
          : AnimatedRotation(
              turns: isOpen ? .5 : 0,
              duration: const Duration(milliseconds: 160),
              child: const Icon(Icons.expand_more, size: 18),
            ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: widget.compact
            ? 8
            : widget.figmaForm
            ? 8
            : 14,
        vertical: widget.compact ? 14 : 16,
      ),
      suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 48),
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: VH.secondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!widget.compact)
        Padding(
          padding: EdgeInsets.only(left: widget.figmaForm ? 14 : 58, bottom: 5),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: widget.figmaForm ? VH.bodyFontFamily : null,
              fontWeight: widget.figmaForm ? FontWeight.w500 : FontWeight.w600,
              fontSize: widget.figmaForm ? 14 : 13,
              color: VH.foreground,
            ),
          ),
        ),
      TapRegion(
        groupId: this,
        onTapOutside: (_) => _closeChoices(),
        child: CompositedTransformTarget(
          link: _link,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VH.secondary.withValues(alpha: widget.figmaForm ? .25 : .45),
                  VH.background,
                ],
              ),
              borderRadius: fieldRadius,
            ),
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
          ),
        ),
      ),
    ],
  );
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
    return Material(
      color: color,
      borderRadius: VH.pillBorderRadius,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: VH.pillBorderRadius,
        child: Padding(
          padding: padding,
          child:
              child ??
              Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
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
  });

  final String title;
  final String? sub;
  final bool showBack;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      height: bottom != null ? VH.headerHeight : (sub != null ? 80 : 64),
      decoration: const BoxDecoration(
        color: VH.secondary,
        borderRadius: VH.headerBorderRadius,
        boxShadow: VH.raise,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 18,
            left: 50,
            right: 50,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: VH.onSecondary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: VH.headingFontFamily,
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
              icon: const Icon(Icons.dashboard_outlined, color: VH.onSecondary),
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
  });

  final String tab;
  final List<Widget> children;
  final Widget? footer;

  static const _tabRoutes = ['/pets', '/perfil', '/chat', '/agenda', '/config'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
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
                VetBottomNav(
                  selectedIndex: _tabRoutes.indexOf(tab).clamp(0, 4),
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

class Pet {
  const Pet({
    required this.name,
    required this.sex,
    required this.weight,
    required this.birth,
    required this.breed,
    this.isDog = true,
  });

  final String name;
  final String sex;
  final String weight;
  final String birth;
  final String breed;
  final bool isDog;
}

List<Pet> get pets => VetRepository.pets.map(_toPet).toList();

Pet _toPet(PetModel model) {
  final birth = model.birthDate;
  final weight = model.weightKg;
  return Pet(
    name: model.name,
    sex: model.sex ?? 'Não informado',
    weight: weight == null ? 'Não informado' : '${weight.toString()} kg',
    birth: birth == null
        ? 'Não informado'
        : '${birth.day.toString().padLeft(2, '0')} / '
              '${birth.month.toString().padLeft(2, '0')} / ${birth.year}',
    breed: model.breed ?? 'Sem raça definida',
    isDog: !(model.species?.toLowerCase().contains('gato') ?? false),
  );
}

class PetRow extends StatelessWidget {
  const PetRow(this.pet, {super.key, required this.onTap});

  final Pet pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: VH.card,
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: VH.muted,
          child: Icon(Icons.pets, color: VH.foreground),
        ),
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${pet.isDog ? 'Cão' : 'Gato'} · ${pet.breed}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class VHBadge extends StatelessWidget {
  const VHBadge(this.imagePath, this.name, {super.key});

  final String imagePath;
  final String name;

  @override
  Widget build(BuildContext context) {
    final asset = imagePath.contains('pet-badge')
        ? 'assets/imagens/pets/img_cachorroegato_png.png'
        : imagePath.contains('user-badge')
        ? 'assets/imagens/client_logo.png'
        : 'assets/imagens/VetHome_logo_1.jpg';

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: VH.card,
            child: ClipOval(
              child: Image.asset(
                asset,
                width: 82,
                height: 82,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.pets, size: 48, color: VH.foreground),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class VHMenu extends StatelessWidget {
  const VHMenu(this.items, {super.key, this.onTap});

  final List<String> items;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Container(
        decoration: BoxDecoration(
          color: VH.card,
          borderRadius: VH.cardBorderRadius,
          boxShadow: VH.raise,
        ),
        child: ClipRRect(
          borderRadius: VH.cardBorderRadius,
          child: Material(
            color: VH.card,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, indent: 18, endIndent: 18),
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      items[i],
                      style: const TextStyle(
                        fontFamily: VH.bodyFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: VH.foreground,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: VH.foreground,
                      size: 20,
                    ),
                    onTap: () => onTap?.call(i),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SidePill extends StatelessWidget {
  const SidePill(this.icon, this.label, {super.key, this.onTap, this.extra});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final asset = switch (label) {
      'Exames' => 'assets/imagens/figma/coisademedico-1.png',
      'Atestados' => 'assets/imagens/figma/atestado-1.png',
      _ => null,
    };
    return SizedBox(
      width: 264,
      height: 59,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: VH.sidePillBorderRadius,
          child: Ink(
            decoration: BoxDecoration(
              gradient: VH.softGradient,
              borderRadius: VH.sidePillBorderRadius,
              boxShadow: const [
                BoxShadow(
                  color: VH.shadowSoft,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                if (asset != null)
                  Image.asset(asset, width: 30, height: 30)
                else
                  Icon(icon, color: VH.onSecondary, size: 30),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: VH.bodyFontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: VH.onSecondary,
                    ),
                  ),
                ),
                extra ??
                    const Icon(
                      Icons.chevron_right,
                      color: VH.onSecondary,
                      size: 21,
                    ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
