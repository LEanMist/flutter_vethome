import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

class ConvenioPage extends StatefulWidget {
  const ConvenioPage({
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
  State<ConvenioPage> createState() => _ConvenioPageState();
}

class _ConvenioPageState extends State<ConvenioPage> {
  static const _convenios = [
    ConvenioAgendamento.petlove,
    ConvenioAgendamento.doglife,
    ConvenioAgendamento.particular,
  ];

  ConvenioAgendamento? _selecionado;
  bool _salvando = false;

  AgendamentoRepository get _repository =>
      widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;

  Future<void> _concluirAgendamento() async {
    final convenio = _selecionado;
    if (convenio == null) {
      _mostrarMensagem('Selecione um convênio.');
      return;
    }

    final agendamento = widget.rascunho.finalizar(convenio: convenio);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  String get _tipoPet => switch (widget.petTipo) {
    PetType.cachorro => 'Cão',
    PetType.gato => 'Gato',
    PetType.outro => 'Pet',
  };

  String _nomeConvenio(ConvenioAgendamento convenio) => switch (convenio) {
    ConvenioAgendamento.petlove => 'PetLove',
    ConvenioAgendamento.doglife => 'Doglife',
    ConvenioAgendamento.particular => 'Particular',
  };

  IconData _iconeConvenio(ConvenioAgendamento convenio) => switch (convenio) {
    ConvenioAgendamento.petlove => Icons.home_outlined,
    ConvenioAgendamento.doglife => Icons.medical_services_outlined,
    ConvenioAgendamento.particular => Icons.pets_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetCores.rosaFundo,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: VetCores.rosaFundo.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _tipoPet,
                      style: GoogleFonts.comfortaa(
                        color: VetCores.branco,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.petNome,
                    style: GoogleFonts.comfortaa(
                      color: VetCores.branco,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                children: [
                  for (final convenio in _convenios)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: VetCores.rosaCard,
                        borderRadius: BorderRadius.circular(28),
                        child: InkWell(
                          key: ValueKey('convenio-${convenio.name}'),
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => setState(() => _selecionado = convenio),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: _selecionado == convenio
                                    ? VetCores.rosaEscuro
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _iconeConvenio(convenio),
                                  color: VetCores.branco,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _nomeConvenio(convenio),
                                    style: GoogleFonts.comfortaa(
                                      color: VetCores.branco,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _selecionado == convenio
                                      ? Icons.check_circle
                                      : Icons.chevron_right_rounded,
                                  color: VetCores.marrom,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                  onPressed: _selecionado == null || _salvando
                      ? null
                      : _concluirAgendamento,
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
}
