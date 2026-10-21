import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/services/perfil_foto_service.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/widgets/bordas_circulares.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:image_picker/image_picker.dart';


class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPage();
}

class _PerfilPage extends State<PerfilPage> {
  final _imagePicker = ImagePicker();

  Future<void> _selecionarFoto() async {
    final repository = InMemoryUsuarioRepository.instance;
    if (repository.findAll().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um usuário primeiro.')),
      );
      return;
    }

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: VetCores.pink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera, color: VetCores.brown),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: VetCores.brown),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final usuarios = repository.findAll();
      if (usuarios.isEmpty) return;

      final usuario = usuarios.first;
      final caminho = await armazenarFotoPerfil(
        picked,
        usuario.id ?? usuario.email,
      );
      if (!mounted) return;

      repository.save(usuario.copyWith(fotoPerfilPath: caminho));
      setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir a imagem.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarios = InMemoryUsuarioRepository.instance.findAll();
    final usuario = usuarios.isEmpty ? null : usuarios.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCabecalho = compacto ? 140 : 160;
        final double alturaEtiqueta = compacto ? 290 : 350;
        final double larguraEtiqueta = compacto ? 230 : 300;
        return SizedBox(
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
            Container(
              width: double.infinity,
              height: alturaCabecalho,
              decoration: BoxDecoration(
                color: const Color(0xFFC08081),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Perfil',
                style: GoogleFonts.comfortaa(
                  color: Color(0xFFFFFFFF),
                  fontSize: compacto ? 30 : 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),  
            Positioned(
              top: 85,
              child: Container(
                width: larguraEtiqueta,
                height: alturaEtiqueta,
                decoration: BoxDecoration(
                  color: VetCores.pink.withValues(alpha: 0.3),
                  border: Border.all(color: VetCores.rose, width: 5),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                    bottom: Radius.circular(200),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        usuario?.nome ?? 'Nome não cadastrado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.comfortaa(
                          color: VetCores.brown,
                          fontSize: compacto ? 18 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),                   
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 178,
                        height: 178,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: _selecionarFoto,
                                child: DashedCircle(
                                  size: 178,
                                  color: VetCores.rose,
                                  strokeWidth: 5,
                                  child: ClipOval(
                                    child: usuario?.fotoPerfilPath == null
                                        ? ColoredBox(
                                            color: VetCores.pink,
                                            child: Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 56,
                                              color: VetCores.rose,
                                            ),
                                          )
                                        : exibirFotoPerfil(
                                            usuario!.fotoPerfilPath!,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: IconButton.filled(
                                tooltip: 'Alterar foto de perfil',
                                onPressed: _selecionarFoto,
                                icon: const Icon(Icons.camera_alt_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
            ],
          ),
        );
      },
    );
  }
}
