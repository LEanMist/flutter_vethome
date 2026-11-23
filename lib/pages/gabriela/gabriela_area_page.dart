import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../auth/auth_session.dart';
import '../../core/utils/pet_photo.dart';
import '../../data/gabriela_profile_repository.dart';
import '../../data/theme_preferences.dart';
import '../../theme.dart';
import '../../theme/vet_colors.dart';
import '../../widgets.dart' show VHHeader;
import '../../widgets/auth/demo_mode_notice.dart';
import '../../widgets/pets/pets_theme.dart';
import '../../widgets/vet/gabriela_bottom_nav.dart';
import '../../widgets/vet/vet_centered_dialog.dart';
import 'gabriela_agenda_tab.dart';
import 'gabriela_messages_tab.dart';

class GabrielaAreaPage extends StatefulWidget {
  const GabrielaAreaPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<GabrielaAreaPage> createState() => _GabrielaAreaPageState();
}

class _GabrielaAreaPageState extends State<GabrielaAreaPage> {
  late int _selectedIndex = widget.initialIndex < 0
      ? 0
      : widget.initialIndex > 3
      ? 3
      : widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const GabrielaProfileTab(),
      const GabrielaMessagesTab(),
      const GabrielaAgendaTab(),
      const GabrielaSettingsTab(),
    ];
    return Scaffold(
      backgroundColor: VetColors.pink,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: pages),
                ),
                if (AuthScope.maybeOf(context)?.isDemo == true)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 4),
                    child: DemoModeNotice(
                      compact: true,
                      multiline: true,
                      message: 'Demonstração · permissões simuladas',
                    ),
                  ),
                GabrielaBottomNav(
                  selectedIndex: _selectedIndex,
                  onSelected: (index) => setState(() => _selectedIndex = index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GabrielaProfileTab extends StatefulWidget {
  const GabrielaProfileTab({super.key});

  @override
  State<GabrielaProfileTab> createState() => _GabrielaProfileTabState();
}

class _GabrielaProfileTabState extends State<GabrielaProfileTab> {
  late String _name = GabrielaProfileRepository.name;
  late DateTime? _birthday = GabrielaProfileRepository.birthDate;
  Uint8List? _photoBytes = GabrielaProfileRepository.photoBytes;
  bool _changingPhoto = false;

  String get _birthdayLabel {
    final date = _birthday;
    if (date == null) return 'Nascimento não informado';
    return '${_two(date.day)} / ${_two(date.month)} / ${date.year}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  Future<void> _changePhoto() async {
    if (_changingPhoto) return;
    setState(() => _changingPhoto = true);
    String? photo;
    try {
      photo = await PetPhoto.choose(context, centered: true);
      if (photo == null || !mounted) return;
      await GabrielaProfileRepository.updatePhoto(photo);
      if (mounted) {
        setState(() => _photoBytes = GabrielaProfileRepository.photoBytes);
      }
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) {
        _message(
          photo == null
              ? 'Não foi possível abrir a imagem.'
              : 'Não foi possível salvar a foto de perfil.',
        );
      }
    } finally {
      if (mounted) setState(() => _changingPhoto = false);
    }
  }

  Future<void> _changeName() async {
    var editedName = _name;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VetColors.pink,
        title: const Text('Nome do perfil'),
        content: TextFormField(
          initialValue: _name,
          autofocus: true,
          onChanged: (value) => editedName = value,
          onFieldSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, editedName.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await GabrielaProfileRepository.updateName(name);
      if (mounted) setState(() => _name = name);
    } catch (_) {
      if (mounted) _message('Não foi possível salvar o nome.');
    }
  }

  Future<void> _changeBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: GabrielaProfileRepository.firstBirthDate,
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (date == null || !mounted) return;
    try {
      await GabrielaProfileRepository.updateBirthDate(date);
      if (mounted) setState(() => _birthday = date);
    } catch (_) {
      if (mounted) _message('Não foi possível salvar a data de nascimento.');
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final s = PetsTheme.scaleOf(context);
    final photo = _photoBytes;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 131 * s,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: VetColors.rose,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 22 * s, 16, 7 * s),
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Perfil',
                      style: TextStyle(
                        fontFamily: PetsTheme.fontComfortaa,
                        fontSize: 30 * s,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 220 * s,
                  padding: EdgeInsets.fromLTRB(8 * s, 15 * s, 8 * s, 10 * s),
                  decoration: BoxDecoration(
                    color: VetColors.pink.withValues(alpha: .5),
                    border: Border.all(color: VetColors.rose, width: 5 * s),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30 * s),
                      bottom: Radius.circular(110 * s),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: PetsTheme.fontComfortaa,
                          fontSize: 22 * s,
                          fontWeight: FontWeight.bold,
                          color: VetColors.brown,
                        ),
                      ),
                      SizedBox(height: 28 * s),
                      CustomPaint(
                        painter: _DashedProfileOutlinePainter(),
                        child: Padding(
                          padding: EdgeInsets.all(12 * s),
                          child: Material(
                            type: MaterialType.transparency,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _changingPhoto ? null : _changePhoto,
                              child: Semantics(
                                button: true,
                                label: 'Alterar foto de perfil',
                                child: SizedBox.square(
                                  dimension: 165 * s,
                                  child: photo == null
                                      ? Image.asset(
                                          'assets/imagens/figma/profile-pet-placeholder.png',
                                          fit: BoxFit.contain,
                                          excludeFromSemantics: true,
                                        )
                                      : Image.memory(
                                          photo,
                                          fit: BoxFit.cover,
                                          excludeFromSemantics: true,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.add_a_photo_outlined,
                                            color: VetColors.brown,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10 * s, 16, 64 * s),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8 * s,
            children: [
              Image.asset(
                'assets/imagens/figma/profile-birthday-icon.png',
                width: 18 * s,
                height: 22 * s,
                excludeFromSemantics: true,
              ),
              Text(
                _birthdayLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: PetsTheme.fontComfortaa,
                  fontSize: 18 * s,
                  fontWeight: FontWeight.bold,
                  color: VetColors.brown,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          child: Column(
            children: [
              _ProfileAction(
                label: 'Mudar Foto de Perfil',
                onTap: _changingPhoto ? null : _changePhoto,
              ),
              _ProfileAction(label: 'Mudar Nome de Perfil', onTap: _changeName),
              _ProfileAction(
                label: 'Mudar Data de Nascimento',
                onTap: _changeBirthday,
                last: true,
              ),
              if (GabrielaProfileRepository.readFailed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Semantics(
                    liveRegion: true,
                    child: const Text(
                      'Não foi possível carregar todos os dados do perfil.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedProfileOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addOval(Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3));
    final paint = Paint()
      ..color = VetColors.brown.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 18) {
        final end = (start + 9).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GabrielaSettingsTab extends StatefulWidget {
  const GabrielaSettingsTab({super.key});

  @override
  State<GabrielaSettingsTab> createState() => _GabrielaSettingsTabState();
}

class _GabrielaSettingsTabState extends State<GabrielaSettingsTab> {
  bool _choosingPalette = false;

  Future<void> _chooseTheme(BuildContext context) async {
    if (_choosingPalette) return;
    _choosingPalette = true;
    try {
      final palette = await showVetCenteredDialog<Color>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Paleta de cores',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('A aparência permanece clara.'),
              ),
              for (final option in ThemePreferences.options)
                ListTile(
                  leading: CircleAvatar(backgroundColor: option.color),
                  title: Text('${option.name} VetHome'),
                  selected: option.color == VH.themeSeed.value,
                  trailing: option.color == VH.themeSeed.value
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, option.color),
                ),
            ],
          ),
        ),
      );
      if (palette == null || palette == VH.themeSeed.value) return;
      if (await ThemePreferences.save(palette)) {
        VH.themeSeed.value = palette;
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar a paleta de cores.'),
          ),
        );
      }
    } finally {
      _choosingPalette = false;
    }
  }

  void _showSupport(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: VetColors.pink,
      title: const Text('Suporte'),
      content: const Text(
        'A equipe VetHome ainda não informou os canais oficiais de suporte.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );

  void _showHistory(BuildContext context) => showVetCenteredDialog<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Histórico',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: VetColors.brown,
              ),
            ),
            SizedBox(height: 16),
            Text('Nenhum atendimento verificado disponível.'),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final actions = <({String label, VoidCallback onTap})>[
      (label: 'Tema do Aplicativo', onTap: () => _chooseTheme(context)),
      (label: 'Suporte', onTap: () => _showSupport(context)),
      (label: 'Histórico', onTap: () => _showHistory(context)),
      (label: 'Sair', onTap: () => AuthScope.signOut(context)),
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const VHHeader('Configurações', showBack: false, settingsStyle: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 26, 12, 24),
          child: Column(
            children: [
              for (var index = 0; index < actions.length; index++) ...[
                ListTile(
                  minTileHeight: 57,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    actions[index].label,
                    style: const TextStyle(
                      fontFamily: VH.headingFontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: VH.foreground,
                    ),
                  ),
                  trailing: SvgPicture.asset(
                    'assets/imagens/figma/services-chevron-right.svg',
                    width: 11,
                    height: 19.6299,
                    excludeFromSemantics: true,
                  ),
                  onTap: actions[index].onTap,
                ),
                if (index < actions.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: VH.foreground.withValues(alpha: .25),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.label,
    required this.onTap,
    this.last = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        enabled: onTap != null,
        onTap: onTap,
        minTileHeight: 56,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: VH.headingFontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: VetColors.brown,
          ),
        ),
        trailing: SvgPicture.asset(
          'assets/imagens/figma/services-chevron-right.svg',
          width: 11,
          height: 19.6299,
          excludeFromSemantics: true,
        ),
      ),
      if (!last)
        Divider(
          height: 1,
          thickness: 1,
          color: VetColors.brown.withValues(alpha: .25),
        ),
    ],
  );
}
