import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/photo_picker.dart';
import '../../data/gabriela_profile_repository.dart';
import '../../theme.dart';
import '../../theme/vet_colors.dart';
import '../../widgets/pets/pets_theme.dart';
import '../../widgets/vet/gabriela_bottom_nav.dart';
import 'gabriela_agenda_tab.dart';
import 'gabriela_messages_tab.dart';

class GabrielaAreaPage extends StatefulWidget {
  const GabrielaAreaPage({super.key});

  @override
  State<GabrielaAreaPage> createState() => _GabrielaAreaPageState();
}

class _GabrielaAreaPageState extends State<GabrielaAreaPage> {
  int _selectedIndex = 0;

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
  late DateTime _birthday = GabrielaProfileRepository.birthDate;
  Uint8List? _photoBytes = GabrielaProfileRepository.photoBytes;

  String get _birthdayLabel =>
      '${_two(_birthday.day)}/${_two(_birthday.month)}/${_birthday.year}';

  String _two(int value) => value.toString().padLeft(2, '0');

  Future<void> _changePhoto() async {
    try {
      final XFile? image = await pickLocalPhoto(context);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _photoBytes = bytes);
      GabrielaProfileRepository.photoBytes = bytes;
    } catch (_) {
      if (mounted) _message('Não foi possível abrir a imagem.');
    }
  }

  Future<void> _changeName() async {
    final controller = TextEditingController(text: _name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VetColors.pink,
        title: const Text('Nome do perfil'),
        content: TextField(controller: controller, autofocus: true),
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
    controller.dispose();
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
      firstDate: DateTime(1920),
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
    return Column(
      children: [
        _GabrielaHeader(title: 'Perfil', height: 116 * s),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 18 * s),
            child: Column(
              children: [
                Transform.translate(
                  offset: Offset(0, -22 * s),
                  child: Container(
                    width: 224 * s,
                    padding: EdgeInsets.fromLTRB(
                      14 * s,
                      14 * s,
                      14 * s,
                      18 * s,
                    ),
                    decoration: BoxDecoration(
                      color: VetColors.pink.withValues(alpha: .55),
                      border: Border.all(color: VetColors.rose, width: 2 * s),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28 * s),
                        bottom: Radius.circular(100 * s),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _name,
                          style: TextStyle(
                            fontFamily: PetsTheme.fontComfortaa,
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w700,
                            color: VetColors.brown,
                          ),
                        ),
                        SizedBox(height: 12 * s),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size(178 * s, 178 * s),
                              painter: _DashedProfileOutlinePainter(),
                            ),
                            ClipOval(
                              child: SizedBox(
                                width: 148 * s,
                                height: 148 * s,
                                child: _photoBytes != null
                                    ? Image.memory(
                                        _photoBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : ColoredBox(
                                        color: VetColors.pink,
                                        child: Image.asset(
                                          'assets/imagens/figma/frame-53-3.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Material(
                                color: VetColors.pink,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _changePhoto,
                                  child: Padding(
                                    padding: EdgeInsets.all(5 * s),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 36 * s,
                                      color: VetColors.profileOutline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -6 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        color: VetColors.brown,
                        size: 18 * s,
                      ),
                      SizedBox(width: 7 * s),
                      Text(
                        _birthdayLabel,
                        style: TextStyle(
                          fontFamily: PetsTheme.fontComfortaa,
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w700,
                          color: VetColors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8 * s),
                _ProfileAction(
                  label: 'Mudar Foto de Perfil',
                  onTap: _changePhoto,
                ),
                _ProfileAction(
                  label: 'Mudar Nome de Perfil',
                  onTap: _changeName,
                ),
                _ProfileAction(
                  label: 'Mudar Data de Nascimento',
                  onTap: _changeBirthday,
                  last: true,
                ),
              ],
            ),
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

class GabrielaSettingsTab extends StatelessWidget {
  const GabrielaSettingsTab({super.key});

  Future<void> _chooseTheme(BuildContext context) async {
    final theme = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: VetColors.pink,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Tema do Aplicativo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFC08081)),
              title: const Text('Rosa VetHome'),
              onTap: () => Navigator.pop(context, VetColors.brown),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF68442E)),
              title: const Text('Marrom VetHome'),
              onTap: () => Navigator.pop(context, VetColors.rose),
            ),
          ],
        ),
      ),
    );
    if (theme != null) VH.themeSeed.value = theme;
  }

  void _showSupport(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: VetColors.pink,
      title: const Text('Suporte'),
      content: const Text(
        'Entre em contato com a equipe VetHome para receber ajuda.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );

  void _showHistory(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: VetColors.pink,
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
            ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Consulta de rotina'),
              subtitle: Text('Rambo · atendimento concluído'),
            ),
            ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Vacinação'),
              subtitle: Text('Olivia · atendimento concluído'),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = PetsTheme.scaleOf(context);
    return Column(
      children: [
        _GabrielaHeader(title: 'Configurações', height: 112 * s),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24 * s, 26 * s, 24 * s, 20 * s),
            child: Column(
              children: [
                _SettingsAction(
                  label: 'Tema do Aplicativo',
                  icon: Icons.palette_outlined,
                  onTap: () => _chooseTheme(context),
                ),
                _SettingsAction(
                  label: 'Suporte',
                  icon: Icons.support_agent,
                  onTap: () => _showSupport(context),
                ),
                _SettingsAction(
                  label: 'Historico',
                  icon: Icons.history,
                  onTap: () => _showHistory(context),
                ),
                _SettingsAction(
                  label: 'Sair',
                  icon: Icons.logout,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/gabriela/login',
                    (_) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GabrielaHeader extends StatelessWidget {
  const _GabrielaHeader({required this.title, required this.height});

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: height,
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 18),
    decoration: const BoxDecoration(
      color: VetColors.rose,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    child: Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontFamily: PetsTheme.fontComfortaa,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.label,
    required this.onTap,
    this.last = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: PetsTheme.fontComfortaa,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: VetColors.brown,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: VetColors.brown),
            ],
          ),
        ),
      ),
      if (!last) const Divider(height: 1, color: VetColors.profileOutline),
    ],
  );
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Material(
      color: VetColors.rose.withValues(alpha: .27),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: VetColors.brown),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VetColors.brown,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: VetColors.brown),
            ],
          ),
        ),
      ),
    ),
  );
}
