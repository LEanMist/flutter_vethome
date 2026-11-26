import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;
import 'package:flutter_vethome/themes/vet_cores.dart';

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
    this.controller,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.valorExibicao,
    this.tamanhoFonteValor,
    this.corIcone = const Color(0xFFC08081),
    this.corTexto = const Color(0xFF68442E),
    this.alinhamentoTexto = TextAlign.start,
  }) : assert(
         valorExibicao == null ||
             (controller == null && onTap == null && onChanged == null),
       );
  final String titulo;
  final IconData icone;
  final double altura;
  final double largura;
  final double tamanhoIcone;
  final double tamanhoIconeInterno;
  final double fonteLabel;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final String? valorExibicao;
  final double? tamanhoFonteValor;
  final Color corIcone;
  final Color corTexto;
  final TextAlign alinhamentoTexto;

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
                          color: VetCores.sombra,
                          blurRadius: 1,
                          offset: Offset(2, 2),
                          inset: true,
                        ),
                      ],
                    ),
                    child: valorExibicao != null
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: tamanhoIcone + 12,
                              right: 8,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  valorExibicao!,
                                  textAlign: alinhamentoTexto,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserratAlternates(
                                    color: corTexto,
                                    fontWeight: FontWeight.w500,
                                    fontSize: tamanhoFonteValor,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : TextField(
                      controller: controller,
                      expands: !obscureText,
                      maxLines: obscureText ? 1 : null,
                      minLines: obscureText ? 1 : null,
                      obscureText: obscureText,
                      keyboardType:
                          keyboardType ??
                          (titulo == 'Peso'
                              ? TextInputType.number
                              : TextInputType.text),
                      inputFormatters: inputFormatters,
                      textCapitalization: textCapitalization,
                      textAlign: alinhamentoTexto,
                      textAlignVertical: TextAlignVertical.center,
                      readOnly: onTap != null,
                      onTap: onTap,
                      style: GoogleFonts.montserratAlternates(
                        color: corTexto,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                          left: tamanhoIcone + 12,
                          right: 16,
                          top: obscureText ? (altura - 16) / 2 : 0,
                          bottom: obscureText ? (altura - 16) / 2 : 0,
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
                        errorText: errorText,
                      ),
                      onChanged: onChanged,
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
                      color: corIcone,
                      size: tamanhoIconeInterno,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
