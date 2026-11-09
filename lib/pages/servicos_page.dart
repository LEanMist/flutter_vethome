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

  Widget _categoria(CategoriaServico categoria, IconData icone) {
    final servicos = _servicosPorCategoria[categoria]!;
    if (categoria == CategoriaServico.microchipagem ||
        categoria == CategoriaServico.atestados) {
      return _categoriaSimples(categoria, icone, servicos.single);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: VetCores.rosaEscuro.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey('categoria-${categoria.name}'),
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            leading: Icon(icone, color: VetCores.branco),
            title: Text(
              categoria.label,
              style: GoogleFonts.comfortaa(
                color: VetCores.branco,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconColor: VetCores.marrom,
            collapsedIconColor: VetCores.marrom,
            initiallyExpanded: categoria == CategoriaServico.exames,
            children: [for (final servico in servicos) _opcaoServico(servico)],
          ),
        ),
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
        color: VetCores.rosaEscuro.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          key: ValueKey('categoria-${categoria.name}'),
          minTileHeight: 52,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          leading: Icon(icone, color: VetCores.branco),
          title: Text(
            categoria.label,
            style: GoogleFonts.comfortaa(
              color: VetCores.branco,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Checkbox(
            key: ValueKey('servico-${servico.id}'),
            value: selecionado,
            onChanged: (value) => _alternarServico(servico, value ?? false),
            activeColor: VetCores.rosaEscuro,
            checkColor: VetCores.branco,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onTap: () => _alternarServico(servico, !selecionado),
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
      activeColor: VetCores.rosaEscuro,
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _categoriaAlinhada(CategoriaServico categoria, IconData icone) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: constraints.maxWidth * 0.86,
            child: _categoria(categoria, icone),
          ),
        );
      },
    );
  }

  Widget _listaCategorias() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      children: [
        _categoriaAlinhada(CategoriaServico.exames, Icons.biotech_rounded),
        _categoriaAlinhada(CategoriaServico.vacinas, Icons.vaccines_rounded),
        _categoriaAlinhada(
          CategoriaServico.microchipagem,
          Icons.memory_rounded,
        ),
        _categoriaAlinhada(
          CategoriaServico.atestados,
          Icons.assignment_rounded,
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: const BoxDecoration(
                color: VetCores.rosaEscuro,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
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
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.petNome}  |  $dataFormatada  |  ${widget.rascunho.horario}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.comfortaa(
                      color: VetCores.branco,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _listaCategorias()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
