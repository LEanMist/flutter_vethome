// lib/pages/perfil_page.dart
// Requer: flutter pub add image_picker
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../core/utils/formatters.dart';
import '../core/utils/form_fields.dart';
import '../core/utils/pet_photo.dart';
import '../widgets.dart';
import '../core/utils/vet_nav.dart';
import '../data/vet_repository.dart';
import '../theme/vet_colors.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet/vet_bottom_nav.dart';

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

  @override
  void initState() {
    super.initState();
    final savedPhoto = VetRepository.clientPhotoBase64;
    if (savedPhoto != null) {
      try {
        _fotoBytes = base64Decode(savedPhoto);
      } catch (_) {
        // Dados legados inválidos seguem para o avatar padrão/fallback abaixo.
      }
    }
    final path = VetRepository.clientPhotoPath;
    if (_fotoBytes != null) {
      // A miniatura persistida independe do caminho temporário do picker.
    } else if (kIsWeb) {
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
      final photo = await PetPhoto.choose(context);
      if (photo == null || !mounted) return;
      final bytes = base64Decode(photo);
      final persisted = await VetRepository.updateClientPhoto(photo);
      if (!mounted) return;
      setState(() {
        _fotoBytes = bytes;
        _foto = null;
        VetRepository.clientPhotoBytes = bytes;
        VetRepository.clientPhotoPath = null;
      });
      if (!persisted) {
        vetSoon(
          context,
          'Foto atualizada nesta sessão. Não foi possível salvar localmente.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        vetSoon(context, error.message.toString());
      }
    } on PersistenceClearingException {
      if (mounted) {
        vetSoon(
          context,
          'A foto não foi alterada porque os dados locais estão sendo limpos.',
        );
      }
    } on PersistenceBlockedException {
      if (mounted) {
        vetSoon(context, 'Não foi possível salvar a foto localmente.');
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
      await _saveProfileChange(
        () => _nome = novo,
        persist: () => VetRepository.updateClient(name: novo),
      );
    }
  }

  Future<void> _mudarNascimento() async {
    final DateTime? data = await showDialog<DateTime>(
      context: context,
      builder: (_) => _BirthDialog(initial: _nascimento),
    );
    if (data != null && mounted) {
      await _saveProfileChange(
        () => _nascimento = data,
        persist: () => VetRepository.updateClient(birthDate: data),
      );
    }
  }

  Future<void> _saveProfileChange(
    VoidCallback update, {
    required VoidCallback persist,
  }) async {
    try {
      persist();
    } on PersistenceClearingException {
      if (mounted) {
        vetSoon(
          context,
          'A alteração não foi feita porque os dados locais estão sendo limpos.',
        );
      }
      return;
    } on PersistenceBlockedException {
      if (mounted) {
        vetSoon(
          context,
          'O armazenamento local está protegido. Nenhuma alteração foi feita.',
        );
      }
      return;
    }
    if (!mounted) return;
    setState(update);
    final saved = await VetRepository.flush();
    if (!saved && mounted) {
      vetSoon(
        context,
        'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = PetsTheme.scaleOf(context);
    final double top = MediaQuery.paddingOf(context).top;
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: VetColors.pink,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Expanded(
                child: desktop
                    ? _buildDesktopProfile(s, top)
                    // O frame móvel do Figma começa em y=0; a barra de
                    // status sobrepõe o cabeçalho rosa, sem deslocá-lo.
                    : SingleChildScrollView(child: _buildMobileProfile(s, 0)),
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

  Widget _buildMobileProfile(double s, double top) => Column(
    children: [
      SizedBox(
        width: double.infinity,
        height: top + 72 * s + _mobileAvatarHeight(s),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(top: 0, left: 0, right: 0, child: _buildHeader(s, top)),
            Positioned(
              top: top + 72 * s,
              child: _buildAvatarTab(s, mobileFigma: true),
            ),
          ],
        ),
      ),
      SizedBox(height: 13 * s),
      _buildBirthday(s),
      SizedBox(height: 62 * s),
      _buildOptions(s),
    ],
  );

  Widget _buildDesktopProfile(double s, double top) => Column(
    key: const ValueKey('profile-desktop-layout'),
    children: [
      _buildHeader(s, top),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildAvatarTab(s),
                    const SizedBox(height: 18),
                    _buildBirthday(s),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(child: _buildOptions(s)),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildHeader(double s, double top) {
    return Container(
      width: double.infinity,
      height: top + 131 * s,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: top + 27 * s),
      decoration: BoxDecoration(
        color: VetColors.rose,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30 * s)),
      ),
      child: Column(
        children: [
          Text(
            'Perfil',
            style: TextStyle(
              fontSize: 30 * s,
              fontFamily: PetsTheme.fontComfortaa,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarTab(double s, {bool mobileFigma = false}) {
    return Container(
      width: 220 * s,
      height: mobileFigma ? _mobileAvatarHeight(s) : null,
      constraints: mobileFigma ? null : BoxConstraints(minHeight: 280 * s),
      decoration: BoxDecoration(
        color: VetColors.pinkOverlay50,
        border: Border.all(color: VetColors.rose, width: 5 * s),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30 * s),
          bottom: Radius.circular(200 * s),
        ),
      ),
      child: mobileFigma
          ? _buildMobileFigmaAvatar(s)
          : _buildLegacyAvatarContent(s),
    );
  }

  Widget _buildMobileFigmaAvatar(double s) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        left: 22 * s,
        top: _mobileAvatarPhotoTop(s),
        child: _buildPhotoAction(s),
      ),
      Positioned(
        left: 9.9486 * s,
        top: 72.3448 * s + _mobileAvatarPhotoTop(s) - 83 * s,
        child: IgnorePointer(
          child: CustomPaint(
            key: const ValueKey('profile-avatar-dashes'),
            size: Size(190.103 * s, 186.971 * s),
            painter: _FigmaProfileEllipsePainter(scale: s),
          ),
        ),
      ),
      Positioned(
        top: _mobileAvatarNameTop(s),
        left: 0,
        right: 0,
        child: _buildNameAction(s),
      ),
    ],
  );

  double _mobileAvatarNameTop(double s) => 15 * s;

  double _mobileAvatarPhotoTop(double s) {
    // Reserve the full wrapped name height, including paragraph leading.
    final nameStyle = DefaultTextStyle.of(context).style.merge(
      TextStyle(
        fontSize: 22 * s,
        fontFamily: PetsTheme.fontComfortaa,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
    );
    final namePainter = TextPainter(
      text: TextSpan(text: _nome, style: nameStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: 210 * s);
    return math.max(
      83 * s,
      _mobileAvatarNameTop(s) + namePainter.height + 8 * s,
    );
  }

  int? _nameActionMaxLines(double s) {
    final nameStyle = DefaultTextStyle.of(context).style.merge(
      TextStyle(
        fontSize: 22 * s,
        fontFamily: PetsTheme.fontComfortaa,
        fontWeight: FontWeight.bold,
        color: VetColors.brown,
      ),
    );
    final painter = TextPainter(
      text: TextSpan(text: _nome, style: nameStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 2,
    )..layout(maxWidth: 210 * s);
    return painter.didExceedMaxLines ? null : 2;
  }

  double _mobileAvatarHeight(double s) {
    final photoTop = _mobileAvatarPhotoTop(s);
    final photoShift = photoTop - 83 * s;
    final ellipseBottom = 72.3448 * s + photoShift + 186.971 * s;
    return math.max(
      280 * s,
      math.max(photoTop + 165 * s, ellipseBottom) + 16 * s,
    );
  }

  Widget _buildLegacyAvatarContent(double s) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(height: 15 * s),
      _buildNameAction(s),
      SizedBox(height: 33 * s),
      SizedBox(
        width: 196 * s,
        height: 190 * s,
        child: CustomPaint(
          painter: _DashedCirclePainter(
            color: VetColors.profileOutline,
            strokeWidth: 2 * s,
          ),
          child: Center(child: _buildPhotoAction(s)),
        ),
      ),
    ],
  );

  Widget _buildNameAction(double s) => Semantics(
    key: const ValueKey('profile-change-name-action'),
    button: true,
    label: 'Alterar nome do perfil. Nome atual: $_nome',
    onTap: _mudarNome,
    child: ExcludeSemantics(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _mudarNome,
          borderRadius: BorderRadius.circular(8 * s),
          child: Text(
            _nome,
            textAlign: TextAlign.center,
            maxLines: _nameActionMaxLines(s),
            style: TextStyle(
              fontSize: 22 * s,
              fontFamily: PetsTheme.fontComfortaa,
              fontWeight: FontWeight.bold,
              color: VetColors.brown,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildPhotoAction(double s) => Semantics(
    key: const ValueKey('profile-change-photo-action'),
    button: true,
    label: 'Alterar foto do perfil',
    onTap: _mudarFoto,
    child: ExcludeSemantics(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _mudarFoto,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 165 * s,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: inset_shadow.BoxDecoration(
                color: VetColors.pink,
                shape: BoxShape.circle,
                boxShadow: const [
                  inset_shadow.BoxShadow(
                    color: VetColors.shadowDark,
                    offset: Offset(2, 2),
                    blurRadius: 5,
                    inset: true,
                  ),
                ],
              ),
              child: _buildProfileImage(),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildProfileImage() {
    if (_fotoBytes != null) {
      return Image.memory(_fotoBytes!, fit: BoxFit.cover, cacheWidth: 400);
    }
    if (!kIsWeb && _foto != null) {
      return Image.file(_foto!, fit: BoxFit.cover, cacheWidth: 400);
    }
    return Container(
      key: const ValueKey('profile-empty-photo'),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Image.asset(
        'assets/imagens/figma/profile-pet-placeholder.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBirthday(double s) => Semantics(
    label: 'Data de nascimento: ${fmtData(_nascimento)}',
    child: ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -4 * s),
            child: Image.asset(
              'assets/imagens/figma/profile-birthday-icon.png',
              key: const ValueKey('profile-birthday-icon'),
              width: 18 * s,
              height: 22 * s,
              excludeFromSemantics: true,
            ),
          ),
          SizedBox(width: 8 * s),
          Flexible(
            child: Text(
              _nascimentoTexto,
              style: TextStyle(
                fontSize: 18 * s,
                fontFamily: PetsTheme.fontComfortaa,
                fontWeight: FontWeight.bold,
                color: VetColors.brown,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildOptions(double s) {
    final textScale = MediaQuery.textScalerOf(context).scale(18 * s);
    final allowsWrappedActions = textScale > 18 * s;
    final items = <MapEntry<String, VoidCallback>>[
      MapEntry('Mudar Foto de Perfil', _mudarFoto),
      MapEntry('Mudar Nome de Perfil', _mudarNome),
      MapEntry('Mudar Data de Nascimento', _mudarNascimento),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * s),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(height: s, thickness: s, color: VetColors.profileOutline),
            SizedBox(
              height: allowsWrappedActions
                  ? null
                  : (i == 0
                            ? 53
                            : i == 1
                            ? 56
                            : 57) *
                        s,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      (i == 0
                          ? 53
                          : i == 1
                          ? 56
                          : 57) *
                      s,
                ),
                child: InkWell(
                  onTap: items[i].value,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16 * s,
                      right: 16 * s,
                      top: (i == 0 ? 16 : 19) * s,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            items[i].key,
                            style: TextStyle(
                              fontSize: 18 * s,
                              fontFamily: PetsTheme.fontComfortaa,
                              fontWeight: FontWeight.bold,
                              color: VetColors.brown,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12 * s,
                          height: 20.6299 * s,
                          child: Center(
                            child: SizedBox(
                              width: 11 * s,
                              height: 19.6299 * s,
                              child: SvgPicture.asset(
                                'assets/imagens/figma/services-chevron-right.svg',
                                key: ValueKey('profile-option-chevron-$i'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
  String? _validationError;

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _validationError = 'O nome não pode ficar vazio.');
      return;
    }
    Navigator.pop(context, name);
  }

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VHField(
            'Novo nome',
            Icons.person_outline,
            controller: _controller,
            onChanged: (value) {
              if (_validationError != null && value.trim().isNotEmpty) {
                setState(() => _validationError = null);
              }
            },
          ),
          if (_validationError case final error?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                key: const ValueKey('profile-name-validation-error'),
                liveRegion: true,
                label: error,
                child: Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _save, child: const Text('Salvar')),
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
    const int dashes = 20;
    const double sweep = 2 * math.pi / dashes;
    for (int i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

/// Contorno oval tracejado conforme o vetor exportado do Figma para mobile.
class _FigmaProfileEllipsePainter extends CustomPainter {
  const _FigmaProfileEllipsePainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addOval(
        Rect.fromLTWH(
          1.5 * scale,
          1.5 * scale,
          187.103 * scale,
          183.971 * scale,
        ),
      );
    final paint = Paint()
      ..color = VetColors.profileOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;

    for (final metric in outline.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 30 * scale) {
        final end = math.min(start + 15 * scale, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FigmaProfileEllipsePainter old) =>
      old.scale != scale;
}
