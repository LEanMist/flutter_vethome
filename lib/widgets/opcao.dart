import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';

class Opcao extends StatelessWidget {
  const Opcao({
    super.key,
    required this.texto,
    required this.compacto,
    this.onTap,
  });

  final String texto;
  final bool compacto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            Expanded(
              child: Text(
                texto,
                style: GoogleFonts.comfortaa(
                  color: VetCores.marrom,
                  fontSize: compacto ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: compacto ? 40 : 28,
              color: VetCores.marrom,
            ),
          ],
        ),
      ),
    );
  }
}