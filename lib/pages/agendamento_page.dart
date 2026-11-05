import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/servicos_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/etiqueta_perfil.dart';
import 'package:flutter_vethome/widgets/pet_card.dart';
import 'package:google_fonts/google_fonts.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({
    super.key,
    this.petRepository,
    this.usuarioRepository,
    this.agendamentoRepository,
  });

  final PetRepository? petRepository;
  final UsuarioRepository? usuarioRepository;
  final AgendamentoRepository? agendamentoRepository;

  @override
  State<AgendamentoPage> createState() => _AgendamentoPage();
}

class _AgendamentoPage extends State<AgendamentoPage> {
  static const _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  static const _diasDaSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  static const _nomesDiasDaSemana = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];
  static const _horariosDisponiveis = [
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  late DateTime _mesVisivel;
  late DateTime _dataSelecionada;
  final List<Agendamento> _agendamentos = [];
  Pet? _petSelecionado;
  String? _horarioSelecionado;

  PetRepository get _repository =>
      widget.petRepository ?? InMemoryPetRepository.instance;
  UsuarioRepository get _usuarioRepository =>
      widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;
  AgendamentoRepository get _agendamentoRepository =>
      widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;

  DateTime get _mesAtual {
    final hoje = DateTime.now();
    return DateTime(hoje.year, hoje.month);
  }

  Future<void> _agendarConsulta() async {
    if (_dataSelecionada.isBefore(DateUtils.dateOnly(DateTime.now()))) {
      _mostrarMensagem('Selecione uma data válida para a consulta.');
      return;
    }

    final pets = _repository.findAll();
    if (pets.isEmpty) {
      _mostrarMensagem('Cadastre um pet primeiro para agendar consulta.');
      return;
    }

    final usuarios = _usuarioRepository.findAll();
    final usuarioId = usuarios.isEmpty ? null : usuarios.first.id;
    if (usuarioId == null || usuarioId.trim().isEmpty) {
      _mostrarMensagem('Cadastre um usuário antes de agendar consulta.');
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

    final horario = await showDialog<String>(
      context: context,
      builder: (context) => _SeletorHorario(
        data: _dataSelecionada,
        meses: _meses,
        diasDaSemana: _nomesDiasDaSemana,
        horarios: _horariosDisponiveis,
      ),
    );
    if (!mounted || horario == null) return;
    if (!_horariosDisponiveis.contains(horario)) {
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
          agendamentoRepository: _agendamentoRepository,
        ),
      ),
    );
    if (!mounted || agendamento == null) return;

    setState(() {
      _petSelecionado = petSelecionado;
      _horarioSelecionado = horario;
      _agendamentos.insert(0, agendamento);
    });
    _mostrarMensagem('Agendamento concluído para ${petSelecionado.nome}.');
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  void initState() {
    super.initState();
    final hoje = DateUtils.dateOnly(DateTime.now());
    _mesVisivel = DateTime(hoje.year, hoje.month);
    _dataSelecionada = hoje;
  }

  void _mudarMes(int quantidade) {
    final proximoMes = DateTime(
      _mesVisivel.year,
      _mesVisivel.month + quantidade,
    );
    if (proximoMes.isBefore(_mesAtual)) return;

    setState(() {
      _mesVisivel = proximoMes;
      final ultimoDia = DateTime(
        proximoMes.year,
        proximoMes.month + 1,
        0,
      ).day;
      var diaSelecionado = math.min(_dataSelecionada.day, ultimoDia);
      if (proximoMes == _mesAtual && diaSelecionado < DateTime.now().day) {
        diaSelecionado = DateTime.now().day;
      }
      _dataSelecionada = DateTime(
        proximoMes.year,
        proximoMes.month,
        diaSelecionado,
      );
    });
  }

  void _selecionarData(DateTime data) {
    final selecionada = DateUtils.dateOnly(data);
    if (selecionada.isBefore(DateUtils.dateOnly(DateTime.now()))) return;

    setState(() {
      _dataSelecionada = selecionada;
      _mesVisivel = DateTime(data.year, data.month);
    });
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
        final tamanhoFonte = compacto ? 15.0 : 20.0;
        final alturaBase = compacto ? 118.0 : 128.0;
        final alturaCelula = math
            .min(
              compacto ? 40.0 : 80.0,
              math.max(24.0, (alturaCalendario - alturaBase) / 6),
            )
            .toDouble();
        final hoje = DateUtils.dateOnly(DateTime.now());
        final primeiroDia = DateTime(_mesVisivel.year, _mesVisivel.month);
        final inicioGrade = DateTime(
          primeiroDia.year,
          primeiroDia.month,
          1 - primeiroDia.weekday % 7,
        );
        final double larguraEtiqueta = compacto ? 280 : 200.0;
        final double alturaEtiqueta = compacto ? 60 : 68;
        final double espessuraBordaEtiqueta = compacto ? 5 : 7;

        return Column(
          children: [
            SizedBox(
            height: alturaCalendario + 30,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: alturaCalendario,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  decoration: const BoxDecoration(
                    color: VetCores.rosaEscuro,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(26),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            if (_mesVisivel.isAfter(_mesAtual))
                              IconButton(
                                tooltip: 'Mês anterior',
                                onPressed: () => _mudarMes(-1),
                                icon: const Icon(Icons.chevron_left_rounded),
                                color: VetCores.marrom,
                              )
                            else
                              const SizedBox(width: 48),
                            Expanded(
                              child: Text(
                                '${_meses[_mesVisivel.month - 1]} ${_mesVisivel.year}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.comfortaa(
                                  color: VetCores.marrom,
                                  fontSize: tamanhoFonte + 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Próximo mês',
                              onPressed: () => _mudarMes(1),
                              icon: const Icon(Icons.chevron_right_rounded),
                              color: VetCores.marrom,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: compacto ? 30 : 40,
                        child: Row(
                          children: [
                            for (final dia in _diasDaSemana)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    dia,
                                    style: GoogleFonts.comfortaa(
                                      color: VetCores.marrom,
                                      fontSize: tamanhoFonte,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: alturaCelula * 6,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: 42,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisExtent: alturaCelula,
                              ),
                          itemBuilder: (context, index) {
                            final data = DateTime(
                              inicioGrade.year,
                              inicioGrade.month,
                              inicioGrade.day + index,
                            );
                            final selecionada = DateUtils.isSameDay(
                              data,
                              _dataSelecionada,
                            );
                            final hojeSelecionado = DateUtils.isSameDay(
                              data,
                              hoje,
                            );
                            final mesmoMes = data.month == _mesVisivel.month;
                            final dataPassada = data.isBefore(hoje);

                            return Padding(
                              padding: const EdgeInsets.all(2),
                              child: Material(
                                key: selecionada
                                    ? const ValueKey('selected-calendar-day')
                                    : ValueKey(
                                        'calendar-day-${data.year}-${data.month}-${data.day}',
                                      ),
                                color: selecionada
                                    ? VetCores.rosaFundo
                                    : Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: dataPassada
                                      ? null
                                      : () => _selecionarData(data),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: hojeSelecionado && !selecionada
                                          ? Border.all(
                                              color: VetCores.rosaClaro,
                                              width: 1.5,
                                            )
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${data.day}',
                                      style: GoogleFonts.comfortaa(
                                        color: selecionada
                                            ? VetCores.marrom
                                            : !mesmoMes || dataPassada
                                            ? VetCores.marrom50
                                            : VetCores.marrom,
                                        fontSize: tamanhoFonte,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: EtiquetaPerfil(
                      compacto: compacto,
                      largura: larguraEtiqueta,
                      altura: alturaEtiqueta,
                      raioInferior: 70,
                      espessuraBorda: espessuraBordaEtiqueta,
                      conteudo: Text(
                        '${_dataSelecionada.day} - ${_nomesDiasDaSemana[_dataSelecionada.weekday % 7]}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.comfortaa(
                          color: VetCores.marrom,
                          fontSize: compacto ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
            Expanded(
              child: ListView.builder(
                key: const ValueKey('lista-agendamentos'),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _agendamentos.length,
                itemBuilder: (context, index) {
                  final agendamento = _agendamentos[index];
                  final petNome =
                      _repository.findById(agendamento.petId)?.nome ??
                      agendamento.petId;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VetCores.rosaCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$petNome - ${agendamento.horario}',
                          style: GoogleFonts.comfortaa(
                            color: VetCores.marrom,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${agendamento.data.day}/${agendamento.data.month}/${agendamento.data.year}',
                          style: GoogleFonts.comfortaa(
                            color: VetCores.marrom,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                compacto ? 16 : 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_petSelecionado != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _horarioSelecionado == null
                            ? 'Pet selecionado: ${_petSelecionado!.nome}'
                            : '${_petSelecionado!.nome} - $_horarioSelecionado',
                        style: GoogleFonts.comfortaa(
                          color: VetCores.marrom,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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

class _SeletorHorario extends StatelessWidget {
  const _SeletorHorario({
    required this.data,
    required this.meses,
    required this.diasDaSemana,
    required this.horarios,
  });

  final DateTime data;
  final List<String> meses;
  final List<String> diasDaSemana;
  final List<String> horarios;

  @override
  Widget build(BuildContext context) {
    final diaDaSemana = diasDaSemana[data.weekday % 7];
    final dataFormatada =
        '${data.day} - $diaDaSemana, ${meses[data.month - 1]} ${data.year}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        decoration: BoxDecoration(
          color: VetCores.rosaFundo,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 52),
                Expanded(
                  child: Text(
                    dataFormatada,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.comfortaa(
                      color: VetCores.marrom,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 26,
                  tooltip: 'Fechar horários',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: VetCores.marrom,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 16,
              children: [
                for (final horario in horarios)
                SizedBox(
                  width: 90,
                  height: 48,
                  child: ElevatedButton(
                    key: ValueKey('horario-$horario'),
                    onPressed: () => Navigator.of(context).pop(horario),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VetCores.rosaEscuro,
                      foregroundColor: VetCores.branco,
                      elevation: 2,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      horario,
                      style: GoogleFonts.comfortaa(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}