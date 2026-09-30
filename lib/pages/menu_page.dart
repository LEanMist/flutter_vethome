import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPage();
}

class _MenuPage extends State<MenuPage> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
          final double alturaCabecalho = compacto ? 140 : 160;
          final double alturaCampoAnimais = compacto ? 480 : 700;
          final double larguraCampoAnimais = compacto ? 350 : 180;

          return Column(
            children: [
              Container(
                width: double.infinity,
                height: alturaCabecalho,
                decoration: BoxDecoration(
                  color: const Color(0xFFC08081),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20)
                  ),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  'Pets',
                  style: GoogleFonts.comfortaa(
                    color:  Color(0xFFFFFFFF),
                    fontSize: compacto ? 30 : 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 60,),
              Container(
                width: larguraCampoAnimais,
                height: alturaCampoAnimais,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(192, 128, 129, 0.25),
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              const SizedBox(height: 30,),
            ],
          );
        },
      )
    );
  }
}