import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> armazenarFotoPerfil(XFile imagem, String usuarioId) async {
  final diretorioApp = await getApplicationDocumentsDirectory();
  final diretorioFotos = Directory(
    '${diretorioApp.path}${Platform.pathSeparator}fotos_perfil',
  );
  await diretorioFotos.create(recursive: true);

  final idSeguro = usuarioId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final extensao = imagem.name.contains('.')
      ? imagem.name.substring(imagem.name.lastIndexOf('.'))
      : '.jpg';
  final arquivo = File(
    '${diretorioFotos.path}${Platform.pathSeparator}$idSeguro$extensao',
  );
  await imagem.saveTo(arquivo.path);
  return arquivo.path;
}

Future<String> armazenarFotoPet(XFile imagem, String petId) async {
  final diretorioApp = await getApplicationDocumentsDirectory();
  final diretorioFotos = Directory(
    '${diretorioApp.path}${Platform.pathSeparator}fotos_pets',
  );
  await diretorioFotos.create(recursive: true);
  final idSeguro = base64Url.encode(utf8.encode(petId)).replaceAll('=', '');
  final extensao = imagem.name.contains('.')
      ? imagem.name.substring(imagem.name.lastIndexOf('.'))
      : '.jpg';
  var sufixo = DateTime.now().microsecondsSinceEpoch;
  var arquivo = File(
    '${diretorioFotos.path}${Platform.pathSeparator}$idSeguro-$sufixo$extensao',
  );
  while (await arquivo.exists()) {
    sufixo++;
    arquivo = File(
      '${diretorioFotos.path}${Platform.pathSeparator}$idSeguro-$sufixo$extensao',
    );
  }
  await imagem.saveTo(arquivo.path);
  return arquivo.path;
}

Widget exibirFotoPerfil(String caminho) => Image.file(
  File(caminho),
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) =>
      const Icon(Icons.person_outline, size: 64),
);
