// lib/pages/perfil_page.dart
// Requer: flutter pub add image_picker

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_bottom_nav.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // TODO: carregar/salvar dados reais (API, SharedPreferences, etc.)
  String _nome = 'Liminha';
  DateTime _nascimento = DateTime(2007, 2, 5);
  File? _foto;

  final ImagePicker _picker = ImagePicker();

  String get _nascimentoTexto {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(_nascimento.day)} / ${two(_nascimento.month)} / ${_nascimento.year}';
  }

  // ── Ações ─────────────────────────────────────────────────────────────────

  Future<void> _mudarFoto() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: VetColors.pink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera, color: VetColors.brown),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: VetColors.brown),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final XFile? picked =
          await _picker.pickImage(source: source, maxWidth: 800);
      if (picked != null && mounted) {
        setState(() => _foto = File(picked.path));
      }
    } catch (_) {
      _aviso('Não foi possível abrir a imagem.');
    }
  }

  Future<void> _mudarNome() async {
    final controller = TextEditingController(text: _nome);
    final String? novo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VetColors.pink,
        title: const Text('Mudar nome de perfil'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(hintText: 'Novo nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (novo != null && novo.isNotEmpty && mounted) {
      setState(() => _nome = novo);
    }
  }

  Future<void> _mudarNascimento() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _nascimento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (data != null && mounted) setState(() => _nascimento = data);
  }

  void _aviso(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // O Stack tem a altura total (header + avatar), então o
                  // avatar fica DENTRO da área e recebe toques normalmente.
                  SizedBox(
                    width: double.infinity,
                    height: top + 52 * s + 230 * s,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: _buildHeader(s, top),
                        ),
                        Positioned(
                          top: top + 52 * s,
                          child: _buildAvatarTab(s),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18 * s),
                  _buildBirthday(s),
                  SizedBox(height: 28 * s),
                  _buildOptions(s),
                ],
              ),
            ),
          ),
          VetBottomNav(
            selectedIndex: 1,
            onSelected: (i) {
              if (i == 0) {
                Navigator.of(context).pop();
              } else if (i != 1) {
                _aviso('Em breve');
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double s, double top) {
    return Container(
      width: double.infinity,
      height: top + 100 * s,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: top + 16 * s),
      decoration: BoxDecoration(
        color: VetColors.roseDark.withOpacity(0.85),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30 * s)),
      ),
      child: Text(
        'Perfil',
        style: TextStyle(
          fontSize: 26 * s,
          fontFamily: PetsTheme.fontComfortaa,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Aba com nome + avatar ─────────────────────────────────────────────────

  Widget _buildAvatarTab(double s) {
    return Container(
      width: 200 * s,
      height: 230 * s,
      decoration: BoxDecoration(
        color: VetColors.pink.withOpacity(0.9),
        border: Border.all(color: VetColors.roseDark, width: 3 * s),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24 * s),
          bottom: Radius.circular(100 * s),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 14 * s),
          GestureDetector(
            onTap: _mudarNome,
            child: Text(
              _nome,
              style: TextStyle(
                fontSize: 20 * s,
                fontFamily: PetsTheme.fontComfortaa,
                fontWeight: FontWeight.w600,
                color: VetColors.brown,
              ),
            ),
          ),
          SizedBox(height: 14 * s),
          GestureDetector(
            onTap: _mudarFoto,
            child: SizedBox(
              width: 140 * s,
              height: 140 * s,
              child: CustomPaint(
                painter: _DashedCirclePainter(
                  color: VetColors.roseDark,
                  strokeWidth: 2 * s,
                ),
                child: Center(
                  child: Container(
                    width: 122 * s,
                    height: 122 * s,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: VetColors.pink,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: VetColors.shadowDark,
                          offset: Offset(3, 3),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: VetColors.shadowLight,
                          offset: Offset(-3, -3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: _foto != null
                        ? Image.file(_foto!, fit: BoxFit.cover)
                        : Icon(
                            Icons.person,
                            size: 70 * s,
                            color: VetColors.roseDark,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Data de nascimento ────────────────────────────────────────────────────

  Widget _buildBirthday(double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cake_outlined, size: 16 * s, color: VetColors.brown),
        SizedBox(width: 6 * s),
        Text(
          _nascimentoTexto,
          style: TextStyle(
            fontSize: 13 * s,
            fontFamily: PetsTheme.fontComfortaa,
            fontWeight: FontWeight.w600,
            color: VetColors.brown,
          ),
        ),
      ],
    );
  }

  // ── Lista de opções ───────────────────────────────────────────────────────

  Widget _buildOptions(double s) {
    final items = <MapEntry<String, VoidCallback>>[
      MapEntry('Mudar Foto de Perfil', _mudarFoto),
      MapEntry('Mudar Nome de Perfil', _mudarNome),
      MapEntry('Mudar Data de Nascimento', _mudarNascimento),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22 * s),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: VetColors.rose),
            InkWell(
              onTap: items[i].value,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14 * s),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        items[i].key,
                        style: TextStyle(
                          fontSize: 14 * s,
                          fontFamily: PetsTheme.fontComfortaa,
                          fontWeight: FontWeight.w600,
                          color: VetColors.brown,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 26 * s, color: VetColors.brown),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Círculo tracejado ao redor do avatar.
class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double r = size.width / 2 - strokeWidth;
    final Rect rect =
        Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    const int dashes = 36;
    const double sweep = 2 * math.pi / dashes;
    for (int i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
