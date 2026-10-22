import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_vethome/models/pet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';

class PetCard extends StatelessWidget {
  const PetCard({
    super.key,
    required this.pet,
    required this.onDetails,
  });

  final Pet pet;
  final VoidCallback onDetails;

  String get imageAsset => pet.tipo == PetType.cachorro
      ? 'assets/imagens/cachorro.png'
      : 'assets/imagens/gato.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: inset.BoxDecoration(
        color: VetCores.rosaEscuro50,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          inset.BoxShadow(
            color: Color.fromARGB(55, 70, 40, 41),
            blurRadius: 1,
            offset: Offset(2, 3),
            inset: true,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onDetails,
          child: SizedBox(
            height: 65,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, object, stackTrace) =>
                          const Icon(Icons.pets, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pet.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.comfortaa(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_double_arrow_right_rounded,
                    color: Color(0xFF9A6C59),
                    size: 45,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
