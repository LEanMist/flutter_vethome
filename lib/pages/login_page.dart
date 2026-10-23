import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

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
  final _rememberFocusNode = FocusNode(debugLabel: 'Lembre-se de mim');

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
    _rememberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          key: const ValueKey('login-surface'),
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
                      ('frame-35.png', 97.0, 82.0, 81.66, 104.03),
                      ('frame-36.png', 216.0, 82.0, 81.66, 104.03),
                      ('frame-34-3.png', 4.0, 151.0, 95.97, 112.05),
                      ('frame-37.png', 288.0, 151.0, 95.97, 112.05),
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
                        Transform.translate(
                          offset: Offset((258 - 242 * s) / 2, -17.5),
                          child: SizedBox(
                            width: 258,
                            height: 48,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: _RememberMeControl(
                                    value: lembrarDeMim,
                                    focusNode: _rememberFocusNode,
                                    onChanged: (value) =>
                                        setState(() => lembrarDeMim = value),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 26),
                                    ),
                                    onPressed: () => mostrarMensagem(
                                      'Procure o suporte para recuperar o acesso.',
                                    ),
                                    child: const Text(
                                      'Esqueceu sua senha?',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Color.fromRGBO(0, 0, 0, .5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 11),
                        SizedBox(
                          width: 303 * s,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: entrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VetColors.brown,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: .25),
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
                                padding: EdgeInsets.symmetric(horizontal: 26),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final (index, social) in const [
                              ('Google', 'icons8-google-logo-96-1.png'),
                              ('Facebook', 'icons8-facebook-novo-96-1.png'),
                              ('Instagram', 'icons8-instagram-96-1.png'),
                            ].indexed) ...[
                              if (index > 0) const SizedBox(width: 37.5),
                              Tooltip(
                                message: social.$1,
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: VH.background,
                                    boxShadow: [
                                      BoxShadow(
                                        color: VH.shadowSubtle,
                                        offset: Offset(2, 2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: OutlinedButton(
                                      onPressed: () => mostrarMensagem(
                                        'Login social em breve.',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: VH.background,
                                        side: BorderSide.none,
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
                              ),
                            ],
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
                    if (kDebugMode)
                      Positioned(
                        top: 4,
                        right: 8,
                        child: IconButton(
                          tooltip: 'Telas de teste',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TestePage(),
                            ),
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
    height: 48,
    child: DecoratedBox(
      decoration: inset_shadow.BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          colors: [VH.secondary.withValues(alpha: .25), VH.background],
        ),
        boxShadow: const [
          inset_shadow.BoxShadow(
            color: VetColors.shadowDark,
            offset: Offset(2, 2),
            blurRadius: 2,
            inset: true,
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
        style: GoogleFonts.montserratAlternates(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: VH.foreground,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.montserratAlternates(
            color: VH.foreground.withValues(alpha: .5),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          filled: false,
          contentPadding: const EdgeInsets.fromLTRB(14, 17, 8, 13),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: VH.foreground),
          ),
          prefixIconConstraints: const BoxConstraints.tightFor(
            width: 60,
            height: 48,
          ),
          prefixIcon: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/imagens/figma/$prefix',
              width: password ? 50 : 48,
              height: 48,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
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

class _RememberMeControl extends StatefulWidget {
  const _RememberMeControl({
    required this.value,
    required this.focusNode,
    required this.onChanged,
  });

  final bool value;
  final FocusNode focusNode;
  final ValueChanged<bool> onChanged;

  @override
  State<_RememberMeControl> createState() => _RememberMeControlState();
}

class _RememberMeControlState extends State<_RememberMeControl> {
  bool _focused = false;

  void _toggle() => widget.onChanged(!widget.value);

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Lembre-se de mim',
    checked: widget.value,
    child: FocusableActionDetector(
      key: const ValueKey('remember-me-control'),
      focusNode: widget.focusNode,
      mouseCursor: SystemMouseCursors.click,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _toggle();
            return null;
          },
        ),
      },
      onShowFocusHighlight: (focused) => setState(() => _focused = focused),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.focusNode.requestFocus();
          _toggle();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          padding: const EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: _focused
                ? Border.all(color: VH.foreground.withValues(alpha: .55))
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                key: const ValueKey('remember-me-marker'),
                width: 16,
                height: 15,
                child: DecoratedBox(
                  decoration: inset_shadow.BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: widget.value
                          ? const [VH.secondary, VH.secondary]
                          : [
                              Colors.white.withValues(alpha: .01),
                              VH.background.withValues(alpha: .01),
                            ],
                    ),
                    boxShadow: const [
                      inset_shadow.BoxShadow(
                        color: VetColors.shadowDark,
                        offset: Offset(2, 2),
                        blurRadius: 2,
                        inset: true,
                      ),
                    ],
                  ),
                  child: widget.value
                      ? const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lembre-se de mim',
                    maxLines: 1,
                    style: TextStyle(fontSize: 8, color: VetColors.brown),
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
