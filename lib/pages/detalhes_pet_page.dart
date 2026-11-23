import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';
import 'package:google_fonts/google_fonts.dart';

class DetalhesPetPage extends StatefulWidget {
  const DetalhesPetPage({
    super.key,
    required this.pet,
    required this.usuarioId,
    required this.agendamentoRepository,
    required this.onVoltar,
    this.atualizacaoAgendamentos,
  });

  final Pet pet;
  final String usuarioId;
  final AgendamentoRepository agendamentoRepository;
  final VoidCallback onVoltar;
  final Listenable? atualizacaoAgendamentos;

  @override
  State<DetalhesPetPage> createState() => _DetalhesPetPageState();
}

class _DetalhesPetPageState extends State<DetalhesPetPage>
    with WidgetsBindingObserver {
  List<Agendamento> _historico = [];
  bool _carregando = true;
  bool _erro = false;
  int _versaoCarregamento = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.atualizacaoAgendamentos?.addListener(_carregarHistorico);
    unawaited(_carregarHistorico());
  }

  @override
  void didUpdateWidget(covariant DetalhesPetPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.atualizacaoAgendamentos != widget.atualizacaoAgendamentos) {
      oldWidget.atualizacaoAgendamentos?.removeListener(_carregarHistorico);
      widget.atualizacaoAgendamentos?.addListener(_carregarHistorico);
    }
    if (oldWidget.pet.id != widget.pet.id ||
        oldWidget.usuarioId != widget.usuarioId ||
        oldWidget.agendamentoRepository != widget.agendamentoRepository) {
      unawaited(_carregarHistorico());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _carregarHistorico();
  }

  @override
  void dispose() {
    widget.atualizacaoAgendamentos?.removeListener(_carregarHistorico);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _carregarHistorico() async {
    final versao = ++_versaoCarregamento;
    setState(() {
      _carregando = true;
      _erro = false;
    });
    try {
      final idPet = widget.pet.id;
      if (idPet == null) {
        throw StateError('Não foi possível identificar o pet.');
      }
      final agendamentos = await widget.agendamentoRepository.findByPetId(
        idPet,
      );
      if (!mounted || versao != _versaoCarregamento) return;
      final historico =
          agendamentos
              .where(
                (agendamento) =>
                    agendamento.petId == idPet &&
                    agendamento.usuarioId == widget.usuarioId &&
                    agendamento.status != StatusAgendamento.cancelado,
              )
              .toList()
            ..sort((a, b) {
              final porData = b.data.compareTo(a.data);
              return porData != 0 ? porData : b.horario.compareTo(a.horario);
            });
      setState(() {
        _historico = historico;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted || versao != _versaoCarregamento) return;
      setState(() {
        _historico = [];
        _carregando = false;
        _erro = true;
      });
    }
  }

  String _dataFormatada(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

  String _pesoFormatado(double peso) =>
      '${peso == peso.roundToDouble() ? peso.toStringAsFixed(0) : peso.toStringAsFixed(1)} kg';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        return Column(
          children: [
            Container(
              width: double.infinity,
              height: compacto ? 100 : 120,
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
                      'Detalhes',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                        color: VetCores.branco,
                        fontSize: compacto ? 28 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    child: IconButton(
                      tooltip: 'Voltar',
                      onPressed: widget.onVoltar,
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: VetCores.branco,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, compacto ? 14 : 20, 20, 0),
              child: _cartaoDados(compacto),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Histórico de Atendimentos',
                  style: GoogleFonts.montserratAlternates(
                    color: VetCores.marrom,
                    fontSize: compacto ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(child: _conteudoHistorico(compacto)),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, compacto ? 12 : 18),
              child: BotaoEstilizado(
                texto: 'Editar',
                onPressed: null,
                largura: 120,
                altura: compacto ? 46 : 52,
                tamanhoFonte: 14,
                corFundo: VetCores.rosaFundo,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cartaoDados(bool compacto) {
    final genero = widget.pet.genero == PetGenero.macho ? 'Macho' : 'Fêmea';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compacto ? 12 : 16),
      decoration: inset.BoxDecoration(
        color: VetCores.rosaEscuro25,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          inset.BoxShadow(
            color: Color.fromARGB(45, 70, 40, 41),
            blurRadius: 1,
            offset: Offset(2, 3),
            inset: true,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _campo('Gênero/Sexo', genero, Icons.wc_rounded)),
              const SizedBox(width: 12),
              Expanded(
                child: _campo(
                  'Peso',
                  _pesoFormatado(widget.pet.peso),
                  Icons.monitor_weight_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _campo(
            'Data de Nascimento',
            _dataFormatada(widget.pet.dataNascimento),
            Icons.cake_outlined,
          ),
          const SizedBox(height: 8),
          _campo('Raça', widget.pet.raca, Icons.pets_rounded),
        ],
      ),
    );
  }

  Widget _campo(String titulo, String valor, IconData icone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            titulo,
            style: GoogleFonts.montserratAlternates(
              color: VetCores.marrom,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: VetCores.rosaEscuro50,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: VetCores.rosaFundo,
                  shape: BoxShape.circle,
                  border: Border.all(color: VetCores.rosaEscuro, width: 2),
                ),
                child: Icon(icone, color: VetCores.marrom, size: 19),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    valor,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.comfortaa(
                      color: VetCores.branco,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _conteudoHistorico(bool compacto) {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: VetCores.marrom),
      );
    }
    if (_erro) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Não foi possível carregar os atendimentos.'),
            TextButton(
              onPressed: _carregarHistorico,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_historico.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Nenhum atendimento encontrado.',
            textAlign: TextAlign.center,
            style: GoogleFonts.comfortaa(color: VetCores.marrom),
          ),
        ),
      );
    }
    return ListView.separated(
      key: const ValueKey('historico-atendimentos-pet'),
      padding: EdgeInsets.fromLTRB(20, 0, 20, compacto ? 8 : 12),
      itemCount: _historico.length,
      separatorBuilder: (_, _) => const SizedBox(height: 7),
      itemBuilder: (context, index) => _cartaoAtendimento(_historico[index]),
    );
  }

  Widget _cartaoAtendimento(Agendamento agendamento) {
    final statusConcluido = agendamento.status == StatusAgendamento.concluido;
    final servicos = agendamento.servicos.isEmpty
        ? 'Serviços não informados'
        : agendamento.servicos.map((servico) => servico.nome).join(' + ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: VetCores.rosaCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_dataFormatada(agendamento.data)} - ${agendamento.horario}',
                  style: GoogleFonts.montserratAlternates(
                    color: VetCores.marrom,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConcluido
                      ? VetCores.marrom50
                      : VetCores.rosaEscuro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusConcluido ? 'Concluído' : 'Ativo',
                  style: GoogleFonts.montserratAlternates(
                    color: VetCores.branco,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            servicos,
            style: GoogleFonts.montserratAlternates(
              color: VetCores.marrom,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
