import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/barra_rolagem.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:flutter_vethome/widgets/editar_pet.dart';
import 'package:google_fonts/google_fonts.dart';

class DetalhesPetPage extends StatefulWidget {
  const DetalhesPetPage({
    super.key,
    required this.pet,
    required this.usuarioId,
    required this.agendamentoRepository,
    required this.petRepository,
    required this.onVoltar,
    required this.onPetAtualizado,
    this.atualizacaoAgendamentos,
  });

  final Pet pet;
  final String usuarioId;
  final AgendamentoRepository agendamentoRepository;
  final PetRepository petRepository;
  final VoidCallback onVoltar;
  final VoidCallback onPetAtualizado;
  final Listenable? atualizacaoAgendamentos;

  @override
  State<DetalhesPetPage> createState() => _DetalhesPetPageState();
}

class _DetalhesPetPageState extends State<DetalhesPetPage>
    with WidgetsBindingObserver {
  List<Agendamento> _historico = [];
  final _scrollHistorico = ScrollController();
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
    _scrollHistorico.dispose();
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
                    agendamento.usuarioId == widget.usuarioId,
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

  Future<void> _editarPet() async {
    final editado = await showDialog<Pet>(
      context: context,
      builder: (_) => EditarPet(pet: widget.pet),
    );
    if (!mounted || editado == null) return;
    try {
      final id = editado.id;
      final atual = id == null ? null : widget.petRepository.findById(id);
      if (atual == null || atual.usuarioId != widget.usuarioId ||
          widget.pet.id != id) {
        throw StateError('Não foi possível encontrar o pet selecionado.');
      }
      widget.petRepository.save(
        atual.copyWith(
          nome: editado.nome,
          genero: editado.genero,
          peso: editado.peso,
          dataNascimento: editado.dataNascimento,
          raca: editado.raca,
        ),
      );
      widget.onPetAtualizado();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar o pet: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCabecalho = compacto ? 120 : 160;
        final double larguraCartao = compacto
            ? constraints.maxWidth - 65
            : constraints.maxWidth - 40;
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
                      'Detalhes',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                        color: VetCores.branco,
                        fontSize: compacto ? 30 : 32,
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
            SizedBox(height: compacto ? 14 : 20),
            Padding(
              padding: EdgeInsets.fromLTRB(20, compacto ? 14 : 20, 20, 0),
              child: _cartaoDados(compacto, larguraCartao),
            ),
            SizedBox(height: compacto ? 14 : 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Histórico de Atendimentos',
                  style: GoogleFonts.montserratAlternates(
                    color: VetCores.marrom,
                    fontSize: compacto ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(child: _conteudoHistorico(compacto)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 23),
              child: BotaoEstilizado(
                texto: 'Editar',
                onPressed: _editarPet,
                largura: compacto ? 140 : 140,
                altura: compacto ? 50 : 52,
                tamanhoFonte: 15,
                corFundo: VetCores.rosaFundo,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cartaoDados(bool compacto, double largura) {
    final genero = widget.pet.genero == PetGenero.macho ? 'Macho' : 'Fêmea';
    return Container(
      width: largura,
      height: compacto ? 280 : 200,
      padding: EdgeInsets.all(compacto ? 14 : 16),
      decoration: inset.BoxDecoration(
        color: VetCores.rosaEscuro25,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          inset.BoxShadow(
            color: VetCores.sombra,
            blurRadius: 1,
            offset: Offset(2.5, 2.5),
            inset: true,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _campo(
                  compacto,
                  'Gênero/Sexo',
                  genero,
                  Icons.wc_rounded,
                ),
              ),
              SizedBox(width: compacto ? 40 : 40),
              Expanded(
                child: _campo(
                  compacto,
                  'Peso',
                  _pesoFormatado(widget.pet.peso),
                  Icons.monitor_weight_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _campo(
            compacto,
            'Data de Nascimento',
            _dataFormatada(widget.pet.dataNascimento),
            Icons.cake_outlined,
          ),
          const SizedBox(height: 8),
          _campo(compacto, 'Raça', widget.pet.raca, Icons.pets_rounded),
        ],
      ),
    );
  }

  Widget _campo(bool compacto, String titulo, String valor, IconData icone) {
    return CampoCadastro(
      titulo: titulo,
      icone: icone,
      altura: compacto ? 55 : 50,
      largura: double.infinity,
      tamanhoIcone: compacto ? 55 : 60,
      tamanhoIconeInterno: compacto ? 30 : 40,
      corIcone: VetCores.marrom75,
      corTexto: VetCores.branco,
      corCampo: VetCores.rosaEscuro50,
      alinhamentoTexto: TextAlign.center,
      fonteLabel: compacto ? 14 : 14,
      tamanhoFonteValor: compacto ? 15 : 14,
      valorExibicao: valor,
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
    return BarraRolagem(
      controller: _scrollHistorico,
      child: ListView.separated(
        key: const ValueKey('historico-atendimentos-pet'),
        controller: _scrollHistorico,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 0, 20, compacto ? 8 : 12),
        itemCount: _historico.length,
        separatorBuilder: (_, _) => const SizedBox(height: 7),
        itemBuilder: (context, index) => _cartaoAtendimento(_historico[index]),
      ),
    );
  }

  Widget _cartaoAtendimento(Agendamento agendamento) {
    final (textoStatus, corStatus) = switch (agendamento.status) {
      StatusAgendamento.ativo => ('Ativo', VetCores.rosaEscuro),
      StatusAgendamento.cancelado => ('Cancelado', VetCores.marrom75),
      StatusAgendamento.concluido => ('Concluído', VetCores.marrom50),
    };
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
                  color: corStatus,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  textoStatus,
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
