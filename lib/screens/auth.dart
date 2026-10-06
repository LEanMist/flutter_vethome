import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../data/vet_repository.dart';
import '../data/cep_service.dart';
import '../core/utils/form_fields.dart';
import '../widgets/address_form.dart';
import '../widgets/pet_form.dart';
import '../widgets/client_gender_fields.dart';
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

class VHForm extends StatefulWidget {
  const VHForm({
    super.key,
    required this.title,
    required this.fields,
    required this.next,
    this.initialData = const {},
    this.dataPrefix = '',
  });

  final String title;
  final List<VHField> fields;
  final String next;
  final Map<String, String> initialData;
  final String dataPrefix;

  @override
  State<VHForm> createState() => _VHFormState();
}

class _VHFormState extends State<VHForm> {
  final _formKey = GlobalKey<FormState>();
  late final _genderCustom = TextEditingController(
    text: widget.initialData['client.Gênero personalizado'] ?? '',
  );
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _makeControllers();
  }

  @override
  void didUpdateWidget(covariant VHForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.initialData, widget.initialData) ||
        !listEquals(
          oldWidget.fields.map((f) => f.label).toList(),
          widget.fields.map((f) => f.label).toList(),
        )) {
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
    _genderCustom.dispose();
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
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (field.label == 'CPF' && digits.length != 11) {
      return 'Informe um CPF com 11 dígitos';
    }
    if (field.label == 'Telefone/Celular' &&
        digits.length != 10 &&
        digits.length != 11) {
      return 'Informe um telefone com 10 ou 11 dígitos';
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
    if (field.label.contains('Nascimento') && !_isValidDate(value)) {
      return 'Use uma data válida (DD/MM/AAAA)';
    }
    return null;
  }

  bool _isValidDate(String value) => parseBirthDate(value) != null;

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final data = <String, String>{
      ...widget.initialData,
      for (var i = 0; i < widget.fields.length; i++)
        '${widget.dataPrefix}${widget.fields[i].label}': _controllers[i].text
            .trim(),
    };
    if (widget.dataPrefix == 'client.') {
      data['client.Gênero personalizado'] = _genderCustom.text.trim();
    }
    Navigator.pushNamed(context, widget.next, arguments: data);
  }

  Widget _buildField(int i) {
    final field = widget.fields[i];
    if (widget.dataPrefix == 'client.' && field.label == 'Gênero/Sexo') {
      return ClientGenderFields(
        gender: _controllers[i],
        custom: _genderCustom,
        figmaForm: true,
        validator: (v) => _validate(field, v),
      );
    }
    return VHField(
      field.label,
      field.icon,
      password: field.password,
      figmaForm: true,
      controller: _controllers[i],
      keyboardType: field.keyboardType,
      choices: field.choices,
      onChanged: (value) {
        setState(() {});
      },
      validator: (value) => _validate(field, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                39 * (MediaQuery.sizeOf(context).width / 390).clamp(.8, 1.0),
                38,
                39 * (MediaQuery.sizeOf(context).width / 390).clamp(.8, 1.0),
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Comfortaa',
                      color: VH.foreground,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: VH.secondary, width: 3),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          for (var i = 0; i < widget.fields.length; i++) ...[
                            _buildField(i),
                            if (i != widget.fields.length - 1)
                              const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: PillButton(
                      color: VH.secondary,
                      padding: EdgeInsets.zero,
                      onTap: _continue,
                      child: SizedBox(
                        width: 181,
                        height: 71,
                        child: const Center(
                          child: Text(
                            'Cadastrar',
                            style: TextStyle(
                              fontFamily: VH.headingFontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
      VHField(
        'Gênero/Sexo',
        Icons.wc,
        choices: ['Masculino', 'Feminino', 'Outro', 'Prefiro não informar'],
      ),
      VHField('CPF', Icons.badge, value: '534.356.874-94'),
      VHField('Telefone/Celular', Icons.phone, value: '11 94345-3266'),
      VHField('E-mail', Icons.mail, value: 'Kelvin231@gmail.com'),
      VHField('Senha', Icons.lock, password: true),
      VHField('Confirmar Senha', Icons.lock, password: true),
    ],
  );
}

class EnderecoScreen extends StatelessWidget {
  const EnderecoScreen({
    super.key,
    this.initialData = const {},
    this.cepService = const CepService(),
  });
  final Map<String, String> initialData;
  final CepService cepService;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      child: AddressForm(
        cepService: cepService,
        title: 'Endereço',
        onSaved: (address) {
          final data = {
            ...initialData,
            'client.CEP': address.cep,
            'client.Endereço': address.street,
            'client.Cidade': address.city,
            'client.Número': address.number,
            'client.Complemento': address.complement,
          };
          VetRepository.registerClient(data);
          Navigator.pushNamed(context, '/cadastroPet', arguments: data);
        },
        onSkip: () {
          VetRepository.registerClient(initialData);
          Navigator.pushNamed(context, '/cadastroPet', arguments: initialData);
        },
      ),
    ),
  );
}

class CadastroPetScreen extends StatelessWidget {
  const CadastroPetScreen({super.key, this.initialData = const {}});
  final Map<String, String> initialData;
  void _client() {
    if (initialData.containsKey('client.E-mail')) {
      VetRepository.registerClient(initialData);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: PetForm(
            title: 'Cadastro Pet',
            onSaved: (v) async {
              final pet = VetRepository.addPet(
                name: v.name,
                species: v.species,
                sex: v.sex,
                weightKg: v.weight,
                birthDate: v.birth,
                breed: v.breed,
                photoBase64: v.photo,
                neutered: v.neutered,
              );
              _client();
              final saved = await VetRepository.flush();
              if (!context.mounted) return;
              if (!saved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
                    ),
                  ),
                );
              }
              if (initialData['flow'] == 'addPet') {
                VetRepository.selectedPetId = pet.id;
                Navigator.pop(context, pet);
              } else {
                Navigator.pushNamed(context, '/sucesso');
              }
            },
            onSkip: () {
              _client();
              if (initialData['flow'] == 'addPet') {
                Navigator.pop(context);
              } else {
                Navigator.pushNamed(context, '/sucesso');
              }
            },
          ),
        ),
      ),
    ),
  );
}

class SucessoScreen extends StatefulWidget {
  const SucessoScreen({super.key});
  @override
  State<SucessoScreen> createState() => _SucessoScreenState();
}

class _SucessoScreenState extends State<SucessoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _arrived = false;
  @override
  void initState() {
    super.initState();
    _controller.forward().then((_) async {
      if (!mounted) return;
      setState(() => _arrived = true);
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/pets', (_) => false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bem-vindo!',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, .5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: Image.asset(
                  'assets/imagens/figma/vethomepng-2.png',
                  width: (MediaQuery.sizeOf(context).width - 40).clamp(
                    240.0,
                    350.0,
                  ),
                  height: (MediaQuery.sizeOf(context).width - 40).clamp(
                    240.0,
                    350.0,
                  ),
                ),
              ),
              const SizedBox(height: 27),
              AnimatedOpacity(
                opacity: _arrived ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Text(
                  VetRepository.pets.isEmpty
                      ? 'Você pode cadastrar seu pet quando quiser.'
                      : 'Você e seu pet já podem usar o VetHome.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: VH.headingFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: VH.foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
