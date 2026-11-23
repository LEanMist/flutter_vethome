import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/services/cep_lookup_service.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';
import 'package:flutter_vethome/widgets/endereco.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;


class ListaEnderecos extends StatefulWidget {
  const ListaEnderecos({
    super.key,
    this.usuarioRepository,
    this.usuarioId,
    this.cepLookupService,
  });

  final UsuarioRepository? usuarioRepository;
  final String? usuarioId;
  final CepLookupService? cepLookupService;

  @override
  State<ListaEnderecos> createState() => _ListaEnderecosState();
}

class _ListaEnderecosState extends State<ListaEnderecos> {
  UsuarioRepository get _repository =>
      widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;

  Usuario? get _usuario {
    final id = widget.usuarioId;
    if (id != null) return _repository.findById(id);
    final usuarios = _repository.findAll();
    return usuarios.isEmpty ? null : usuarios.first;
  }

  EnderecoUsuario _principal(Usuario usuario) => EnderecoUsuario(
    nome: usuario.nomeEnderecoPrincipal,
    cep: usuario.cep,
    logradouro: usuario.endereco,
    numero: usuario.numero,
    complemento: usuario.complemento,
    cidade: usuario.cidade,
  );

  Usuario _comPrincipal(Usuario usuario, EnderecoUsuario? endereco) =>
      usuario.copyWith(
        nomeEnderecoPrincipal: endereco?.nome ?? 'Endereço principal',
        cep: endereco?.cep ?? '',
        endereco: endereco?.logradouro ?? '',
        numero: endereco?.numero ?? '',
        complemento: endereco?.complemento ?? '',
        cidade: endereco?.cidade ?? '',
      );

  bool _corresponde(EnderecoUsuario a, EnderecoUsuario b) =>
      a.nome == b.nome &&
      a.cep == b.cep &&
      a.logradouro == b.logradouro &&
      a.numero == b.numero &&
      a.complemento == b.complemento &&
      a.cidade == b.cidade;

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _aplicar(EnderecoUsuario original, bool principal, int indiceAdicional, EnderecoUsuario? novo) {
    final usuario = _usuario;
    if (usuario == null) {
      _mensagem('Não foi possível carregar os dados do usuário.');
      return;
    }
    Usuario atualizado;
    if (principal) {
      if (!usuario.temEnderecoPrincipal || !_corresponde(_principal(usuario), original)) {
        _mensagem('O endereço foi alterado. Tente novamente.');
        return;
      }
      if (novo != null) {
        atualizado = _comPrincipal(usuario, novo);
      } else if (usuario.enderecosAdicionais.isNotEmpty) {
        atualizado = _comPrincipal(usuario, usuario.enderecosAdicionais.first)
            .copyWith(enderecosAdicionais: usuario.enderecosAdicionais.sublist(1));
      } else {
        atualizado = _comPrincipal(usuario, null);
      }
    } else {
      final enderecos = [...usuario.enderecosAdicionais];
      if (indiceAdicional < 0 || indiceAdicional >= enderecos.length ||
          !_corresponde(enderecos[indiceAdicional], original)) {
        _mensagem('O endereço foi alterado. Tente novamente.');
        return;
      }
      if (novo == null) {
        enderecos.removeAt(indiceAdicional);
      } else {
        enderecos[indiceAdicional] = novo;
      }
      atualizado = usuario.copyWith(enderecosAdicionais: enderecos);
    }
    try {
      _repository.save(atualizado);
      setState(() {});
      _mensagem(novo == null ? 'Endereço excluído.' : 'Endereço atualizado.');
    } catch (error) {
      _mensagem('Não foi possível salvar o endereço: $error');
    }
  }

  Future<void> _editar(EnderecoUsuario endereco, bool principal, int indiceAdicional) async {
    final novo = await showDialog<EnderecoUsuario>(
      context: context,
      builder: (_) => NovoEndereco(
        enderecoInicial: endereco,
        cepLookupService: widget.cepLookupService,
      ),
    );
    if (!mounted || novo == null) return;
    _aplicar(endereco, principal, indiceAdicional, novo);
  }

  Future<void> _deletar(EnderecoUsuario endereco, bool principal, int indiceAdicional) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VetCores.rosaFundo,
        title: Text('Deseja excluir este endereço?', style: GoogleFonts.comfortaa()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    _aplicar(endereco, principal, indiceAdicional, null);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;

    return Scaffold(
      backgroundColor: VetCores.rosaFundo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            final double alturaCabecalho = compacto ? 120 : 160;
            final double alturaListaEnderecos = compacto ? 170 : 250;
            final enderecos = usuario == null
                ? <EnderecoUsuario>[]
                : [
                    if (usuario.temEnderecoPrincipal) _principal(usuario),
                    ...usuario.enderecosAdicionais,
                  ];
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: alturaCabecalho,
                  decoration: const BoxDecoration(
                    color: VetCores.rosaEscuro,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56),
                        child: Text(
                          'Endereços',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            color: VetCores.branco,
                            fontSize: compacto ? 30 : 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        child: IconButton(
                          tooltip: 'Voltar',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: VetCores.branco,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compacto ? 10 : 24),
                Expanded(
                  child: usuario == null ? 
                  Center(
                    child: Text(
                      'Não foi possível carregar os dados do usuário.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                        color: VetCores.marrom,
                      ),
                    ),
                  ) : 
                  enderecos.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum endereço cadastrado.',
                        style: GoogleFonts.comfortaa(color: VetCores.marrom),
                      ),
                    )
                  : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: enderecos.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final endereco = enderecos[index];
                      final principal = usuario.temEnderecoPrincipal && index == 0;
                      final indiceAdicional = index - (usuario.temEnderecoPrincipal ? 1 : 0);
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 700,
                          ),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: alturaListaEnderecos,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: inset.BoxDecoration(
                              color: VetCores.rosaEscuro50,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                inset.BoxShadow(
                                  color: Color.fromARGB(55, 0, 0, 0),
                                  blurRadius: 2,
                                  offset: Offset(3, 3),
                                  inset: true,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      'Nome:',
                                      style: GoogleFonts.comfortaa(
                                        color: VetCores.marrom,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 52),
                                    Expanded(                              
                                      child: Text(
                                        endereco.nome,
                                        style: GoogleFonts.comfortaa(
                                          color: VetCores.marrom,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      'Endereço:',
                                      style: GoogleFonts.comfortaa(
                                        color: VetCores.marrom,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        endereco.enderecoCompleto,
                                        style: GoogleFonts.comfortaa(
                                          color: VetCores.marrom,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: BotaoEstilizado(
                                        texto: 'Editar',
                                        largura: 96,
                                        altura: 40,
                                        tamanhoFonte: 15,
                                        corFundo: VetCores.branco50,
                                        mostrarSombra: false,
                                        onPressed: () => _editar(endereco, principal, indiceAdicional),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: SizedBox(
                                        width: 96,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () => _deletar(endereco, principal, indiceAdicional),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: VetCores.vermelhoEscuro,
                                            foregroundColor: VetCores.branco,
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            'Deletar',
                                            style: GoogleFonts.comfortaa(
                                              fontSize: 15,
                                              color: VetCores.branco,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
