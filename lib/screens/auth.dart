import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../widgets.dart';

const _logo = 'assets/imagens/figma/vethomepng-2.png';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: Center(
        child: Container(
          width: 136,
          height: 136,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: VH.secondary.withValues(alpha: 0.45)),
          ),
          child: Image.asset(_logo, width: 108, height: 108),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool lembrar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Image.asset(_logo, width: 164, height: 164, fit: BoxFit.contain),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VH.card,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: VH.raise,
                ),
                child: Column(
                  children: [
                    const VHField('Usuário', Icons.person),
                    const SizedBox(height: 12),
                    const VHField('Senha', Icons.lock, password: true),
                    Row(
                      children: [
                        Checkbox(
                          value: lembrar,
                          onChanged: (value) =>
                              setState(() => lembrar = value ?? false),
                        ),
                        const Text(
                          'Lembrar de mim',
                          style: TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Entre em contato com o suporte para recuperar o acesso.',
                                ),
                              ),
                            ),
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PillButton(
                label: 'Entrar',
                onTap: () => Navigator.pushReplacementNamed(context, '/pets'),
              ),
              const SizedBox(height: 20),
              const Text('Ou continue com', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIcon(
                    icon: Icons.g_mobiledata,
                    color: Color(0xFF4285F4),
                  ),
                  _SocialIcon(icon: Icons.facebook, color: Color(0xFF1877F2)),
                  _SocialIcon(
                    icon: Icons.camera_alt_outlined,
                    color: Color(0xFFC13584),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Ainda não possui uma conta?',
                style: TextStyle(fontSize: 12),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 25),
      ),
    );
  }
}

class VHForm extends StatefulWidget {
  const VHForm({
    super.key,
    required this.title,
    required this.fields,
    required this.next,
    this.initialData = const {},
    this.onSubmit,
    this.dataPrefix = '',
  });

  final String title;
  final List<VHField> fields;
  final String next;
  final Map<String, String> initialData;
  final ValueChanged<Map<String, String>>? onSubmit;
  final String dataPrefix;

  @override
  State<VHForm> createState() => _VHFormState();
}

class _VHFormState extends State<VHForm> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _makeControllers();
  }

  @override
  void didUpdateWidget(covariant VHForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialData != widget.initialData ||
        oldWidget.fields != widget.fields) {
      for (final controller in _controllers) {
        controller.dispose();
      }
      _controllers = _makeControllers();
    }
  }

  List<TextEditingController> _makeControllers() => [
    for (final field in widget.fields)
      TextEditingController(
        text: widget.initialData['${widget.dataPrefix}${field.label}'] ?? '',
      ),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validate(VHField field, String? rawValue) {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) {
      return field.label == 'Complemento' ? null : 'Preencha este campo';
    }
    if (field.label == 'E-mail' &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Informe um e-mail válido';
    }
    if (field.label == 'Senha' && value.length < 6) {
      return 'Use ao menos 6 caracteres';
    }
    if (field.label == 'Confirmar Senha' &&
        widget.fields.any((item) => item.label == 'Senha') &&
        value !=
            _controllers[widget.fields.indexWhere(
                  (item) => item.label == 'Senha',
                )]
                .text) {
      return 'As senhas não coincidem';
    }
    if (field.label == 'Nome do Pet' && VetRepository.petNameExists(value)) {
      return 'Já existe um pet com esse nome';
    }
    if (field.label == 'Peso') {
      final weight = double.tryParse(value.replaceAll(',', '.'));
      if (weight == null || weight <= 0) return 'Informe um peso válido';
    }
    if (field.label.contains('Nascimento') && !_isValidDate(value)) {
      return 'Use uma data válida (DD/MM/AAAA)';
    }
    return null;
  }

  bool _isValidDate(String value) {
    final parts = value.split(RegExp(r'[/.-]'));
    if (parts.length != 3) return false;
    final first = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final last = int.tryParse(parts[2]);
    if (first == null || month == null || last == null) return false;
    final date = first > 31
        ? DateTime(first, month, last)
        : DateTime(last, month, first);
    return date.year >= 1900 &&
        date.month == month &&
        date.day == (first > 31 ? last : first) &&
        !date.isAfter(DateTime.now());
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final data = <String, String>{
      ...widget.initialData,
      for (var i = 0; i < widget.fields.length; i++)
        '${widget.dataPrefix}${widget.fields[i].label}': _controllers[i].text
            .trim(),
    };
    widget.onSubmit?.call(data);
    Navigator.pushNamed(context, widget.next, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Comfortaa',
                color: VH.foreground,
              ),
            ),
            const SizedBox(height: 18),
            if (widget.title == 'Cadastro Pet') ...[
              Image.asset(
                'assets/imagens/figma/cachorroegatopng-2.png',
                width: 58,
                height: 66,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: VH.background.withValues(alpha: 0.46),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: VH.secondary, width: 1.5),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    for (var i = 0; i < widget.fields.length; i++) ...[
                      VHField(
                        widget.fields[i].label,
                        widget.fields[i].icon,
                        password: widget.fields[i].password,
                        controller: _controllers[i],
                        keyboardType: widget.fields[i].keyboardType,
                        validator: (value) =>
                            _validate(widget.fields[i], value),
                      ),
                      const SizedBox(height: 7),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: PillButton(
                label: 'Cadastrar',
                color: VH.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 11,
                ),
                onTap: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context) => const VHForm(
    title: 'Cadastro',
    dataPrefix: 'client.',
    next: '/endereco',
    fields: [
      VHField('Nome Completo', Icons.person, value: 'Matheus Santana Lima'),
      VHField('Data de Nascimento', Icons.cake, value: '05/02/2007'),
      VHField('Gênero/Sexo', Icons.person_outline, value: 'Masculino'),
      VHField('CPF', Icons.badge, value: '534.356.874-94'),
      VHField('Telefone/Celular', Icons.phone, value: '11 94345-3266'),
      VHField('E-mail', Icons.mail, value: 'Kelvin231@gmail.com'),
      VHField('Senha', Icons.lock, password: true),
      VHField('Confirmar Senha', Icons.lock, password: true),
    ],
  );
}

