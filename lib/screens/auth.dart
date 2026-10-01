import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

const _logo = 'assets/imagens/VetHome_logo_1.jpg';

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
      body: Center(
        child: Container(
          width: 224,
          padding: const EdgeInsets.all(16),
          decoration: insetBox(color: VH.card, radius: 999),
          child: ClipOval(child: Image.asset(_logo)),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                        const Text('Lembrar de mim', style: TextStyle(fontSize: 12)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Entre em contato com o suporte para recuperar o acesso.'),
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
                  _SocialIcon(icon: Icons.g_mobiledata, color: Color(0xFF4285F4)),
                  _SocialIcon(icon: Icons.facebook, color: Color(0xFF1877F2)),
                  _SocialIcon(icon: Icons.camera_alt_outlined, color: Color(0xFFC13584)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Ainda não possui uma conta?', style: TextStyle(fontSize: 12)),
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

class VHForm extends StatelessWidget {
  const VHForm({
    super.key,
    required this.title,
    required this.fields,
    required this.next,
  });

  final String title;
  final List<VHField> fields;
  final String next;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VH.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: VH.secondary, width: 3),
              ),
              child: Column(
                children: [
                  for (final field in fields) ...[
                    field,
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: PillButton(
                label: 'Continuar',
                onTap: () => Navigator.pushNamed(context, next),
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
    next: '/endereco',
    fields: [
      VHField('Nome Completo', Icons.person),
      VHField('Data de Nascimento', Icons.cake),
      VHField('Gênero/Sexo', Icons.person_outline),
      VHField('CPF', Icons.badge),
      VHField('Telefone/Celular', Icons.phone),
      VHField('E-mail', Icons.mail),
      VHField('Senha', Icons.lock, password: true),
      VHField('Confirmar Senha', Icons.lock, password: true),
    ],
  );
}

class EnderecoScreen extends StatelessWidget {
  const EnderecoScreen({super.key});

  @override
  Widget build(BuildContext context) => const VHForm(
    title: 'Endereço',
    next: '/cadastroPet',
    fields: [
      VHField('CEP', Icons.home),
      VHField('Endereço', Icons.home),
      VHField('Número', Icons.tag),
      VHField('Complemento', Icons.home),
      VHField('Cidade', Icons.location_city),
    ],
  );
}

class CadastroPetScreen extends StatelessWidget {
  const CadastroPetScreen({super.key});

  @override
  Widget build(BuildContext context) => const VHForm(
    title: 'Cadastro Pet',
    next: '/sucesso',
    fields: [
      VHField('Tipo de Animal', Icons.pets),
      VHField('Nome do Pet', Icons.person),
      VHField('Gênero/Sexo', Icons.person_outline),
      VHField('Peso', Icons.scale),
      VHField('Data de Nascimento', Icons.cake),
      VHField('Raça', Icons.pets),
    ],
  );
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
                const Text(
                  'É um prazer ter você conosco!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 28),
                  width: 176,
                  padding: const EdgeInsets.all(12),
                  decoration: insetBox(color: VH.card, radius: 999),
                  child: ClipOval(child: Image.asset(_logo)),
                ),
                const Text(
                  'Cadastro concluído!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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