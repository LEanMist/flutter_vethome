import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool esconderSenha = true;
  bool lembrarDeMim = false;

  void mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem)
      ),
    );
  }

  void entrar(){
    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    if(email.isEmpty || senha.isEmpty){
      mostrarMensagem(
        'Preencha o e-mail e a senha.',
      );
      return;
    }
  }
  
  @override
  Widget build(BuildContext context){
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
            fontSize: 35,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 150,),

            Center(
              child: Container(
                width: 180,
                height: 180,
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
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 60),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  decoration: const inset_shadow.BoxDecoration(
                    color: Color.fromRGBO(192, 128, 129, 0.15),
                    borderRadius: BorderRadius.all(Radius.circular(80)),
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

                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
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
                        margin: const EdgeInsets.only(left: 5, right: 8),
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAD3D5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF68442E),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ),

            const SizedBox(height: 20),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  decoration: const inset_shadow.BoxDecoration(
                    color: Color.fromRGBO(192, 128, 129, 0.15),
                    borderRadius: BorderRadius.all(Radius.circular(80)),
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

                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
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
                        margin: const EdgeInsets.only(left: 5, right: 8),
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAD3D5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Color(0xFF68442E),
                          size: 40,
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
                          esconderSenha ? Icons.visibility : Icons.visibility_off,
                        ),
                        tooltip: esconderSenha ? 'Mostrar senha' : 'Ocultar senha',
                      ),
                    ),
                  ),
                ),
              )
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
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
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      mostrarMensagem('Recuperação de senha');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Esqueceu a senha?',
                      style: GoogleFonts.montserratAlternates(
                        color: const Color(0xFF68442E),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30,),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.23,
                height: 70,
                child: TextButton(
                  onPressed: entrar,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFAD3D5),
                    foregroundColor: const Color(0xFFFAD3D5),
                    elevation: 10,
                    shadowColor: const Color.fromARGB(190, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Entrar',
                        style: GoogleFonts.montserratAlternates(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF68442E),
                          fontSize: 20,
                        ),
                      ),
                      const Positioned(
                        right: 8,
                        child: Icon(
                          Icons.login,
                          color: Color(0xFF68442E),
                          size: 30,
                        ),
                      ),
                    ],
                    ),
                )
              ),
            ),

             const SizedBox(height: 10),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                height: 70,
                child: TextButton(
                  onPressed: (){},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFC08081),
                    foregroundColor: const Color(0xFF68442E),
                    elevation: 10,
                    shadowColor: const Color.fromARGB(190, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
                  child: Text(
                    'Cadastrar',
                    style: GoogleFonts.montserratAlternates(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                )
              ),
            ),
          ],
        ),
      )
    );
  }
}