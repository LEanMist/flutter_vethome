import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/servicos_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/calendario.dart';
import 'package:flutter_vethome/widgets/pet_card.dart';
import 'package:flutter_vethome/widgets/seletor_horario.dart';
import 'package:google_fonts/google_fonts.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({
    super.key,
    this.petRepository,
    this.usuarioRepository,
    this.usuarioId,
    this.agendamentoRepository,
    this.atualizacaoAgendamentos,
    this.onAgendamentoConcluido,
  });

  final PetRepository? petRepository;
  final UsuarioRepository? usuarioRepository;
  final String? usuarioId;
  final AgendamentoRepository? agendamentoRepository;
  final Listenable? atualizacaoAgendamentos;
  final VoidCallback? onAgendamentoConcluido;

  @override
  State<AgendamentoPage> createState() => _AgendamentoPage();
}

class _AgendamentoPage extends State<AgendamentoPage> {
  late DateTime _dataSelecionada;
  final List<Agendamento> _agendamentos = [];
  int _versaoCarregamento = 0;

  PetRepository get _repository =>
      widget.petRepository ?? InMemoryPetRepository.instance;
  UsuarioRepository get _usuarioRepository =>
      widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;
  AgendamentoRepository get _agendamentoRepository =>
      widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;

  String? get _usuarioId {
    final usuarios = _usuarioRepository.findAll();
    return widget.usuarioId ?? (usuarios.isEmpty ? null : usuarios.first.id);
  }

  Future<void> _carregarAgendamentos() async {
    final versao = ++_versaoCarregamento;
    final usuarioId = _usuarioId;
    if (usuarioId == null || usuarioId.trim().isEmpty) {
      if (mounted) setState(() => _agendamentos.clear());
      return;
    }

    try {
      final agendamentos = await _agendamentoRepository.findByUsuarioId(usuarioId);
      if (!mounted || versao != _versaoCarregamento) return;
      setState(() {
        _agendamentos
          ..clear()
          ..addAll(agendamentos.reversed);
      });
    } catch (error) {
      if (mounted && versao == _versaoCarregamento) {
        _mostrarMensagem('Não foi possível carregar os agendamentos: $error');
      }
    }
  }

  Future<void> _agendarConsulta() async {
    if (_dataSelecionada.isBefore(DateUtils.dateOnly(DateTime.now()))) {
      _mostrarMensagem('Selecione uma data válida para a consulta.');
      return;
    }

    final usuarioId = _usuarioId;
    if (usuarioId == null || usuarioId.trim().isEmpty) {
      _mostrarMensagem('Cadastre um usuário antes de agendar consulta.');
      return;
    }

    final pets = _repository.findByUsuarioId(usuarioId);
    if (pets.isEmpty) {
      _mostrarMensagem('Cadastre um pet primeiro para agendar consulta.');
      return;
    }

    final petSelecionado = await showDialog<Pet>(
      context: context,
      builder: (context) => _SeletorPet(pets: pets),
    );
    if (!mounted || petSelecionado == null) return;
    final petId = petSelecionado.id;
    if (petId == null || petId.trim().isEmpty) {
      _mostrarMensagem('Não foi possível identificar o pet selecionado.');
      return;
    }

    final horario = await selecionarHorarioAgendamento(
      context,
      data: _dataSelecionada,
      repository: _agendamentoRepository,
    );
    if (!mounted || horario == null) return;
    if (!horariosDisponiveisAgendamento.contains(horario)) {
      _mostrarMensagem('Selecione um horário disponível.');
      return;
    }

    final rascunho = AgendamentoRascunho(
      usuarioId: usuarioId,
      petId: petId,
      data: _dataSelecionada,
      horario: horario,
    );
    if (rascunho.errors.isNotEmpty) {
      _mostrarMensagem(rascunho.errors.first);
      return;
    }

    final agendamento = await Navigator.of(context).push<Agendamento>(
      MaterialPageRoute(
        builder: (_) => ServicosPage(
          rascunho: rascunho,
          petNome: petSelecionado.nome,
          petTipo: petSelecionado.tipo,
          usuarioRepository: _usuarioRepository,
          agendamentoRepository: _agendamentoRepository,
        ),
      ),
    );
    if (!mounted || agendamento == null) return;

    if (_usuarioId == usuarioId) {
      setState(() {
        _agendamentos.insert(0, agendamento);
      });
      if (widget.onAgendamentoConcluido != null) {
        widget.onAgendamentoConcluido!();
      } else {
        unawaited(_carregarAgendamentos());
      }
    }
    _mostrarMensagem('Agendamento concluído para ${petSelecionado.nome}.');
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  void initState() {
    super.initState();
    final hoje = DateUtils.dateOnly(DateTime.now());
    _dataSelecionada = hoje;
    widget.atualizacaoAgendamentos?.addListener(_atualizarAgendamentos);
    unawaited(_carregarAgendamentos());
  }

  void _atualizarAgendamentos() => unawaited(_carregarAgendamentos());

  @override
  void didUpdateWidget(covariant AgendamentoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.atualizacaoAgendamentos != widget.atualizacaoAgendamentos) {
      oldWidget.atualizacaoAgendamentos?.removeListener(_atualizarAgendamentos);
      widget.atualizacaoAgendamentos?.addListener(_atualizarAgendamentos);
    }
    if (oldWidget.usuarioId != widget.usuarioId ||
        oldWidget.usuarioRepository != widget.usuarioRepository ||
        oldWidget.agendamentoRepository != widget.agendamentoRepository) {
      _agendamentos.clear();
      unawaited(_carregarAgendamentos());
    }
  }

