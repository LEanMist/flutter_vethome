import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'perfil_foto_service_stub.dart'
    if (dart.library.io) 'perfil_foto_service_io.dart'
    if (dart.library.html) 'perfil_foto_service_web.dart' as platform;

Future<String> armazenarFotoPerfil(XFile imagem, String usuarioId) =>
    platform.armazenarFotoPerfil(imagem, usuarioId);

Widget exibirFotoPerfil(String caminho) => platform.exibirFotoPerfil(caminho);