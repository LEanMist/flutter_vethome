import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/convenio_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/foto_pet.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({
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
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  static const _alturaOpcaoServico = 48.0;
  static const _maxServicosVisiveis = 3;

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

  static const _examesComuns = <ServicoAgendamento>[
    ServicoAgendamento(
      id: 'hemograma',
      categoria: CategoriaServico.exames,
      nome: 'Hemograma',
    ),
    ServicoAgendamento(
      id: 'ureia-creatinina',
      categoria: CategoriaServico.exames,
      nome: 'Ureia e creatinina',
    ),
    ServicoAgendamento(
      id: 'alt-ggt',
      categoria: CategoriaServico.exames,
      nome: 'ALT e GGT',
    ),
    ServicoAgendamento(
      id: 'fosfatase-alcalina',
      categoria: CategoriaServico.exames,
      nome: 'Fosfatase alcalina',
    ),
    ServicoAgendamento(
      id: 'colesterol',
      categoria: CategoriaServico.exames,
      nome: 'Colesterol',
    ),
    ServicoAgendamento(
      id: 'trigliceridios',
      categoria: CategoriaServico.exames,
      nome: 'Triglicerídios',
    ),
    ServicoAgendamento(
      id: 'urina',
      categoria: CategoriaServico.exames,
      nome: 'Urina',
    ),
    ServicoAgendamento(
      id: 'coproparasitologico',
      categoria: CategoriaServico.exames,
      nome: 'Coproparasitológico',
    ),
  ];

  static const _vacinasGato = <ServicoAgendamento>[
    ServicoAgendamento(
      id: 'v3',
      categoria: CategoriaServico.vacinas,
      nome: 'V3',
    ),
    ServicoAgendamento(
      id: 'calicivirose',
      categoria: CategoriaServico.vacinas,
      nome: 'Calicivirose',
    ),
    ServicoAgendamento(
      id: 'rinotraqueite',
      categoria: CategoriaServico.vacinas,
      nome: 'Rinotraqueíte',
    ),
    ServicoAgendamento(
      id: 'v4',
      categoria: CategoriaServico.vacinas,
      nome: 'V4',
    ),
    ServicoAgendamento(
      id: 'v5',
      categoria: CategoriaServico.vacinas,
      nome: 'V5',
    ),
    ServicoAgendamento(
      id: 'antirrabica',
      categoria: CategoriaServico.vacinas,
      nome: 'Antirrábica',
    ),
  ];

  static const _vacinasCachorro = <ServicoAgendamento>[
    ServicoAgendamento(
      id: 'v8-v10',
      categoria: CategoriaServico.vacinas,
      nome: 'V8 e V10',
    ),
    ServicoAgendamento(
      id: 'cinomose',
      categoria: CategoriaServico.vacinas,
      nome: 'Cinomose',
    ),
    ServicoAgendamento(
      id: 'parvovirose',
      categoria: CategoriaServico.vacinas,
      nome: 'Parvovirose',
    ),
    ServicoAgendamento(
      id: 'adenovirose',
      categoria: CategoriaServico.vacinas,
      nome: 'Adenovirose',
    ),
    ServicoAgendamento(
      id: 'leptospirose',
      categoria: CategoriaServico.vacinas,
      nome: 'Leptospirose',
    ),
    ServicoAgendamento(
      id: 'antirrabica',
      categoria: CategoriaServico.vacinas,
      nome: 'Antirrábica',
    ),
    ServicoAgendamento(
      id: 'giardia',
      categoria: CategoriaServico.vacinas,
      nome: 'Giárdia',
    ),
    ServicoAgendamento(
      id: 'gripe-canina',
      categoria: CategoriaServico.vacinas,
      nome: 'Gripe dos canis',
    ),
  ];

  Map<CategoriaServico, List<ServicoAgendamento>> get _servicosPorCategoria {
    final gato = widget.petTipo == PetType.gato;
    final exames = <ServicoAgendamento>[
      ..._examesComuns,
      if (gato)
        const ServicoAgendamento(
          id: 'fiv-felv',
          categoria: CategoriaServico.exames,
          nome: 'FIV e FeLV',
        ),
    ];

    return {
      CategoriaServico.exames: exames,
      CategoriaServico.vacinas: gato ? _vacinasGato : _vacinasCachorro,
      CategoriaServico.microchipagem: const [
        ServicoAgendamento(
          id: 'microchipagem',
          categoria: CategoriaServico.microchipagem,
          nome: 'Microchipagem',
        ),
      ],
      CategoriaServico.atestados: const [
        ServicoAgendamento(
          id: 'atestado-saude',
          categoria: CategoriaServico.atestados,
          nome: 'Atestado de saúde',
        ),
      ],
    };
  }

  final Set<CategoriaServico> _categoriasExpandidas = {};
  final Map<String, ServicoAgendamento> _servicosSelecionados = {};
  final Map<CategoriaServico, ScrollController> _controladoresServico = {};

  AgendamentoRepository get _repository =>
      widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;

  ScrollController _controladorServico(CategoriaServico categoria) {
    return _controladoresServico.putIfAbsent(
      categoria,
      ScrollController.new,
    );
  }

  @override
  void dispose() {
    for (final controller in _controladoresServico.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _continuar() async {
    if (_servicosSelecionados.isEmpty) {
      _mostrarMensagem('Selecione pelo menos um serviço.');
      return;
    }

    final rascunho = widget.rascunho.comServicos(
      _servicosSelecionados.values.toList(),
    );
    final agendamento = await Navigator.of(context).push<Agendamento>(
      MaterialPageRoute(
        builder: (_) => ConvenioPage(
          rascunho: rascunho,
          petNome: widget.petNome,
          petTipo: widget.petTipo,
          petFotoPerfilPath: widget.petFotoPerfilPath,
          usuarioRepository: widget.usuarioRepository,
          agendamentoRepository: _repository,
        ),
      ),
    );
    if (!mounted || agendamento == null) return;
    Navigator.of(context).pop(agendamento);
  }

  Future<void> _confirmarSaida() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Deseja sair do agendamento?',
          style: GoogleFonts.comfortaa(
            color: VetCores.marrom,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Se sair agora, os dados deste agendamento serão descartados.',
          style: GoogleFonts.comfortaa(
            color: VetCores.marrom,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: VetCores.rosaCard,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: VetCores.marrom,
            ),
            child: Text(
              'Não',
              style: GoogleFonts.comfortaa(
                color: VetCores.marrom,
                fontWeight: FontWeight.w900,
              ),
            )
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: VetCores.marrom,
              foregroundColor: VetCores.branco,
            ),
            child: Text(
              'Sim',
              style: GoogleFonts.comfortaa(
                color: VetCores.branco,
                fontWeight: FontWeight.w900,
              ),
            )
          ),
        ],
      ),
    );

    if (!mounted || sair != true) return;
    Navigator.of(context).pop();
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _alternarServico(ServicoAgendamento servico, bool selecionado) {
    setState(() {
      if (selecionado) {
        _servicosSelecionados[servico.id] = servico;
      } else {
        _servicosSelecionados.remove(servico.id);
      }
    });
  }

  BorderRadius _bordaDaCategoria(CategoriaServico categoria) {
    if (categoria == CategoriaServico.exames) return _bordaExames;
    if (categoria == CategoriaServico.atestados) return _bordaAtestados;
    return _bordaCircular;
  }

  void _alternarCategoria(CategoriaServico categoria) {
    setState(() {
      if (!_categoriasExpandidas.remove(categoria)) {
        _categoriasExpandidas.add(categoria);
      }
    });
  }

  Widget _categoria(CategoriaServico categoria, IconData icone) {
    final servicos = _servicosPorCategoria[categoria]!;
    if (categoria == CategoriaServico.microchipagem ||
        categoria == CategoriaServico.atestados) {
      return _categoriaSimples(categoria, icone, servicos.single);
    }

    final expandida = _categoriasExpandidas.contains(categoria);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: _bordaDaCategoria(categoria),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('categoria-${categoria.name}'),
              onTap: () => _alternarCategoria(categoria),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: _gradienteCategorias,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 58),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(icone, color: VetCores.branco),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            categoria.label,
                            style: GoogleFonts.montserratAlternates(
                              color: VetCores.branco,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: expandida ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(
                            Icons.expand_more_rounded,
                            color: VetCores.marrom,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (expandida)
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.75,
              child: Material(
                color: VetCores.rosaEscuro.withValues(alpha: 0.25),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: _alturaOpcaoServico * _maxServicosVisiveis,
                  ),
                  child: Scrollbar(
                    controller: _controladorServico(categoria),
                    thumbVisibility:
                        servicos.length > _maxServicosVisiveis,
                    thickness: 4,
                    radius: const Radius.circular(4),
                    child: ListView.builder(
                      key: ValueKey('lista-servicos-${categoria.name}'),
                      controller: _controladorServico(categoria),
                      primary: false,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemExtent: _alturaOpcaoServico,
                      physics: servicos.length > _maxServicosVisiveis
                          ? const ClampingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      itemCount: servicos.length,
                      itemBuilder: (context, index) =>
                          _opcaoServico(servicos[index]),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _categoriaSimples(
    CategoriaServico categoria,
    IconData icone,
    ServicoAgendamento servico,
  ) {
    final selecionado = _servicosSelecionados.containsKey(servico.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: _bordaDaCategoria(categoria),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: _gradienteCategorias),
          child: ListTile(
            key: ValueKey('categoria-${categoria.name}'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            leading: Icon(icone, color: VetCores.branco),
            title: Text(
              categoria.label,
              style: GoogleFonts.montserratAlternates(
                color: VetCores.branco,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Checkbox(
              key: ValueKey('servico-${servico.id}'),
              value: selecionado,
              onChanged: (value) => _alternarServico(servico, value ?? false),
              activeColor: VetCores.marrom50,
              checkColor: VetCores.branco,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onTap: () => _alternarServico(servico, !selecionado),
          ),
        ),
      ),
    );
  }

  Widget _opcaoServico(ServicoAgendamento servico) {
    final selecionado = _servicosSelecionados.containsKey(servico.id);
    return SizedBox(
      height: _alturaOpcaoServico,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => _alternarServico(servico, !selecionado),
                  child: Text(
                    servico.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserratAlternates(
                      color: VetCores.marrom,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Checkbox(
              key: ValueKey('servico-${servico.id}'),
              value: selecionado,
              onChanged: (value) => _alternarServico(servico, value ?? false),
              activeColor: VetCores.marrom50,
              checkColor: VetCores.branco,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoriaAlinhada(
    CategoriaServico categoria,
    IconData icone,
    double largura,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: largura, child: _categoria(categoria, icone)),
    );
  }

  Widget _listaCategorias(double larguraCategoria) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 12),
        children: [
          _categoriaAlinhada(
            CategoriaServico.exames,
            Icons.biotech_rounded,
            larguraCategoria,
          ),
          _categoriaAlinhada(
            CategoriaServico.vacinas,
            Icons.vaccines_rounded,
            larguraCategoria,
          ),
          _categoriaAlinhada(
            CategoriaServico.microchipagem,
            Icons.memory_rounded,
            larguraCategoria,
          ),
          _categoriaAlinhada(
            CategoriaServico.atestados,
            Icons.assignment_rounded,
            larguraCategoria,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetCores.rosaFundo,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
          final double alturaCabecalho = compacto ? 140 : 160;
          final larguraCategoria = constraints.maxWidth * 0.86;
          final double tamanhoImagemPet = compacto ? 40 : 34;
          final double larguraBotao = compacto ? 150 : 250;
          final double alturaBotao = compacto ? 50 : 60;
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
                          tooltip: 'Voltar',
                          onPressed: _confirmarSaida,
                          icon: const Icon(Icons.arrow_back),
                          color: VetCores.branco,
                        ),
                        Expanded(
                          child: Text(
                            'Serviços',
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
                    SizedBox(height: compacto ? 15 : 12),
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
              SizedBox(height: compacto ? 18 : 12),
              Expanded(child: _listaCategorias(larguraCategoria)),
              SafeArea(
                top: false,
                child: SizedBox(
                  width: larguraBotao,
                  height: alturaBotao,
                  child: ElevatedButton(
                    onPressed: _continuar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VetCores.marrom,
                      foregroundColor: VetCores.branco,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Continuar',
                      style: GoogleFonts.comfortaa(
                        fontSize: compacto ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
