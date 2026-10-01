import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

import 'theme.dart';
import 'widgets/vet_bottom_nav.dart';

BoxDecoration insetBox({required Color color, double radius = 20}) {
  return inset_shadow.BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      inset_shadow.BoxShadow(
        color: Color(0x22683F40),
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
  });

  final String label;
  final IconData icon;
  final String? value;
  final bool password;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      obscureText: password,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: VH.foreground),
        filled: true,
        fillColor: VH.background.withValues(alpha: 0.55),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    this.label,
    this.child,
    this.color = VH.primary,
    this.textColor = Colors.white,
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
      borderRadius: BorderRadius.circular(999),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: padding,
          child: child ??
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
  const VHHeader(this.title, {super.key, this.sub, this.face});

  final String title;
  final String? sub;
  final String? face;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: const BoxDecoration(
        color: VH.secondary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: VH.raise,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                if (Navigator.of(context).canPop())
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: VH.onSecondary),
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: VH.onSecondary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: face == null
                      ? null
                      : Text(
                          face!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: VH.onSecondary,
                          ),
                        ),
                ),
              ],
            ),
            if (sub != null) ...[
              const SizedBox(height: 4),
              Text(
                sub!,
                style: const TextStyle(
                  color: VH.onSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VHPage extends StatelessWidget {
  const VHPage({super.key, required this.tab, required this.children});

  final String tab;
  final List<Widget> children;

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

final List<Pet> pets = [
  const Pet(
    name: 'Fernando',
    sex: 'Macho',
    weight: '24 kg',
    birth: '23 / 03 / 2012',
    breed: 'Lulu-da-Pomerânia',
  ),
  const Pet(
    name: 'Mimi',
    sex: 'Fêmea',
    weight: '4 kg',
    birth: '11 / 06 / 2020',
    breed: 'Sem raça definida',
    isDog: false,
  ),
];

int petAtual = 0;

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
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        : 'assets/imagens/pets/vethome_logo.png';

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
                errorBuilder: (_, _, _) => const Icon(
                  Icons.pets,
                  size: 48,
                  color: VH.foreground,
                ),
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
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Card(
              color: VH.card,
              child: ListTile(
                title: Text(items[i]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onTap?.call(i),
              ),
            ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: VH.card,
        borderRadius: BorderRadius.circular(28),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: VH.foreground),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: extra ?? const Icon(Icons.chevron_right),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
    );
  }
}