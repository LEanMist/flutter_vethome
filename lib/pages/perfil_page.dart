// lib/pages/perfil_page.dart
// Requer: flutter pub add image_picker
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/utils/formatters.dart';
import '../core/utils/form_fields.dart';
import '../core/utils/photo_picker.dart';
import '../widgets.dart';
import '../widgets/client_gender_fields.dart';
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
  String _nome = VetRepository.clientName;
  DateTime _nascimento = VetRepository.clientBirthDate;
  File? _foto;
  Uint8List? _fotoBytes;
  bool _editingGender = false;
  final _gender = TextEditingController(text: VetRepository.clientGender);
  final _genderCustom = TextEditingController(
    text: VetRepository.clientGenderCustom,
  );
  @override
  void dispose() {
    _gender.dispose();
    _genderCustom.dispose();
    super.dispose();
  }

  Future<void> _saveGender() async {
    VetRepository.registerClient({
      'client.Gênero/Sexo': _gender.text,
      'client.Gênero personalizado': _genderCustom.text,
    });
    final saved = await VetRepository.flush();
    if (!mounted) return;
    setState(() => _editingGender = false);
    if (!saved) {
      vetSoon(
        context,
        'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final path = VetRepository.clientPhotoPath;
    if (kIsWeb) {
      _fotoBytes = VetRepository.clientPhotoBytes;
      if (_fotoBytes == null && path != null) _carregarFotoWeb(path);
    } else if (path != null) {
      _foto = File(path);
    }
  }

  Future<void> _carregarFotoWeb(String path) async {
    try {
      final bytes = await XFile(path).readAsBytes();
      if (!mounted) return;
      setState(() {
        _fotoBytes = bytes;
        VetRepository.clientPhotoBytes = bytes;
      });
    } catch (_) {
      // Caminhos blob expirados mantêm o avatar padrão, sem usar File no Web.
    }
  }

  String get _nascimentoTexto => fmtData(_nascimento).replaceAll('/', ' / ');

  Future<void> _mudarFoto() async {
    try {
      final picked = await pickLocalPhoto(context);
      if (picked != null && mounted) {
        final bytes = kIsWeb ? await picked.readAsBytes() : null;
        if (!mounted) return;
        setState(() {
          if (kIsWeb) {
            _fotoBytes = bytes;
            VetRepository.clientPhotoBytes = bytes;
          } else {
            _foto = File(picked.path);
          }
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
    final DateTime? data = await showDialog<DateTime>(
      context: context,
      builder: (_) => _BirthDialog(initial: _nascimento),
    );
    if (data != null && mounted) {
      setState(() {
        _nascimento = data;
        VetRepository.updateClient(birthDate: data);
      });
    }
  }

  Future<void> _mudarEndereco() async {
    await Navigator.pushNamed(context, '/enderecos');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
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
        ),
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
                    child: _buildProfileImage(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (kIsWeb && _fotoBytes != null) {
      return Image.memory(_fotoBytes!, fit: BoxFit.cover, cacheWidth: 400);
    }
    if (!kIsWeb && _foto != null) {
      return Image.file(_foto!, fit: BoxFit.cover, cacheWidth: 400);
    }
    return Image.asset(
      'assets/imagens/figma/frame-53-3.png',
      fit: BoxFit.contain,
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
      MapEntry(
        'Mudar gênero',
        () => setState(() => _editingGender = !_editingGender),
      ),
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
          if (_editingGender) ...[
            const SizedBox(height: 10),
            ClientGenderFields(gender: _gender, custom: _genderCustom),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _saveGender,
                child: const Text('Salvar gênero'),
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
      content: VHField(
        'Novo nome',
        Icons.person_outline,
        controller: _controller,
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

class _BirthDialog extends StatefulWidget {
  const _BirthDialog({required this.initial});
  final DateTime initial;
  @override
  State<_BirthDialog> createState() => _BirthDialogState();
}

class _BirthDialogState extends State<_BirthDialog> {
  final _form = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: fmtData(widget.initial));
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: VetColors.pink,
    title: const Text('Mudar data de nascimento'),
    content: Form(
      key: _form,
      child: VHField(
        'Data de nascimento',
        Icons.cake_outlined,
        controller: _controller,
        keyboardType: TextInputType.number,
        validator: (v) =>
            parseBirthDate(v ?? '') == null ? 'Informe uma data válida' : null,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, parseBirthDate(_controller.text));
          }
        },
        child: const Text('Salvar'),
      ),
    ],
  );
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
