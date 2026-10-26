import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/services/perfil_foto_service.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/widgets/etiqueta_perfil.dart';
import 'package:flutter_vethome/widgets/opcao.dart';
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

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _salvarUsuario(Usuario usuario) {
    try {
      _repository.save(usuario);
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) {
        _mostrarMensagem('Não foi possível atualizar os dados: $error');
      }
    }
  }

  Future<void> _editarNome() async {
    final usuarios = _repository.findAll();
    if (usuarios.isEmpty) {
      _mostrarMensagem('Cadastre um usuário antes de editar o perfil.');
      return;
    }

    final usuario = usuarios.first;
    var nomeEditado = usuario.nome;
    final novoNome = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mudar Nome de Perfil'),
        content: TextFormField(
          initialValue: usuario.nome,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => nomeEditado = value,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, nomeEditado),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (!mounted || novoNome == null) return;
    final nome = novoNome.trim();
    if (nome.length < 2) {
      _mostrarMensagem('Informe um nome com pelo menos 2 caracteres.');
      return;
    }

    _salvarUsuario(usuario.copyWith(nome: nome));
  }

  Future<void> _editarDataNascimento() async {
    final usuarios = _repository.findAll();
    if (usuarios.isEmpty) {
      _mostrarMensagem('Cadastre um usuário antes de editar o perfil.');
      return;
    }

    final usuario = usuarios.first;
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: usuario.dataNascimento ?? DateTime(hoje.year - 18),
      firstDate: DateTime(1900),
      lastDate: hoje,
    );

    if (!mounted || data == null) return;
    _salvarUsuario(usuario.copyWith(dataNascimento: data));
  }

  @override
  Widget build(BuildContext context) {
    final usuarios = _repository.findAll();
    final usuario = usuarios.isEmpty ? null : usuarios.first;
    final fotoPerfilPath = usuario?.fotoPerfilPath ?? _fotoPerfilPath;
    final dataNascimento = usuario?.dataNascimento;
    final dataNascimentoFormatada = dataNascimento == null
        ? 'Data de nascimento não cadastrada'
        : '${dataNascimento.day.toString().padLeft(2, '0')}/'
              '${dataNascimento.month.toString().padLeft(2, '0')}/'
              '${dataNascimento.year}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCabecalho = compacto ? 140 : 160;
        final double alturaIconeNascimento = compacto ? 25 : 30;
        final double tamanhoFonte = compacto ? 18 : 30;
        return SizedBox.expand(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
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
                      Padding(
                        padding: const EdgeInsets.only(
                          top: EtiquetaPerfil.offsetTop,
                        ),
                        child: EtiquetaPerfil(
                          nome: usuario?.nome ?? 'Nome não cadastrado',
                          fotoPerfilPath: fotoPerfilPath,
                          compacto: compacto,
                          onSelecionarFoto: _selecionarFoto,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compacto ? 20 : 30),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      size: alturaIconeNascimento,
                      color: VetCores.marrom,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dataNascimentoFormatada,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                        color: VetCores.marrom,
                        fontSize: tamanhoFonte,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compacto ? 70 : 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opcao(
                        texto: 'Mudar Foto de Perfil',
                        compacto: compacto,
                        onTap: _selecionarFoto,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: VetCores.marrom25,
                      ),
                      Opcao(
                        texto: 'Mudar Nome de Perfil',
                        compacto: compacto,
                        onTap: _editarNome,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: VetCores.marrom25,
                      ),
                      Opcao(
                        texto: 'Mudar Data de Nascimento',
                        compacto: compacto,
                        onTap: _editarDataNascimento,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
