import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

class CampoCadastro extends StatelessWidget {
  const CampoCadastro({
    super.key,
    required this.titulo,
    required this.icone,
    required this.altura,
    required this.largura,
    required this.tamanhoIcone,
    required this.tamanhoIconeInterno,
    required this.fonteLabel,
  });
  final String titulo;
  final IconData icone;
  final double altura;
  final double largura;
  final double tamanhoIcone;
  final double tamanhoIconeInterno;
  final double fonteLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 1),
          child: Text(
            titulo,
            style: GoogleFonts.montserratAlternates(
              color: const Color(0xFF68442E),
              fontWeight: FontWeight.w500,
              fontSize: fonteLabel,
            ),
          ),
        ),

        SizedBox(
          height: altura,
          width: largura,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: altura,
                child: Container(
                decoration: const inset_shadow.BoxDecoration(
                  color: Color.fromRGBO(192, 128, 129, 0.28),
                  borderRadius: BorderRadius.all(Radius.circular(80)),
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
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.center,

                  style: GoogleFonts.montserratAlternates(
                    color: const Color(0xFF68442E),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    isDense: true,
                    contentPadding: EdgeInsets.only(
                      left: tamanhoIcone + 12,
                      right: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: const BorderSide(
                        color: Color(0xFF68442E),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              ),
              Positioned(
                left: 0,
                top: (altura - tamanhoIcone) / 2,
                child: Container(
                  width: tamanhoIcone,
                  height: tamanhoIcone,
                  decoration: inset_shadow.BoxDecoration(
                    color: const Color(0xFFFAD3D5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC08081).withValues(alpha: 0.80),
                      width: 3,
                    ),
                    boxShadow: const [
                      inset_shadow.BoxShadow(
                        color: Color.fromARGB(50, 255, 255, 255),
                        blurRadius: 4,
                        offset: Offset(-2, -2),
                        inset: true,
                      ),
                      inset_shadow.BoxShadow(
                        color: Color.fromARGB(70, 105, 66, 67),
                        blurRadius: 5,
                        offset: Offset(3, 4),
                        inset: true,
                      ),
                    ],
                  ),
                  child: Icon(
                    icone,
                    color: const Color(0xFFC08081),
                    size: tamanhoIconeInterno,
                  ),
                ),
              ),
            ],
          ),
        )
        ],
      ),
    );
  }
}