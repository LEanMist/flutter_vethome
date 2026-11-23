import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'perfil_foto_service_stub.dart'
    if (dart.library.io) 'perfil_foto_service_io.dart'
    if (dart.library.html) 'perfil_foto_service_web.dart'
    as platform;

Future<String> armazenarFotoPerfil(XFile imagem, String usuarioId) =>
    platform.armazenarFotoPerfil(imagem, usuarioId);

Future<String> armazenarFotoPet(XFile imagem, String petId) =>
    platform.armazenarFotoPet(imagem, petId);

Widget exibirFotoPerfil(String caminho) => platform.exibirFotoPerfil(caminho);

Future<XFile?> selecionarFotoPerfil(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: VetCores.rosaFundo,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera, color: VetCores.marrom),
            title: const Text('Tirar foto'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: VetCores.marrom),
            title: const Text('Escolher da galeria'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null || !context.mounted) return null;
  return ImagePicker().pickImage(
    source: source,
    maxWidth: 800,
    imageQuality: 85,
  );
}
