import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_data_manager.dart';
import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets/auth/demo_mode_notice.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode(debugLabel: 'Senha');
  final _rememberFocusNode = FocusNode(debugLabel: 'Lembre-se de mim');

  bool esconderSenha = true;
  bool lembrarDeMim = false;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
  }

  Future<void> _restoreRememberedEmail() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final email = preferences.getString(LocalDataManager.rememberedEmailKey);
      if (!mounted ||
          email == null ||
          email.trim().isEmpty ||
          _emailController.text.isNotEmpty) {
        return;
      }
      setState(() {
        _emailController.text = email;
        lembrarDeMim = true;
      });
    } catch (_) {
      // Login continua disponível se a preferência opcional não puder ser lida.
    }
  }

  Future<bool> _saveRememberedEmail({
    required String email,
    required bool remember,
  }) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!remember) {
        return await preferences.remove(LocalDataManager.rememberedEmailKey);
      }
      return await preferences.setString(
        LocalDataManager.rememberedEmailKey,
        email,
      );
    } catch (_) {
      return false;
    }
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> entrar() async {
    if (_signingIn) return;
    if (!VetRepository.authenticate(
      _emailController.text,
      _passwordController.text,
    )) {
      final message =
          VetRepository.hasDifferentLocalClientEmail(_emailController.text)
          ? 'Este protótipo mantém um perfil local. Use o e-mail salvo neste dispositivo.'
          : 'Informe um e-mail válido e uma senha com 6 caracteres.';
      mostrarMensagem(message);
      return;
    }
    final email = _emailController.text.trim();
    final rememberEmail = lembrarDeMim;
    setState(() => _signingIn = true);
    final emailSaved = await _saveRememberedEmail(
      email: email,
      remember: rememberEmail,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pushReplacementNamed(context, '/home');
    if (!emailSaved) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível lembrar o usuário neste dispositivo.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _rememberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      // O Figma posiciona a arte a partir do topo do frame. O fundo rosa pode
      // continuar atrás da barra de status; controles de retorno ficam abaixo.
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          key: const ValueKey('login-surface'),
          constraints: const BoxConstraints(maxWidth: 390),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final s = (constraints.maxWidth / 390).clamp(.8, 1.0);
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final rememberControl = _RememberMeControl(
                value: lembrarDeMim,
                enabled: !_signingIn,
                focusNode: _rememberFocusNode,
                onChanged: (value) => setState(() => lembrarDeMim = value),
              );
              final forgotPassword = TextButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.only(left: 8),
                ),
                onPressed: _signingIn
                    ? null
                    : () => mostrarMensagem(
                        'A recuperação de senha ainda não está disponível nesta demonstração.',
                      ),
                child: const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(fontSize: 12, color: VetColors.brownOnRose),
                ),
              );
              final secondaryActions = textScale >= 1.4
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 258, child: rememberControl),
                        SizedBox(width: 258, child: forgotPassword),
                      ],
                    )
                  : SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          SizedBox(width: 130, child: rememberControl),
                          Expanded(child: forgotPassword),
                        ],
                      ),
                    );
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
                    Positioned(
                      left: 43.5 * s,
                      top: MediaQuery.viewPaddingOf(context).top + 8 * s,
                      width: 303 * s,
                      child: const DemoModeNotice(
                        compact: true,
                        message: 'Demonstração · use dados fictícios',
                        semanticLabel:
                            'Modo demonstração. Não há contas individuais. As informações ficam neste dispositivo; use apenas dados fictícios.',
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: 180 * s),
                        Transform.translate(
                          offset: Offset(-1 * s, 0),
                          child: Image.asset(
                            'assets/imagens/figma/vethomepng-2.png',
                            width: 166 * s,
                            height: 166 * s,
                            fit: BoxFit.contain,
                            semanticLabel: 'VetHome',
                          ),
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
                                enabled: !_signingIn,
                              ),
                              SizedBox(height: 17 * s),
                              _loginField(
                                'Senha',
                                _passwordController,
                                prefix: 'frame-7-5.png',
                                scale: s,
                                password: true,
                                enabled: !_signingIn,
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: Offset((258 - 242 * s) / 2, -17.5),
                          child: SizedBox(width: 258, child: secondaryActions),
                        ),
                        const SizedBox(height: 11),
                        SizedBox(
                          width: 303 * s,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _signingIn ? null : entrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VetColors.rose,
                              foregroundColor: VetColors.calendarTextOnRose,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: .25),
                              shape: const StadiumBorder(),
                            ),
                            icon: _signingIn
                                ? const ExcludeSemantics(
                                    child: SizedBox.square(
                                      dimension: 21,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.login,
                                    size: 21,
                                    color: Colors.white,
                                  ),
                            iconAlignment: IconAlignment.end,
                            label: Semantics(
                              liveRegion: _signingIn,
                              child: Text(
                                _signingIn ? 'Entrando…' : 'Entrar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: textScale >= 1.4
                              ? const Text(
                                  'Ou continue com',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: VetColors.brownOnRose,
                                  ),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: VH.foreground.withValues(
                                          alpha: .5,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 26,
                                      ),
                                      child: Text(
                                        'Ou continue com',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: VetColors.brownOnRose,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: VH.foreground.withValues(
                                          alpha: .5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 22),
                        Transform.translate(
                          offset: const Offset(0, -2),
                          child: Row(
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
                                          'A autenticação com ${social.$1} não está disponível nesta demonstração.',
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
                        ),
                        const SizedBox(height: 27),
                        const Text(
                          'Ainda não possui uma conta?',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: VetColors.brownOnRose,
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
                              color: VetColors.brownOnRose,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    if (Navigator.of(context).canPop())
                      Positioned(
                        top: MediaQuery.viewPaddingOf(context).top + 4,
                        left: 8,
                        child: IconButton(
                          tooltip: 'Voltar',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back),
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

  double _loginFieldHeight(BuildContext context) {
    final scaledFontSize = MediaQuery.textScalerOf(context).scale(15);
    // Mantém os 48 px exatos do Figma na escala 1. Acima disso,
    // reserva espaço para a linha ampliada sem recortá-la.
    return 48 + (scaledFontSize - 15).clamp(0.0, double.infinity) * 2.3;
  }

  Widget _loginField(
    String label,
    TextEditingController controller, {
    required String prefix,
    required double scale,
    bool password = false,
    bool enabled = true,
  }) => SizedBox(
    width: 242 * scale,
    height: _loginFieldHeight(context),
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
        enabled: enabled,
        controller: controller,
        focusNode: password ? _passwordFocusNode : null,
        obscureText: password && esconderSenha,
        keyboardType: password
            ? TextInputType.text
            : TextInputType.emailAddress,
        textInputAction: password ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (_) {
          if (password) {
            entrar();
          } else {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          }
        },
        style: const TextStyle(
          fontFamily: VH.bodyFontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: VH.foreground,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            fontFamily: VH.bodyFontFamily,
            color: VH.foreground,
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
                  tooltip: esconderSenha ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: enabled
                      ? () => setState(() => esconderSenha = !esconderSenha)
                      : null,
                  icon: Icon(
                    esconderSenha
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: VH.foreground,
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
    required this.enabled,
    required this.focusNode,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final FocusNode focusNode;
  final ValueChanged<bool> onChanged;

  @override
  State<_RememberMeControl> createState() => _RememberMeControlState();
}

class _RememberMeControlState extends State<_RememberMeControl> {
  bool _focused = false;

  void _toggle() {
    if (widget.enabled) widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Lembre-se de mim',
    checked: widget.value,
    enabled: widget.enabled,
    excludeSemantics: true,
    onTap: widget.enabled ? _toggle : null,
    child: FocusableActionDetector(
      key: const ValueKey('remember-me-control'),
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      mouseCursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
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
        onTap: widget.enabled
            ? () {
                widget.focusNode.requestFocus();
                _toggle();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.only(left: 5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          child: Row(
            children: [
              SizedBox(
                key: const ValueKey('remember-me-marker'),
                width: 16,
                height: 15,
                child: DecoratedBox(
                  decoration: inset_shadow.BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: _focused
                        ? Border.all(
                            color: VH.foreground.withValues(alpha: .85),
                            width: 1.5,
                          )
                        : null,
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
                child: Text(
                  'Lembre-se de mim',
                  style: TextStyle(fontSize: 12, color: VetColors.brown),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
