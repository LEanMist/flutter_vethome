import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/finalizar_agendamento_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/foto_pet.dart';
import 'package:google_fonts/google_fonts.dart';

class ConvenioPage extends StatefulWidget {
  const ConvenioPage({
    super.key,
    required this.rascunho,
    required this.petNome,
    required this.petTipo,
    this.petFotoPerfilPath,
    this.usuarioRepository,
    this.agendamentoRepository,
  });

  final AgendamentoRascunho rascunho;
  final String petNome;
  final PetType petTipo;
  final String? petFotoPerfilPath;
  final UsuarioRepository? usuarioRepository;
  final AgendamentoRepository? agendamentoRepository;

  @override
  State<ConvenioPage> createState() => _ConvenioPageState();
}

class _ConvenioPageState extends State<ConvenioPage> {
  static const _gradienteCategorias = LinearGradient(
    begin:  Alignment(-1, -4),
    end: Alignment(1, 4),
    colors: [VetCores.rosaEscuro, VetCores.rosaFundo],
    stops: [0, 1.0],
  );
  static const _bordaExames = BorderRadius.only(
    topRight: Radius.circular(50),
    bottomRight: Radius.circular(20),
  );
  static const _bordaCircular = BorderRadius.only(
    topRight: Radius.circular(20),
    bottomRight: Radius.circular(20),
  );
  static const _bordaAtestados = BorderRadius.only(
    topRight: Radius.circular(20),
    bottomRight: Radius.circular(50),
  );

  static const _convenios = [
    ConvenioAgendamento.petlove,
    ConvenioAgendamento.doglife,
    ConvenioAgendamento.particular,
  ];

  Future<void> _confirmarConvenio(ConvenioAgendamento convenio) async {
    final continuar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VetCores.rosaCard,
        title: Text(
          'Confirmar convênio',
          style: GoogleFonts.comfortaa(
            color: VetCores.marrom,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Deseja continuar com ${_nomeConvenio(convenio)}?',
          style: GoogleFonts.comfortaa(
            color: VetCores.marrom
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: VetCores.marrom,
            ),
            child: Text(
              'Voltar',
              style: GoogleFonts.comfortaa(
                color: VetCores.marrom,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: VetCores.marrom,
              foregroundColor: VetCores.branco,
            ),
            child: Text(
              'Continuar',
              style: GoogleFonts.comfortaa(
                color: VetCores.branco,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted || continuar != true) return;
    final agendamento = await Navigator.of(context).push<Agendamento>(
      MaterialPageRoute(
        builder: (_) => FinalizarAgendamentoPage(
          rascunho: widget.rascunho,
          petNome: widget.petNome,
          petTipo: widget.petTipo,
          petFotoPerfilPath: widget.petFotoPerfilPath,
          convenio: convenio,
          usuarioRepository: widget.usuarioRepository,
          agendamentoRepository: widget.agendamentoRepository,
        ),
      ),
    );
    if (!mounted || agendamento == null) return;
    Navigator.of(context).pop(agendamento);
  }

  String _nomeConvenio(ConvenioAgendamento convenio) => switch (convenio) {
    ConvenioAgendamento.petlove => 'PetLove',
    ConvenioAgendamento.doglife => 'Doglife',
    ConvenioAgendamento.particular => 'Particular',
  };

  String _imagemConvenio(ConvenioAgendamento convenio) => switch (convenio) {
    ConvenioAgendamento.petlove => 'assets/imagens/CasaVeterinario.png',
    ConvenioAgendamento.doglife => 'assets/imagens/Estestoscopio.png',
    ConvenioAgendamento.particular => 'assets/imagens/Pirulas.png',
  };

  BorderRadius _bordaDaCategoria(ConvenioAgendamento categoria) {
    if (categoria == ConvenioAgendamento.petlove) return _bordaExames;
    if (categoria == ConvenioAgendamento.particular) return _bordaAtestados;
    return _bordaCircular;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetCores.rosaFundo,
      body: LayoutBuilder(
        builder:(context, constraints) {
          final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
          final double alturaCabecalho = compacto ? 140 : 160;
          final double tamanhoImagemPet = compacto ? 37 : 34;
          final double larguraLinhaConvenio = constraints.maxWidth * 0.85;
          final double alturaLinhaConvenio = compacto ? 70 : 80;
          final double tamanhoImagemConvenio = compacto ? 29 : 35;
          return Column(
            children: [
              Container(
                width: double.infinity,
                height: alturaCabecalho,
                padding: EdgeInsets.fromLTRB(
                  6,
                  compacto ? 23 : 30,
                  8,
                  compacto ? 11 : 16,
                ),
                decoration: BoxDecoration(
                  color: VetCores.rosaEscuro,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Voltar para serviços',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          color: VetCores.branco,
                        ),
                        Expanded(
                          child: Text(
                            'Convênio',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.comfortaa(
                              color: VetCores.branco,
                              fontSize: compacto ? 30 : 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: compacto ? 47 : 80),
                      ],
                    ),
                    SizedBox(height: compacto ? 20 : 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.62,
                          ),
                          child: Text(
                            widget.petNome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserratAlternates(
                              color: VetCores.branco,
                              fontSize: compacto ? 20 : 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        FotoPet(
                          tipo: widget.petTipo,
                          fotoPerfilPath: widget.petFotoPerfilPath,
                          tamanho: tamanhoImagemPet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: compacto ? 100 : 100),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 28, 16, 16),
                    children: [
                      for (final convenio in _convenios)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: larguraLinhaConvenio,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Material(         
                                    borderRadius: _bordaDaCategoria(convenio),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      key: ValueKey('convenio-${convenio.name}'),
                                      borderRadius: _bordaDaCategoria(convenio),
                                      onTap: () => _confirmarConvenio(convenio),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: _gradienteCategorias,
                                          borderRadius: _bordaDaCategoria(convenio),
                                        ),
                                        child: SizedBox(
                                          height: alturaLinhaConvenio,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  _imagemConvenio(convenio),
                                                  width: tamanhoImagemConvenio,
                                                  height: tamanhoImagemConvenio,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: Text(
                                                    _nomeConvenio(convenio),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts
                                                        .montserratAlternates(
                                                      color: VetCores.branco,
                                                      fontSize: compacto ? 20 : 25,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () => _confirmarConvenio(convenio),
                                  icon: const Icon(
                                    Icons.keyboard_double_arrow_right_rounded,
                                    size: 35,
                                  ),
                                  color: VetCores.marrom,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ],
          );
        }
      ),
    );
  }
}
