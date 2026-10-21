import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<String> armazenarFotoPerfil(XFile imagem, String usuarioId) async =>
    imagem.path;

Widget exibirFotoPerfil(String caminho) => Image.network(
  caminho,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) =>
      const Icon(Icons.person_outline, size: 64),
);