import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({
    super.key,
    required this.rascunho,
    required this.petNome,
    this.agendamentoRepository,
  });

  final AgendamentoRascunho rascunho;
  final String petNome;
  final AgendamentoRepository? agendamentoRepository;

  @override
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  static const _servicosPorCategoria = <CategoriaServico, List<ServicoAgendamento>>{
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
  ConvenioAgendamento? _convenio;
  bool _salvando = false;

  AgendamentoRepository get _repository =>
      widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;

  Future<void> _salvarAgendamento() async {
    if (_servicosSelecionados.isEmpty) {
      _mostrarMensagem('Selecione pelo menos um serviço.');
      return;
    }
    if (_convenio == null) {
      _mostrarMensagem('Selecione um convênio.');
      return;
    }

    final agendamento = widget.rascunho.finalizar(
      servicos: _servicosSelecionados.values.toList(),
      convenio: _convenio!,
    );
    if (agendamento.errors.isNotEmpty) {
      _mostrarMensagem(agendamento.errors.first);
      return;
    }

    setState(() => _salvando = true);
    try {
      final salvo = await _repository.save(agendamento);
      if (mounted) Navigator.of(context).pop(salvo);
    } catch (error) {
      if (mounted) _mostrarMensagem('Não foi possível salvar: $error');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: VetCores.rosaEscuro.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
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
          children: [
            for (final servico in servicos)
              CheckboxListTile(
                key: ValueKey('servico-${servico.id}'),
                value: _servicosSelecionados.containsKey(servico.id),
                onChanged: (selecionado) => _alternarServico(
                  servico,
                  selecionado ?? false,
                ),
                title: Text(
                  servico.nome,
                  style: GoogleFonts.comfortaa(
                    color: VetCores.marrom,
                    fontSize: 14,
                  ),
                ),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: VetCores.rosaEscuro,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        ),
      ),
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
                  Text(
                    'Serviços',
                    style: GoogleFonts.comfortaa(
                      color: VetCores.branco,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                children: [
                  _categoria(CategoriaServico.exames, Icons.biotech_rounded),
                  _categoria(CategoriaServico.vacinas, Icons.vaccines_rounded),
                  _categoria(
                    CategoriaServico.microchipagem,
                    Icons.memory_rounded,
                  ),
                  _categoria(CategoriaServico.atestados, Icons.assignment_rounded),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ConvenioAgendamento>(
                    key: const ValueKey('convenio-dropdown'),
                    value: _convenio,
                    decoration: InputDecoration(
                      labelText: 'Convênio',
                      labelStyle: GoogleFonts.comfortaa(
                        color: VetCores.marrom,
                      ),
                      filled: true,
                      fillColor: VetCores.rosaCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      for (final convenio in ConvenioAgendamento.values)
                        DropdownMenuItem(
                          value: convenio,
                          child: Text(_nomeConvenio(convenio)),
                        ),
                    ],
                    onChanged: (convenio) {
                      setState(() => _convenio = convenio);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvarAgendamento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VetCores.marrom,
                    foregroundColor: VetCores.branco,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _salvando ? 'Salvando...' : 'Concluir agendamento',
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

  String _nomeConvenio(ConvenioAgendamento convenio) => switch (convenio) {
    ConvenioAgendamento.petlove => 'Petlove',
    ConvenioAgendamento.doglife => 'Doglife',
    ConvenioAgendamento.particular => 'Particular',
  };
}