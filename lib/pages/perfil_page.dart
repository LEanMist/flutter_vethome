// lib/pages/perfil_page.dart
// Requer: flutter pub add image_picker
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/utils/formatters.dart';
import '../core/utils/vet_nav.dart';
import '../data/vet_repository.dart';
import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_bottom_nav.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // TODO: carregar/salvar dados reais (API, SharedPreferences, etc.)
  String _nome = VetRepository.clientName;
  DateTime _nascimento = VetRepository.clientBirthDate;
  File? _foto;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final path = VetRepository.clientPhotoPath;
    if (path != null) _foto = File(path);
  }

  String get _nascimentoTexto => fmtData(_nascimento).replaceAll('/', ' / ');

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
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
      );
      if (picked != null && mounted) {
        setState(() {
          _foto = File(picked.path);
          VetRepository.clientPhotoPath = picked.path;
        });
      }
    } catch (_) {
      if (mounted) vetSoon(context, 'Não foi possível abrir a imagem.');
    }
  }

  Future<void> _mudarNome() async {
    final String? novo = await showDialog<String>(
      context: context,
      builder: (_) => _NomeDialog(inicial: _nome),
    );
    if (novo != null && novo.isNotEmpty && mounted) {
      setState(() {
        _nome = novo;
        VetRepository.updateClient(name: novo);
      });
    }
  }

  Future<void> _mudarNascimento() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _nascimento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (data != null && mounted) {
      setState(() {
        _nascimento = data;
        VetRepository.updateClient(birthDate: data);
      });
    }
  }

  Future<void> _mudarEndereco() async {
    final controller = TextEditingController(text: VetRepository.clientAddress);
    try {
      final String? value = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: VetColors.pink,
          title: const Text('Alterar endereço'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Endereço completo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        ),
      );
      if (value != null && value.isNotEmpty && mounted) {
        VetRepository.updateClient(address: value);
        vetSoon(context, 'Endereço atualizado');
      }
    } finally {
      controller.dispose();
    }
  }

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
                  SizedBox(
                    width: double.infinity,
                    height: top + 72 * s + 280 * s,
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
                          top: top + 72 * s,
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
          SafeArea(
            top: false,
            child: VetBottomNav(
              selectedIndex: 1,
              onSelected: (i) =>
                  vetNavigate(context, i, selected: 1, isTabRoot: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double s, double top) {
    return Container(
      width: double.infinity,
      height: top + 131 * s,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: top + 16 * s),
      decoration: BoxDecoration(
        color: VetColors.roseDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30 * s)),
      ),
      child: Column(
        children: [
          Text(
            'Perfil',
            style: TextStyle(
              fontSize: 26 * s,
              fontFamily: PetsTheme.fontComfortaa,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 18 * s),
          Container(
            width: 220 * s,
            height: 59 * s,
            decoration: BoxDecoration(
              color: VetColors.pink.withValues(alpha: 0.16),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30 * s),
                bottom: Radius.circular(10 * s),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarTab(double s) {
    return Container(
      width: 220 * s,
      height: 280 * s,
      decoration: BoxDecoration(
        color: VetColors.pink.withValues(alpha: 0.9),
        border: Border.all(color: VetColors.rose, width: 3 * s),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30 * s),
          bottom: Radius.circular(200 * s),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 15 * s),
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
          SizedBox(height: 12 * s),
          GestureDetector(
            onTap: _mudarFoto,
            child: SizedBox(
              width: 178 * s,
              height: 178 * s,
              child: CustomPaint(
                painter: _DashedCirclePainter(
                  color: VetColors.roseDark,
                  strokeWidth: 2 * s,
                ),
                child: Center(
                  child: Container(
                    width: 156 * s,
                    height: 156 * s,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: VetColors.pink,
                      shape: BoxShape.circle,
                    ),
                    child: _foto != null
                        ? Image.file(_foto!, fit: BoxFit.cover, cacheWidth: 400)
                        : Image.asset(
                            'assets/imagens/figma/frame-53-3.png',
                            fit: BoxFit.contain,
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

  Widget _buildOptions(double s) {
    final items = <MapEntry<String, VoidCallback>>[
      MapEntry('Mudar Foto de Perfil', _mudarFoto),
      MapEntry('Mudar Nome de Perfil', _mudarNome),
      MapEntry('Mudar Data de Nascimento', _mudarNascimento),
      MapEntry('Alterar endereço', _mudarEndereco),
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
                    Icon(
                      Icons.chevron_right,
                      size: 26 * s,
                      color: VetColors.brown,
                    ),
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

/// Diálogo próprio: o controller nasce e morre junto com o widget,
/// então `dispose()` é seguro (sem crash na animação de fechar).
class _NomeDialog extends StatefulWidget {
  const _NomeDialog({required this.inicial});
  final String inicial;

  @override
  State<_NomeDialog> createState() => _NomeDialogState();
}

class _NomeDialogState extends State<_NomeDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.inicial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: VetColors.pink,
      title: const Text('Mudar nome de perfil'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        decoration: const InputDecoration(hintText: 'Novo nome'),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Salvar'),
        ),
      ],
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
    final Rect rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: r,
    );
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
