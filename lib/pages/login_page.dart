import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_vethome/pages/informacoes_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

=======

import '../data/vet_repository.dart';
import '../theme.dart';
import '../theme/vet_colors.dart';
import 'teste_page.dart';

>>>>>>> origin/kelvin
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
<<<<<<< HEAD
  }

  void abrirInformacoesCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InformacoesCadastroPage()),
    );
=======
    Navigator.pushReplacementNamed(context, '/pets');
>>>>>>> origin/kelvin
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: compacto ? 18 : 24),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        SizedBox(height: espacamentoInicial),
                        SizedBox(
                          width: double.infinity,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Transform.translate(
                                  offset: Offset(0, deslocamentoForma),
                                  child: CustomPaint(
                                    painter: FormaLoginPainter(),
                                  ),
                                ),
                              ),

                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: compacto ? 200 : 300,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          top: 0,
                                          child: _pata(compacto ? 0.65 : 1.1),
                                        ),
                                        Positioned(
                                          bottom: 1,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Image.asset(
                                              'assets/imagens/VetHome_logo_1.jpg',
                                              width: tamanhoLogo,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: compacto ? 2 : 26),

                                  Center(
                                    child: SizedBox(
                                      width: larguraCampos,
                                      height: alturacampos,
                                      child: Container(
                                        decoration:
                                            const inset_shadow.BoxDecoration(
                                              color: Color.fromRGBO(
                                                192,
                                                128,
                                                129,
                                                0.15,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(80),
                                              ),
                                              boxShadow: [
                                                inset_shadow.BoxShadow(
                                                  color: Color.fromARGB(
                                                    60,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 3),
                                                  inset: true,
                                                ),
                                              ],
                                            ),
                                        child: TextField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style:
                                              GoogleFonts.montserratAlternates(
                                                fontWeight: FontWeight.w500,
                                                fontSize: compacto ? 14 : 16,
                                              ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            hintText: 'Usuario',
                                            hintStyle:
                                                GoogleFonts.montserratAlternates(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: compacto ? 14 : 16,
                                                ),

                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: compacto ? 10 : 20,
                                                  horizontal: 18,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              borderSide: const BorderSide(
                                                width: 1.5,
                                                color: Color(0xFF68442E),
                                              ),
                                            ),
                                            prefixIcon: Container(
                                              margin: const EdgeInsets.only(
                                                left: 1,
                                                right: 8,
                                              ),
                                              width: compacto ? 17 : 54,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFAD3D5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: Color(0xFF68442E),
                                                size: compacto ? 25 : 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: espacamentoCampos),

                                  Center(
                                    child: SizedBox(
                                      width: larguraCampos,
                                      height: alturacampos,
                                      child: Container(
                                        decoration:
                                            const inset_shadow.BoxDecoration(
                                              color: Color.fromRGBO(
                                                192,
                                                128,
                                                129,
                                                0.15,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(80),
                                              ),
                                              boxShadow: [
                                                inset_shadow.BoxShadow(
                                                  color: Color.fromARGB(
                                                    60,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                  inset: true,
                                                ),
                                              ],
                                            ),
                                        child: TextField(
                                          controller: _senhaController,
                                          obscureText: esconderSenha,
                                          style:
                                              GoogleFonts.montserratAlternates(
                                                fontWeight: FontWeight.w500,
                                                fontSize: compacto ? 14 : 16,
                                              ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            hintText: 'Senha',
                                            hintStyle:
                                                GoogleFonts.montserratAlternates(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: compacto ? 14 : 16,
                                                ),

                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: compacto ? 12 : 20,
                                                  horizontal: 18,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              borderSide: const BorderSide(
                                                width: 1.5,
                                                color: Color(0xFF68442E),
                                              ),
                                            ),
                                            prefixIcon: Container(
                                              margin: const EdgeInsets.only(
                                                left: 1,
                                                right: 8,
                                              ),
                                              width: compacto ? 17 : 54,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFAD3D5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.lock,
                                                color: Color(0xFF68442E),
                                                size: compacto ? 25 : 40,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  esconderSenha =
                                                      !esconderSenha;
                                                });
                                              },
                                              color: const Color(0xFF68442E),
                                              icon: Icon(
                                                esconderSenha
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              tooltip: esconderSenha
                                                  ? 'Mostrar senha'
                                                  : 'Ocultar senha',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: SizedBox(
                                      width: compacto ? 250 : 300,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 28,
                                                height: 28,
                                                child: Transform.scale(
                                                  scale: 0.75,
                                                  child: Checkbox(
                                                    value: lembrarDeMim,
                                                    onChanged: (selecionado) {
                                                      setState(() {
                                                        lembrarDeMim =
                                                            selecionado ??
                                                            false;
                                                      });
                                                    },
                                                    shape: const CircleBorder(),
                                                    activeColor: const Color(
                                                      0xFF68442E,
                                                    ),
                                                    checkColor: Colors.white,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                'Lembre de mim',
                                                style:
                                                    GoogleFonts.montserratAlternates(
                                                      color: const Color(
                                                        0xFF68442E,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 8,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.all(11),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              'Esqueceu a senha?',
                                              style:
                                                  GoogleFonts.montserratAlternates(
                                                    color: const Color(
                                                      0xFF68442E,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 8,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
=======
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
>>>>>>> origin/kelvin
                              ),
                            ],
                          ),
                        ),
<<<<<<< HEAD

                        SizedBox(height: compacto ? 40 : 50),

                        Center(
                          child: Container(
                            width: larguraBotao,
                            height: alturaBotao,
                            decoration: const inset_shadow.BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(80),
                              ),
                              boxShadow: [
                                inset_shadow.BoxShadow(
                                  color: Color.fromARGB(150, 105, 66, 67),
                                  blurRadius: 2,
                                  offset: Offset(1, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                TextButton(
                                  onPressed: entrar,
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFC08081),
                                    foregroundColor: const Color(0xFF68442E),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Entrar',
                                        style: GoogleFonts.montserratAlternates(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: fonteBotao,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Icon(
                                          Icons.login,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: compacto ? 40 : 30),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color: const Color(0xFF68442E),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'Ou continue com',
                                style: GoogleFonts.montserratAlternates(
                                  color: const Color(0xFF68442E),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color: const Color(0xFF68442E),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _botaoRedeSocial(
                              imagem: 'assets/imagens/google_logo.png',
                              onPressed: () {},
                            ),

                            const SizedBox(width: 20),

                            _botaoRedeSocial(
                              imagem: 'assets/imagens/facebook_logo.png',
                              onPressed: () {},
                            ),

                            const SizedBox(width: 20),

                            _botaoRedeSocial(
                              imagem: 'assets/imagens/instagram_logo.png',
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ainda não possui uma conta? ',
                              style: GoogleFonts.montserratAlternates(
                                color: const Color(0xFF68442E),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: abrirInformacoesCadastro,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'CADASTRE-SE',
                                style: GoogleFonts.montserratAlternates(
                                  color: const Color(0xFFC08081),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _botaoRedeSocial({
    required String imagem,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAD3D5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(100, 105, 66, 67),
              blurRadius: 1,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: BorderSide.none,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(10),
          ),
          child: Image.asset(imagem, fit: BoxFit.contain, width: 100),
        ),
      ),
    );
  }

  Widget _almofada({
    required double largura,
    required double altura,
    required double rotacao,
  }) {
    return Transform.rotate(
      angle: rotacao,
      child: Container(
        width: largura,
        height: altura,
        decoration: const BoxDecoration(
          color: Color(0xFFC08081),
          borderRadius: BorderRadius.all(Radius.circular(50)),
          boxShadow: [
            // sombra projetada
            BoxShadow(
              color: Color.fromARGB(80, 105, 66, 67),
              blurRadius: 10,
              offset: Offset(5, 7),
            ),

            // brilho
            BoxShadow(
              color: Color.fromARGB(100, 255, 255, 255),
              blurRadius: 5,
              offset: Offset(-4, -4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _almofadaComContorno({
    required double largura,
    required double altura,
    required double rotacao,
  }) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(
          angle: rotacao,
          child: Container(
            width: largura + 18,
            height: altura + 18,
            decoration: BoxDecoration(
              color: const Color(0xFFFAD3D5),
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                inset_shadow.BoxShadow(
                  color: Color.fromARGB(190, 75, 42, 43),
                  blurRadius: 6,
                  offset: Offset(-4, -1),
                  inset: true,
                ),
              ],
            ),
          ),
        ),
        _almofada(largura: largura, altura: altura, rotacao: rotacao),
      ],
    );
  }

  Widget _pata(double escala) {
    return SizedBox(
      width: 370 * escala,
      height: 100 * escala,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Dedo superior esquerdo
          Positioned(
            top: -30 * escala,
            left: 65 * escala,
            child: _almofadaComContorno(
              largura: 58 * escala,
              altura: 85 * escala,
              rotacao: -0.25,
            ),
          ),

          // Dedo superior direito
          Positioned(
            top: -30 * escala,
            right: 65 * escala,
            child: _almofadaComContorno(
              largura: 58 * escala,
              altura: 85 * escala,
              rotacao: 0.25,
            ),
          ),

          // Dedo inferior esquerdo
          Positioned(
            top: 90 * escala,
            left: -70 * escala,
            child: _almofadaComContorno(
              largura: 58 * escala,
              altura: 85 * escala,
              rotacao: -0.45,
            ),
          ),

          // Dedo inferior direito
          Positioned(
            top: 90 * escala,
            right: -70 * escala,
            child: _almofadaComContorno(
              largura: 58 * escala,
              altura: 85 * escala,
              rotacao: 0.45,
            ),
          ),
        ],
      ),
    );
  }
}

class FormaLoginPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Começa mais abaixo, com uma pequena curva arredondada entre as almofadas
    path.moveTo(size.width * 0.50, size.height * 0.12);

    // Curva superior esquerda
    path.cubicTo(
      size.width * 0.45,
      size.height * 0.12,
      size.width * 0.36,
      size.height * 0.12,
      size.width * 0.28,
      size.height * 0.24,
    );

    // Descida pelo lado esquerdo
    path.cubicTo(
      size.width * 0.20,
      size.height * 0.38,
      size.width * 0.20,
      size.height * 0.40,
      size.width * 0.07,
      size.height * 0.62,
    );

    // Curva inferior esquerda
    path.cubicTo(
      size.width * 0.01,
      size.height * 0.72,
      size.width * 0.02,
      size.height * 0.95,
      size.width * 0.20,
      size.height * 0.98,
    );

    // Parte inferior
    path.cubicTo(
      size.width * 0.40,
      size.height * 1.00,
      size.width * 0.80,
      size.height * 1.00,
      size.width * 0.86,
      size.height * 0.96,
    );

    // Curva inferior direita
    path.cubicTo(
      size.width * 0.92,
      size.height * 0.93,
      size.width * 1.03,
      size.height * 0.88,
      size.width * 0.97,
      size.height * 0.65,
    );

    // Subida pelo lado direito
    path.cubicTo(
      size.width * 0.89,
      size.height * 0.50,
      size.width * 0.80,
      size.height * 0.37,
      size.width * 0.73,
      size.height * 0.26,
    );

    // Curva superior direita
    path.cubicTo(
      size.width * 0.63,
      size.height * 0.12,
      size.width * 0.57,
      size.height * 0.12,
      size.width * 0.50,
      size.height * 0.12,
    );

    path.close();

    // Sombra externa
    final sombra = Paint()
      ..color = const Color.fromARGB(55, 105, 66, 67)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawPath(path.shift(const Offset(0, 5)), sombra);

    // Fundo da forma
    final fundo = Paint()
      ..color = const Color(0xFFFAD3D5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fundo);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
=======
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
>>>>>>> origin/kelvin
