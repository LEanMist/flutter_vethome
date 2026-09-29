import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

class BotaoCadastro extends StatelessWidget {
  const BotaoCadastro({
    super.key,
    required this.largura,
    required this.altura,
    required this.fonte,
    required this.onPressed,
  });
  final double largura;
  final double altura;
  final double fonte;
  final VoidCallback onPressed;

  @override 
  Widget build(BuildContext context) {
    return Container(
      width: largura,
      height: altura,

      decoration:
          const inset_shadow.BoxDecoration(
        borderRadius:
            BorderRadius.all(
          Radius.circular(80),
        ),

        boxShadow: [
          inset_shadow.BoxShadow(
            color: Color.fromARGB(149, 17, 12, 12),
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),

      child: Stack(
        fit: StackFit.expand,

        children: [

          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor:
                  const Color(0xFFC08081),
              foregroundColor: Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(80),
              ),
            ),

            child: Text(
              'Cadastrar',
              style:
                  GoogleFonts.montserratAlternates(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fonte,
              ),
            ),
          ),
        ],
      ),
    );
  }
}