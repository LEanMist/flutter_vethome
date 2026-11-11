import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/convenio_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({
    super.key,
    required this.rascunho,
    required this.petNome,
    required this.petTipo,
    this.agendamentoRepository,
  });

  final AgendamentoRascunho rascunho;
  final String petNome;
  final PetType petTipo;
  final AgendamentoRepository? agendamentoRepository;

  @override
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
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

  static const _servicosPorCategoria =
      <CategoriaServico, List<ServicoAgendamento>>{
        CategoriaServico.exames: [
          ServicoAgendamento(
            id: 'hemograma',
            categoria: CategoriaServico.exames,
            nome: 'Hemograma',
          ),
          ServicoAgendamento(
            id: 'creatinina',
            categoria: CategoriaServico.exames,
            nome: 'Creatinina',
          ),
          ServicoAgendamento(
            id: 'urina',
            categoria: CategoriaServico.exames,
            nome: 'Urina',
          ),
        ],
        CategoriaServico.vacinas: [
          ServicoAgendamento(
            id: 'antirrabica',
            categoria: CategoriaServico.vacinas,
            nome: 'Antirrábica',
          ),
          ServicoAgendamento(
            id: 'v8-v10',
            categoria: CategoriaServico.vacinas,
            nome: 'V8 / V10',
          ),
          ServicoAgendamento(
            id: 'gripe',
            categoria: CategoriaServico.vacinas,
            nome: 'Gripe',
          ),
        ],
        CategoriaServico.microchipagem: [
          ServicoAgendamento(
            id: 'microchipagem',
            categoria: CategoriaServico.microchipagem,
            nome: 'Microchipagem',
          ),
        ],
        CategoriaServico.atestados: [
          ServicoAgendamento(
            id: 'atestado-saude',
            categoria: CategoriaServico.atestados,
            nome: 'Atestado de saúde',
          ),
        ],
      };

  final Set<CategoriaServico> _categoriasExpandidas = {
    CategoriaServico.exames,
  };
  final Map<String, ServicoAgendamento> _servicosSelecionados = {};

  AgendamentoRepository get _repository =>
      widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;

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
        title: const Text('Deseja sair do agendamento?'),
        content: const Text(
          'Se sair agora, os dados deste agendamento serão descartados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sim'),
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
            color: Colors.transparent,
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
                  constraints: const BoxConstraints(minHeight: 56),
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
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: Material(
                    color: VetCores.rosaEscuro.withValues(alpha: 0.25),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final servico in servicos)
                          _opcaoServico(servico),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
    return CheckboxListTile(
      key: ValueKey('servico-${servico.id}'),
      value: _servicosSelecionados.containsKey(servico.id),
      onChanged: (selecionado) =>
          _alternarServico(servico, selecionado ?? false),
      title: Text(
        servico.nome,
        style: GoogleFonts.comfortaa(color: VetCores.marrom, fontSize: 14),
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: VetCores.marrom50,
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
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
    return ListView(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.rascunho.data;
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';

    return Scaffold(
      backgroundColor: VetCores.rosaFundo,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
          final double alturaCabecalho = compacto ? 140 : 160;
          final larguraCategoria = constraints.maxWidth * 0.86;
          final double larguraBotao = compacto ? 150 : 250;
          final double alturaBotao = compacto ? 50 : 60;

          return Column(
            children: [
              Container(
                width: double.infinity,
                height: alturaCabecalho,
                padding: const EdgeInsets.fromLTRB(2, 25, 8, 20),
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
                    SizedBox(height: compacto ? 16 : 20),
                    Text(
                      '${widget.petNome}  |  $dataFormatada  |  ${widget.rascunho.horario}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                        color: VetCores.branco,
                        fontSize: compacto ? 17 : 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compacto ? 35 : 16),
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
