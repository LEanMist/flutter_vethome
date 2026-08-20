import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAD3D5),
        foregroundColor: const Color(0xFF68442E),
        title: Text(
          'Cadastro',
          style: GoogleFonts.comfortaa(
            color: const Color(0xFF68442E),
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        centerTitle: true,        
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
                decoration: const inset_shadow.BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/imagens/VetHome_logo_1.jpg',
                      width: 200,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: const inset_shadow.BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            inset_shadow.BoxShadow(
                              color: Color.fromARGB(150, 255, 255, 255),
                              blurRadius: 2,
                              offset: Offset(-5, -5),
                              inset: true,
                            ),
                            inset_shadow.BoxShadow(
                              color: Color.fromARGB(190, 75, 42, 43),
                              blurRadius: 6,
                              offset: Offset(6, 7),
                              inset: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),

            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.39,
                height: 70,
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
                  onPressed: (){},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFAD3D5),
                    foregroundColor: const Color(0xFFFAD3D5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Cadastrar Manualmente',
                        style: GoogleFonts.montserratAlternates(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF68442E),
                          fontSize: 18,
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 9),
                          child: Icon(
                            Icons.login,
                            color: Color(0xFF68442E),
                            size: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 1,
                        left: 10,
                        right: 28,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        left: 10,
                        right: 28,
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
                )
              ),
            ),
          ],)
      ),
    );
  }
}