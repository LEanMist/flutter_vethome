import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import 'teste_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool esconderSenha = true;
  bool lembrarDeMim = false;

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void entrar() {
    if (!VetRepository.authenticate(
      _emailController.text,
      _passwordController.text,
    )) {
      mostrarMensagem('Informe um e-mail válido e uma senha com 6 caracteres.');
      return;
    }
    Navigator.pushReplacementNamed(context, '/pets');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final s = (constraints.maxWidth / 390).clamp(.8, 1.0);
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    // Assets exportados do Figma; a almofada ultrapassa o frame.
                    Positioned(
                      left: 10.25 * s,
                      top: 190 * s,
                      width: 369.5 * s,
                      height: 311.5 * s,
                      child: Image.asset(
                        'assets/imagens/figma/polygon-2.png',
                        fit: BoxFit.fill,
                        excludeFromSemantics: true,
                      ),
                    ),
                    for (final pad in const [
                      ('frame-35.png', 89.0, 77.0, 82.0, 104.5),
                      ('frame-36.png', 210.0, 77.0, 82.0, 104.5),
                      ('frame-34-3.png', -7.0, 141.0, 96.0, 112.5),
                      ('frame-37.png', 282.0, 141.0, 96.0, 112.5),
                    ])
                      Positioned(
                        left: pad.$2 * s,
                        top: pad.$3 * s,
                        width: pad.$4 * s,
                        height: pad.$5 * s,
                        child: Image.asset(
                          'assets/imagens/figma/${pad.$1}',
                          excludeFromSemantics: true,
                        ),
                      ),
                    Column(
                      children: [
                        SizedBox(height: 180 * s),
                        Image.asset(
                          'assets/imagens/figma/vethomepng-2.png',
                          width: 166 * s,
                          height: 166 * s,
                          fit: BoxFit.contain,
                          semanticLabel: 'VetHome',
                        ),
                        // O primeiro campo começa em 333 no frame de referência.
                        Transform.translate(
                          offset: Offset(0, -13 * s),
                          child: Column(
                            children: [
                              _loginField(
                                'Usuário',
                                _emailController,
                                prefix: 'frame-6.png',
                                scale: s,
                              ),
                              SizedBox(height: 17 * s),
                              _loginField(
                                'Senha',
                                _passwordController,
                                prefix: 'frame-7-5.png',
                                scale: s,
                                password: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 286,
                          height: 48,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Checkbox(
                                  semanticLabel: 'Lembre-se de mim',
                                  value: lembrarDeMim,
                                  onChanged: (v) =>
                                      setState(() => lembrarDeMim = v ?? false),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'Lembre-se de mim',
                                  style: TextStyle(fontSize: 9),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                  ),
                                  onPressed: () => mostrarMensagem(
                                    'Procure o suporte para recuperar o acesso.',
                                  ),
                                  child: const Text(
                                    'Esqueceu sua senha?',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color.fromRGBO(0, 0, 0, .5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 11),
                        SizedBox(
                          width: 303 * s,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: entrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VH.secondary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            icon: const Icon(Icons.login, size: 21),
                            iconAlignment: IconAlignment.end,
                            label: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: VH.foreground.withValues(alpha: .5),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                child: Text(
                                  'Ou continue com',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: VetColors.brownSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: VH.foreground.withValues(alpha: .5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (final social in const [
                              ('Google', 'icons8-google-logo-96-1.png'),
                              ('Facebook', 'icons8-facebook-novo-96-1.png'),
                              ('Instagram', 'icons8-instagram-96-1.png'),
                            ])
                              Tooltip(
                                message: social.$1,
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: () => mostrarMensagem(
                                      'Login social em breve.',
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: VH.background,
                                      side: const BorderSide(
                                        color: Colors.black26,
                                      ),
                                      shape: const CircleBorder(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Image.asset(
                                      'assets/imagens/figma/${social.$2}',
                                      width: 39,
                                      height: 39,
                                      semanticLabel: social.$1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 27),
                        const Text(
                          'Ainda não possui uma conta?',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: VetColors.brownSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/cadastro'),
                          child: const Text(
                            'CADASTRE-SE',
                            style: TextStyle(
                              fontFamily: VH.bodyFontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: VH.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    if (Navigator.of(context).canPop())
                      Positioned(
                        top: 4,
                        left: 8,
                        child: IconButton(
                          tooltip: 'Voltar',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 8,
                      child: IconButton(
                        tooltip: 'Telas de teste',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TestePage()),
                        ),
                        icon: const Icon(Icons.dashboard_outlined),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _loginField(
    String label,
    TextEditingController controller, {
    required String prefix,
    required double scale,
    bool password = false,
  }) => SizedBox(
    width: 242 * scale,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          colors: [VH.secondary.withValues(alpha: .25), VH.background],
        ),
        boxShadow: const [
          BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: password && esconderSenha,
        keyboardType: password
            ? TextInputType.text
            : TextInputType.emailAddress,
        onSubmitted: (_) => entrar(),
        style: const TextStyle(
          fontFamily: VH.headingFontFamily,
          fontSize: 13,
          color: VH.foreground,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: VH.foreground.withValues(alpha: .5),
            fontSize: 13,
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: VH.foreground),
          ),
          prefixIconConstraints: const BoxConstraints.tightFor(
            width: 50,
            height: 48,
          ),
          prefixIcon: Image.asset(
            'assets/imagens/figma/$prefix',
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          suffixIcon: password
              ? IconButton(
                  tooltip: 'Mostrar/ocultar senha',
                  onPressed: () =>
                      setState(() => esconderSenha = !esconderSenha),
                  icon: Icon(
                    esconderSenha
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: VH.foreground.withValues(alpha: .5),
                  ),
                )
              : null,
        ),
      ),
    ),
  );
}
