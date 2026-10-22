import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/services/perfil_foto_service.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/widgets/bordas_circulares.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:image_picker/image_picker.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key, this.usuarioRepository});
  final UsuarioRepository? usuarioRepository;

  @override
  State<PerfilPage> createState() => _PerfilPage();
}

class _PerfilPage extends State<PerfilPage> {
  final _imagePicker = ImagePicker();
  String? _fotoPerfilPath;

  UsuarioRepository get _repository =>
      widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;

  Future<void> _selecionarFoto() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: VetCores.rosaFundo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera, color: VetCores.marrom),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: VetCores.marrom),
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

      final usuarios = _repository.findAll();
      final usuario = usuarios.isEmpty ? null : usuarios.first;
      final caminho = await armazenarFotoPerfil(
        picked,
        usuario?.id ?? usuario?.email ?? 'perfil',
      );
      if (!mounted) return;

      if (usuario != null) {
        _repository.save(usuario.copyWith(fotoPerfilPath: caminho));
      }
      setState(() => _fotoPerfilPath = caminho);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível selecionar ou salvar a foto: $error',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarios = _repository.findAll();
    final usuario = usuarios.isEmpty ? null : usuarios.first;
    final fotoPerfilPath = usuario?.fotoPerfilPath ?? _fotoPerfilPath;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCabecalho = compacto ? 140 : 160;
        final double alturaEtiqueta = compacto ? 290 : 350;
        final double larguraEtiqueta = compacto ? 230 : 300;
        final double alturaFoto = compacto ? 200 : 260;
        final double larguraFoto = compacto ? 200 : 260;
        return SizedBox.expand(
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: alturaCabecalho,
                decoration: BoxDecoration(
                  color: VetCores.rosaEscuro,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  'Perfil',
                  style: GoogleFonts.comfortaa(
                    color: VetCores.branco,
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
                    color: VetCores.rosaFundo.withValues(alpha: 0.3),
                    border: Border.all(color: VetCores.rosaEscuro, width: 5),
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
                            color: VetCores.marrom,
                            fontSize: compacto ? 20 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          width: larguraFoto,
                          height: alturaFoto,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: _selecionarFoto,
                                  child: DashedCircle(
                                    size: 100,
                                    color: VetCores.marrom50,
                                    strokeWidth: 3.2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(11),
                                      child: ClipOval(
                                        child: fotoPerfilPath == null? ColoredBox(
                                          color: VetCores.rosaFundo,
                                          child: Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 90,
                                            color: VetCores.marrom50,
                                          ),
                                        )
                                        : exibirFotoPerfil(fotoPerfilPath),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),                 
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