class EnderecoScreen extends StatelessWidget {
  const EnderecoScreen({super.key, this.initialData = const {}});

  final Map<String, String> initialData;

  @override
  Widget build(BuildContext context) => VHForm(
    title: 'Endereço',
    dataPrefix: 'client.',
    next: '/cadastroPet',
    initialData: initialData,
    fields: const [
      VHField(
        'CEP',
        Icons.home,
        value: '34556-234',
        keyboardType: TextInputType.number,
      ),
      VHField('Endereço', Icons.home, value: 'R. Carcino'),
      VHField(
        'Número',
        Icons.tag,
        value: '73',
        keyboardType: TextInputType.number,
      ),
      VHField('Complemento', Icons.home),
      VHField('Cidade', Icons.location_city),
    ],
  );
}

class CadastroPetScreen extends StatelessWidget {
  const CadastroPetScreen({super.key, this.initialData = const {}});

  final Map<String, String> initialData;

  @override
  Widget build(BuildContext context) => VHForm(
    title: 'Cadastro Pet',
    dataPrefix: 'pet.',
    next: '/sucesso',
    initialData: initialData,
    fields: [
      VHField('Tipo de Animal', Icons.pets, value: 'Cachorro'),
      VHField('Nome do Pet', Icons.person, value: 'Fernando'),
      VHField('Gênero/Sexo', Icons.person_outline, value: 'M'),
      VHField(
        'Peso',
        Icons.scale,
        value: '24',
        keyboardType: TextInputType.number,
      ),
      VHField('Data de Nascimento', Icons.cake, value: '23/03/2012'),
      VHField('Raça', Icons.pets, value: 'Lulu-da-Pomerânia'),
    ],
    onSubmit: (data) {
      final weight = double.parse(data['pet.Peso']!.replaceAll(',', '.'));
      final birth = _parseDate(data['pet.Data de Nascimento']!);
      VetRepository.addPet(
        name: data['pet.Nome do Pet']!,
        species: data['pet.Tipo de Animal']!,
        sex: data['pet.Gênero/Sexo']!,
        weightKg: weight,
        birthDate: birth,
        breed: data['pet.Raça']!,
      );
      if (data.containsKey('client.E-mail')) {
        VetRepository.registerClient(data);
      }
    },
  );

  static DateTime _parseDate(String value) {
    final parts = value.split(RegExp(r'[/.-]')).map(int.parse).toList();
    return parts[0] > 31
        ? DateTime(parts[0], parts[1], parts[2])
        : DateTime(parts[2], parts[1], parts[0]);
  }
}

class SucessoScreen extends StatelessWidget {
  const SucessoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'É um prazer tê-lo(a) conosco, senhor(a) '
                  '${VetRepository.clientName}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'MontserratAlternates',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    'assets/imagens/figma/vethomepng-1.png',
                    width: 226,
                    height: 226,
                    fit: BoxFit.contain,
                  ),
                ),
                const Text(
                  'Usuário e Pets Cadastrados!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Comfortaa',
                  ),
                ),
                const SizedBox(height: 28),
                PillButton(
                  label: 'Continuar',
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/pets',
                    (_) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