  @override
  void dispose() {
    widget.atualizacaoAgendamentos?.removeListener(_atualizarAgendamentos);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final alturaCalendario = math
            .min(compacto ? 380.0 : 500.0, constraints.maxHeight * 0.68)
            .toDouble();
        return Column(
          children: [
            CalendarioAgendamento(
              dataSelecionada: _dataSelecionada,
              onDataSelecionada: (data) =>
                  setState(() => _dataSelecionada = data),
              alturaCalendario: alturaCalendario,
              compacto: compacto,
            ),
            SizedBox(height: compacto ? 20 : 24),
            Expanded(
              child: ListView.separated(
                key: const ValueKey('lista-agendamentos'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _agendamentos.length,
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 9),
                  child: Center(
                    child: SizedBox(
                      width: 350,
                      height: 9,
                      child: CustomPaint(
                        key: ValueKey('separador-agendamentos'),
                        painter: _SeparadorAgendamentoPainter(),
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context, index) {
                  final agendamento = _agendamentos[index];
                  final data = agendamento.data;
                  final dataFormatada =
                      '${data.day.toString().padLeft(2, '0')}/'
                      '${data.month.toString().padLeft(2, '0')}/${data.year}';
                  final servico = agendamento.servicos.isEmpty
                      ? 'Serviço não informado'
                      : agendamento.servicos.first.nome;
                      
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 60),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    dataFormatada,
                                    style: GoogleFonts.montserratAlternates(
                                      color: VetCores.marrom,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  agendamento.horario,
                                  style: GoogleFonts.montserratAlternates(
                                    color: VetCores.marrom,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 42),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: inset.BoxDecoration(
                                color: VetCores.rosaEscuro,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  inset.BoxShadow(
                                    color: Color.fromARGB(55, 0, 0, 0),
                                    blurRadius: 3,
                                    offset: Offset(2, 3),
                                    inset: true,
                                  ),
                                ],
                              ),
                              child: Text(
                                servico,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserratAlternates(
                                  color: VetCores.branco,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  
                },
              ),
            ),
            SizedBox(height: compacto ? 16 : 24),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, compacto ? 16 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 165,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _agendarConsulta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VetCores.marrom,
                        foregroundColor: VetCores.branco,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Agendar consulta',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 12,
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
      },
    );
  }
}

class _SeparadorAgendamentoPainter extends CustomPainter {
  const _SeparadorAgendamentoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = VetCores.marrom;
    final centro = size.height / 2;
    canvas.drawCircle(Offset(2, centro), 2, paint);
    canvas.drawCircle(Offset(size.width - 2, centro), 2, paint);
    for (double x = 7; x < size.width - 5; x += 3) {
      canvas.drawCircle(Offset(x, centro), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SeparadorAgendamentoPainter oldDelegate) => false;
}

class _SeletorPet extends StatelessWidget {
  const _SeletorPet({required this.pets});

  final List<Pet> pets;

  @override
  Widget build(BuildContext context) {
    final alturaMaxima = MediaQuery.sizeOf(context).height * 0.55;
    final alturaLista = math
        .min(pets.length * 77.0, math.max(65.0, alturaMaxima - 90))
        .toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: VetCores.rosaCard,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha seu Pet',
              style: GoogleFonts.comfortaa(
                color: VetCores.marrom,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: alturaLista,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: pets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return PetCard(
                    pet: pet,
                    onDetails: () => Navigator.of(context).pop(pet),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

