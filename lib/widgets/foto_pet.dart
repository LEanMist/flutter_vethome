import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/services/perfil_foto_service.dart';

class FotoPet extends StatelessWidget {
  const FotoPet({
    super.key,
    required this.tipo,
    required this.tamanho,
    this.fotoPerfilPath,
  });

  final PetType tipo;
  final double tamanho;
  final String? fotoPerfilPath;

  @override
  Widget build(BuildContext context) {
    final foto = fotoPerfilPath;
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: foto == null
          ? Image.asset(
              tipo == PetType.gato
                  ? 'assets/imagens/gato.png'
                  : 'assets/imagens/cachorro.png',
              key: ValueKey('icone-pet-${tipo.name}'),
              fit: BoxFit.contain,
            )
          : ClipOval(
              key: const ValueKey('foto-pet'),
              child: exibirFotoPerfil(foto),
            ),
    );
  }
}
