import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'cadastro_page.dart';

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

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroPage()),
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
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            final double espacamentoInicial = compacto ? 80.0 : 100.0;
            final double tamanhoLogo = compacto ? 92.0 : 130.0;
            final double espacamentoCampos = compacto ? 12.0 : 20.0;
            final double alturaBotao = compacto ? 56.0 : 70.0;
            final double fonteBotao = compacto ? 15.0 : 18.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: compacto ? 16 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: espacamentoInicial),

                      SizedBox(
                        width: double.infinity,
                        
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 74),
                            Center(
                              child: Container(
                                width: tamanhoLogo,
                                height: tamanhoLogo,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  'assets/imagens/VetHome_logo_1.jpg',
                                  width: tamanhoLogo,
                                  height: tamanhoLogo,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            SizedBox(height: compacto ? 14 : 26),

                      Center(
                        child: SizedBox(
                          width: compacto ? 220 : 270,
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
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                hintText: 'Usuario',
                                hintStyle: GoogleFonts.montserratAlternates(
                                  fontWeight: FontWeight.w500,
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
                                    left: 5,
                                    right: 8,
                                  ),
                                  width: compacto ? 42 : 54,
                                  height: compacto ? 42 : 54,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFAD3D5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF68442E),
                                    size: compacto ? 30 : 40,
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
                          width: compacto ? 220 : 270,
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
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                hintText: 'Senha',
                                hintStyle: GoogleFonts.montserratAlternates(
                                  fontWeight: FontWeight.w500,
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
                                    left: 5,
                                    right: 8,
                                  ),
                                  width: compacto ? 42 : 54,
                                  height: compacto ? 42 : 54,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFAD3D5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.lock,
                                    color: Color(0xFF68442E),
                                    size: compacto ? 30 : 40,
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
                                        Checkbox(
                                          value: lembrarDeMim,
                                          onChanged: (selecionado) {
                                            setState(() {
                                              lembrarDeMim = selecionado ?? false;
                                            });
                                          },
                                          shape: const CircleBorder(),
                                          activeColor: const Color(0xFF68442E),
                                          checkColor: Colors.white,
                                        ),
                                        Text(
                                          'Lembre de mim',
                                          style: GoogleFonts.montserratAlternates(
                                            color: const Color(0xFF68442E),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.all(17),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Esqueceu a senha?',
                                        style: GoogleFonts.montserratAlternates(
                                          color: const Color(0xFF68442E),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          ),
                        
                      ),

                      SizedBox(height: compacto ? 30 : 40),

                      Center(
                        
                        child: Container(
                          width: 200,
                          height: alturaBotao,
                          decoration: const inset_shadow.BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(80)),
                            boxShadow: [
                              inset_shadow.BoxShadow(
                                color: Color.fromARGB(150, 105, 66, 67),
                                blurRadius: 8,
                                offset: Offset(4, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              TextButton(
                                onPressed: entrar,
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFFAD3D5),
                                  foregroundColor: const Color(0xFFFAD3D5),
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
                                        color: const Color(0xFF68442E),
                                        fontSize: fonteBotao,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(
                                        Icons.login,
                                        color: Color(0xFF68442E),
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0.7,
                                left: 21,
                                right: 30,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 1,
                                left: 25,
                                right: 20,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      

                      SizedBox(height: compacto ? 8 : 10),

                      Center(
                        child: Container(
                          width: 130,
                          height: alturaBotao,
                          decoration: const inset_shadow.BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(80)),
                            boxShadow: [
                              inset_shadow.BoxShadow(
                                color: Color.fromARGB(150, 105, 66, 67),
                                blurRadius: 8,
                                offset: Offset(4, 5),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: abrirCadastro,
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFC08081),
                              foregroundColor: const Color(0xFF68442E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80),
                              ),
                            ),
                            child: Text(
                              'Cadastrar',
                              style: GoogleFonts.montserratAlternates(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: fonteBotao,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}