import 'package:flutter/material.dart';
import 'package:flutter_vethome/pages/Informacoes_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool esconderSenha = true;
  bool lembrarDeMim = false;

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void entrar() {
    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha o e-mail e a senha.');
      return;
    }
  }

  void abrirInformacoesCadastro(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InformacoesCadastroPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAD3D5),
        foregroundColor: const Color(0xFF68442E),
        title: Text(
          'Login',
          style: GoogleFonts.comfortaa(
            color: const Color(0xFF68442E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            final double espacamentoInicial = compacto ? 25.0 : 100.0;
            final double tamanhoLogo = compacto ? 125.0 : 130.0;
            final double espacamentoCampos = compacto ? 10.0 : 20.0;
            final double alturaBotao = compacto ? 56.0 : 70.0;
            final double larguraBotao = compacto ? 250.0 : 400.0;
            final double fonteBotao = compacto ? 15.0 : 18.0;
            final double deslocamentoForma = compacto ? 25.0 : 24.0;
            final double alturacampos = compacto ? 40.0 : 60.0;
            final double larguraCampos = compacto ? 220.0 : 270.0;

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
                                              child: _pata(compacto ? 0.65 : 1.1
                                              ),
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
                                            decoration: const inset_shadow.BoxDecoration(
                                              color: Color.fromRGBO(192, 128, 129, 0.15),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(80),
                                              ),
                                              boxShadow: [
                                                inset_shadow.BoxShadow(
                                                  color: Color.fromARGB(60, 0, 0, 0),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 3),
                                                  inset: true,
                                                ),
                                              ],
                                            ),
                                            child: TextField(
                                              controller: _emailController,
                                              keyboardType: TextInputType.emailAddress,
                                              style: GoogleFonts.montserratAlternates(
                                                fontWeight: FontWeight.w500,
                                                fontSize: compacto ? 14 : 16,
                                              ),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.transparent,
                                                hintText: 'Usuario',
                                                hintStyle: GoogleFonts.montserratAlternates(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: compacto ? 14 : 16,
                                                ),

                                                contentPadding: EdgeInsets.symmetric(
                                                  vertical: compacto ? 10 : 20,
                                                  horizontal: 18,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(80),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(80),
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
                                            decoration: const inset_shadow.BoxDecoration(
                                              color: Color.fromRGBO(192, 128, 129, 0.15),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(80),
                                              ),
                                              boxShadow: [
                                                inset_shadow.BoxShadow(
                                                  color: Color.fromARGB(60, 0, 0, 0),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                  inset: true,
                                                ),
                                              ],
                                            ),
                                            child: TextField(
                                              controller: _senhaController,
                                              obscureText: esconderSenha,
                                              style: GoogleFonts.montserratAlternates(
                                                fontWeight: FontWeight.w500,
                                                fontSize: compacto ? 14 : 16,
                                              ),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.transparent,
                                                hintText: 'Senha',
                                                hintStyle: GoogleFonts.montserratAlternates(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: compacto ? 14 : 16,
                                                ),

                                                contentPadding: EdgeInsets.symmetric(
                                                  vertical: compacto ? 12 : 20,
                                                  horizontal: 18,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(80),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(80),
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
                                                      esconderSenha = !esconderSenha;
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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                selecionado ?? false;
                                                          });
                                                        },
                                                        shape: const CircleBorder(),
                                                        activeColor: const Color(0xFF68442E),
                                                        checkColor: Colors.white,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize.shrinkWrap,
                                                        visualDensity: VisualDensity.compact,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    'Lembre de mim',
                                                    style: GoogleFonts.montserratAlternates(
                                                      color: const Color(0xFF68442E),
                                                      fontWeight: FontWeight.w500,
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
                                                      MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: Text(
                                                  'Esqueceu a senha?',
                                                  style: GoogleFonts.montserratAlternates(
                                                    color: const Color(0xFF68442E),
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
                            ),
                          ],
                        ),  
                      ),

                      
                      SizedBox(height: compacto ? 35 : 50),

                      Center(
                        
                        child: Container(
                          width: larguraBotao,
                          height: alturaBotao,
                          decoration: const inset_shadow.BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(80)),
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
                              height: 1,
                              color: Colors.black26,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Ou continue com',
                              style: GoogleFonts.montserratAlternates(
                                color: const Color(0xFF68442E),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.black26,
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
                            onPressed: () {}
                          ),

                          const SizedBox(width: 20,),

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
                      const SizedBox(height: 25,),
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
                      )


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
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFAD3D5),
          side: const BorderSide(
            color: Colors.black26,
            width: 1,
          ),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(10),
        ),
        child: Image.asset(
          imagem,
          fit: BoxFit.contain,
          width: 100,
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
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
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
        _almofada(
          largura: largura,
          altura: altura,
          rotacao: rotacao,
        ),
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
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12,
      );

    canvas.drawPath(
      path.shift(const Offset(0, 5)),
      sombra,
    );

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