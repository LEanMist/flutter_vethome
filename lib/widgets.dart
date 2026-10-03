import 'package:flutter/material.dart';
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

class VHField extends StatelessWidget {
  const VHField(
    this.label,
    this.icon, {
    super.key,
    this.value,
    this.password = false,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final String? value;
  final bool password;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 3),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: VH.bodyFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: VH.foreground,
            ),
          ),
        ),
        Container(
          height: VH.fieldHeight,
          decoration: inset_shadow.BoxDecoration(
            color: VH.background.withValues(alpha: 0.72),
            borderRadius: VH.pillBorderRadius,
            boxShadow: const [
              inset_shadow.BoxShadow(
                color: VH.shadowSoft,
                offset: Offset(2, 3),
                blurRadius: 5,
                inset: true,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            initialValue: controller == null ? value : null,
            obscureText: password,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: controller == null ? null : value,
              hintStyle: const TextStyle(
                fontFamily: VH.bodyFontFamily,
                fontSize: 15,
                color: VH.mutedText,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VH.background,
                    border: Border.all(color: VH.secondary, width: 3),
                  ),
                  child: Icon(icon, color: VH.secondary, size: 23),
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: VH.pillBorderRadius,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: VH.pillBorderRadius,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: VH.pillBorderRadius,
                borderSide: const BorderSide(color: VH.primary, width: 1),
              ),
            ),
            style: const TextStyle(
              fontFamily: VH.bodyFontFamily,
              fontSize: 15,
              color: VH.foreground,
            ),
          ),
        ),
      ],
    );
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
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: VH.onSecondary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: VH.headingFontFamily,
              ),
            ),
          ),
          if (showBack && Navigator.of(context).canPop())
            Positioned(
              top: 8,
              left: 10,
              child: IconButton(
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
      body: SafeArea(
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
