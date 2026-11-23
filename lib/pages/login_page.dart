import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_data_manager.dart';
import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import '../widgets/auth/demo_mode_notice.dart';
import '../widgets/auth/registration_actions_footer.dart';

const _loginActionTextStyle = TextStyle(
  fontFamily: VH.bodyFontFamily,
  fontSize: 8,
  fontWeight: FontWeight.w400,
  height: 1.25,
  color: VetColors.brown,
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.successRoute = '/pets'})
    : _veterinarianDemo = false;

  const LoginPage.veterinarianDemo({super.key})
    : successRoute = '/gabriela',
      _veterinarianDemo = true;

  final String successRoute;
  final bool _veterinarianDemo;

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
  bool _changedLoginDraft = false;

  @override
  void initState() {
    super.initState();
    if (!widget._veterinarianDemo) _restoreRememberedEmail();
  }

  Future<void> _restoreRememberedEmail() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      // SharedPreferences altera o cache antes de confirmar a gravação.
      // Use o valor persistido ao abrir outro Login após uma falha.
      await preferences.reload();
      final email = preferences.getString(LocalDataManager.rememberedEmailKey);
      if (!mounted ||
          _changedLoginDraft ||
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

  ScaffoldMessengerState _clearMessages() {
    final messenger = ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..removeCurrentSnackBar();
    return messenger;
  }

  void mostrarMensagem(String mensagem) {
    _clearMessages().showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> entrar() async {
    if (_signingIn) return;
    if (widget._veterinarianDemo) {
      Navigator.pushReplacementNamed(context, widget.successRoute);
      return;
    }
    if (!VetRepository.authenticate(
      _emailController.text,
      _passwordController.text,
    )) {
      final message =
          VetRepository.hasDifferentLocalClientEmail(_emailController.text)
          ? 'Este protótipo mantém um perfil local. Use o e-mail salvo neste dispositivo.'
          : 'Informe um e-mail válido e uma senha com pelo menos 6 caracteres.';
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
    if (ModalRoute.isCurrentOf(context) != true) {
      setState(() => _signingIn = false);
      return;
    }
    final messenger = _clearMessages();
    Navigator.pushReplacementNamed(context, widget.successRoute);
    if (!emailSaved) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            rememberEmail
                ? 'Não foi possível lembrar o usuário neste dispositivo.'
                : 'Não foi possível esquecer o e-mail neste dispositivo.',
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
              final textScaler = MediaQuery.textScalerOf(context);
              final enlarged = textScaler.scale(12) >= 16.8;
              final stackActions = enlarged || constraints.maxWidth < 300;
              final actionsWidth = math.min(258.0, constraints.maxWidth - 24);
              final actionsLeft = math.min(
                (constraints.maxWidth - 242 * s) / 2,
                constraints.maxWidth - actionsWidth - 12,
              );
              final actionsOffset =
                  actionsLeft - (constraints.maxWidth - actionsWidth) / 2;
              final rememberControl = _RememberMeControl(
                value: lembrarDeMim,
                enabled: !_signingIn,
                focusNode: _rememberFocusNode,
                onToggle: () {
                  if (_signingIn) return;
                  setState(() {
                    _changedLoginDraft = true;
                    lembrarDeMim = !lembrarDeMim;
                  });
                },
              );
              final forgotPassword = TextButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.only(left: 8, bottom: 9),
                ),
                onPressed: _signingIn
                    ? null
                    : () => mostrarMensagem(
                        'A recuperação de senha ainda não está disponível nesta demonstração.',
                      ),
                child: Text(
                  'Esqueceu sua senha?',
                  style: _loginActionTextStyle.copyWith(
                    color: VetColors.brownSecondary,
                  ),
                ),
              );
              final secondaryActions = stackActions
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [rememberControl, forgotPassword],
                    )
                  : SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          SizedBox(width: 148, child: rememberControl),
                          Expanded(child: forgotPassword),
                        ],
                      ),
                    );
              final submitHeight = math.max(
                widget._veterinarianDemo && enlarged ? 76.0 : 54.0,
                textScaler.scale(14) + 24,
              );
              final submit = _submitButton(303 * s, submitHeight, enlarged);
              final submitBottom =
                  363 * s +
                  2 * _loginFieldHeight(context) +
                  (stackActions ? 96 : 48) +
                  11 +
                  submitHeight;
              final pinSubmit =
                  constraints.maxHeight >= submitHeight + 68 &&
                  constraints.maxHeight < submitBottom + 8;
              final availableArtScale = math.min(s, constraints.maxWidth / 390);
              // Em janelas baixas, ganhe espaço na arte antes de exigir rolagem.
              // Campos e botões continuam com suas áreas de toque.
              final artSpace = pinSubmit
                  ? constraints.maxHeight / 720
                  : s + (constraints.maxHeight - submitBottom - 220) / 346;
              final artScale = math.min(
                availableArtScale,
                math.max(.42, artSpace),
              );
              final artLeft = (constraints.maxWidth - 390 * artScale) / 2;
              final noticeTop = MediaQuery.viewPaddingOf(context).top + 8 * s;
              final canGoBack = Navigator.of(context).canPop();
              final reserveBackSpace =
                  canGoBack && (constraints.maxWidth - 303 * s) / 2 < 40;
              final socialSpacing = ((constraints.maxWidth - 192) / 2).clamp(
                8.0,
                37.5,
              );
              final content = SingleChildScrollView(
                child: Stack(
                  children: [
                    // Assets exportados do Figma; a almofada ultrapassa o frame.
                    Positioned(
                      left: artLeft + 10.25 * artScale,
                      top: 190 * artScale,
                      width: 369.5 * artScale,
                      height: 311.5 * artScale,
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
                        left: artLeft + pad.$2 * artScale,
                        top: pad.$3 * artScale,
                        width: pad.$4 * artScale,
                        height: pad.$5 * artScale,
                        child: Image.asset(
                          'assets/imagens/figma/${pad.$1}',
                          excludeFromSemantics: true,
                        ),
                      ),
                    Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 180 * artScale,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: reserveBackSpace ? 56 : 8,
                              top: noticeTop,
                              right: kDebugMode ? 64 : 8,
                              bottom: 12,
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: 1,
                              child: SizedBox(
                                width: 303 * s,
                                child: DemoModeNotice(
                                  compact: true,
                                  multiline:
                                      kDebugMode ||
                                      stackActions ||
                                      reserveBackSpace,
                                  message: widget._veterinarianDemo
                                      ? 'Demonstração local'
                                      : 'Demonstração · use dados fictícios',
                                  semanticLabel: widget._veterinarianDemo
                                      ? 'Área veterinária em demonstração. Acesso local sem credenciais.'
                                      : 'Modo demonstração. Não há contas individuais. As informações ficam neste dispositivo; use apenas dados fictícios.',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(-1 * artScale, 0),
                          child: Image.asset(
                            'assets/imagens/figma/splash-start-logo.png',
                            width: 166 * artScale,
                            height: 166 * artScale,
                            fit: BoxFit.contain,
                            semanticLabel: 'VetHome',
                          ),
                        ),
                        if (widget._veterinarianDemo)
                          SizedBox(
                            height: 161 * s,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Semantics(
                                  header: true,
                                  child: const Text(
                                    'Área veterinária',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: VH.headingFontFamily,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: VetColors.brownOnRose,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else ...[
                          // O primeiro campo começa em 333 no frame de referência.
                          Transform.translate(
                            offset: Offset(0, -13 * s),
                            child: FocusTraversalGroup(
                              policy: WidgetOrderTraversalPolicy(),
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
                          ),
                          Transform.translate(
                            // A faixa de toque começa onde termina o campo Senha.
                            offset: Offset(actionsOffset, -13 * s),
                            child: SizedBox(
                              width: actionsWidth,
                              child: secondaryActions,
                            ),
                          ),
                        ],
                        const SizedBox(height: 11),
                        if (!pinSubmit) submit,
                        if (!widget._veterinarianDemo) ...[
                          const SizedBox(height: 28),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: enlarged || constraints.maxWidth < 300
                                ? const Text(
                                    'Ou continue com',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: VetColors.brownSecondary,
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
                                            color: VetColors.brownSecondary,
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
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: socialSpacing,
                              runSpacing: 12,
                              children: [
                                for (final social in const [
                                  ('Google', 'icons8-google-logo-96-1.png'),
                                  ('Facebook', 'icons8-facebook-novo-96-1.png'),
                                  ('Instagram', 'icons8-instagram-96-1.png'),
                                ])
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
                                          onPressed: _signingIn
                                              ? null
                                              : () => mostrarMensagem(
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
                            ),
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
                            onPressed: _signingIn
                                ? null
                                : () {
                                    _clearMessages();
                                    Navigator.pushNamed(context, '/cadastro');
                                  },
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
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                    if (canGoBack)
                      Positioned(
                        top: MediaQuery.viewPaddingOf(context).top + 4,
                        left: 8,
                        child: IconButton(
                          tooltip: 'Voltar',
                          onPressed: _signingIn
                              ? null
                              : () {
                                  _clearMessages();
                                  Navigator.maybePop(context);
                                },
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                  ],
                ),
              );
              return Column(
                children: [
                  Expanded(child: content),
                  if (pinSubmit)
                    RegistrationActionsFooter(
                      key: const ValueKey('login-fixed-submit'),
                      child: Center(child: submit),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _submitButton(double width, double height, bool enlarged) {
    final label = Semantics(
      liveRegion: _signingIn,
      child: Text(
        _signingIn
            ? 'Entrando…'
            : widget._veterinarianDemo
            ? 'Entrar na demonstração'
            : 'Entrar',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
    final icon = _signingIn
        ? const ExcludeSemantics(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: VetColors.brown,
              ),
            ),
          )
        : SvgPicture.asset(
            'assets/imagens/figma/login-enter.svg',
            key: const ValueKey('login-enter-icon'),
            width: 21,
            height: 20,
            excludeFromSemantics: true,
          );

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          shadows: _signingIn
              ? null
              : const [
                  BoxShadow(
                    color: VetColors.shadowDark,
                    offset: Offset(2, 2),
                    blurRadius: 2,
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _signingIn ? null : entrar,
          style: ElevatedButton.styleFrom(
            backgroundColor: VetColors.brown,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const StadiumBorder(),
            padding: EdgeInsets.zero,
          ),
          child: enlarged || _signingIn || widget._veterinarianDemo
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: label),
                    const SizedBox(width: 8),
                    icon,
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Center(child: label),
                    Align(
                      alignment: Alignment(84 / (width - 21), 0),
                      child: icon,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

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
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, field) => Semantics(
          // Em um campo vazio o próprio hint já fornece o nome.
          label: value.text.isEmpty ? null : label,
          child: field,
        ),
        child: TextField(
          enabled: enabled,
          controller: controller,
          focusNode: password ? _passwordFocusNode : null,
          obscureText: password && esconderSenha,
          keyboardType: password
              ? TextInputType.text
              : TextInputType.emailAddress,
          textInputAction: password
              ? TextInputAction.done
              : TextInputAction.next,
          onChanged: password ? null : (_) => _changedLoginDraft = true,
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
    ),
  );
}

class _RememberMeControl extends StatefulWidget {
  const _RememberMeControl({
    required this.value,
    required this.enabled,
    required this.focusNode,
    required this.onToggle,
  });

  final bool value;
  final bool enabled;
  final FocusNode focusNode;
  final VoidCallback onToggle;

  @override
  State<_RememberMeControl> createState() => _RememberMeControlState();
}

class _RememberMeControlState extends State<_RememberMeControl> {
  bool _focused = false;

  void _toggle() {
    if (widget.enabled) widget.onToggle();
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
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          // Alinha o marcador ao y=458 do Figma dentro do alvo de 48 px.
          padding: const EdgeInsets.only(left: 5, bottom: 9),
          child: Row(
            children: [
              SizedBox(
                key: const ValueKey('remember-me-marker'),
                width: 16,
                height: 15,
                child: DecoratedBox(
                  decoration: inset_shadow.BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: _focused
                        ? VetColors.brown
                        : widget.value
                        ? VH.secondary
                        : null,
                    gradient: widget.value || _focused
                        ? null
                        : LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
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
                child: Text('Lembre-se de mim', style: _loginActionTextStyle),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
