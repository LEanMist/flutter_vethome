import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/etiqueta_perfil.dart';
import 'package:google_fonts/google_fonts.dart';

Future<DateTime?> selecionarDataAgendamento(
  BuildContext context, {
  required DateTime dataInicial,
}) {
  final hoje = DateUtils.dateOnly(DateTime.now());
  var dataTemporaria = dataInicial.isBefore(hoje) ? hoje : dataInicial;
  return showDialog<DateTime>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: StatefulBuilder(
          builder: (context, atualizarDialogo) {
            final alturaDisponivel = MediaQuery.sizeOf(context).height - 110;
            final escala = math.min(0.85, math.max(0.1, alturaDisponivel / 380));
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Fechar calendário',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: VetCores.branco,
                  ),
                ),
                CalendarioAgendamento(
                  dataSelecionada: dataTemporaria,
                  onDataSelecionada: (data) =>
                      atualizarDialogo(() => dataTemporaria = data),
                  onDiaSelecionado: (data) => Navigator.of(context).pop(data),
                  escala: escala,
                  mostrarEtiqueta: false,
                  arredondarTopo: true,
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class CalendarioAgendamento extends StatefulWidget {
  const CalendarioAgendamento({
    super.key,
    required this.dataSelecionada,
    required this.onDataSelecionada,
    this.onDiaSelecionado,
    this.alturaCalendario = 380,
    this.largura,
    this.escala = 1,
    this.compacto = true,
    this.mostrarEtiqueta = true,
    this.arredondarTopo = false,
  }) : assert(alturaCalendario > 0),
       assert(largura == null || largura > 0),
       assert(escala > 0);

  final DateTime dataSelecionada;
  final ValueChanged<DateTime> onDataSelecionada;
  final ValueChanged<DateTime>? onDiaSelecionado;
  final double alturaCalendario;
  final double? largura;
  final double escala;
  final bool compacto;
  final bool mostrarEtiqueta;
  final bool arredondarTopo;

  @override
  State<CalendarioAgendamento> createState() => _CalendarioAgendamentoState();
}

class _CalendarioAgendamentoState extends State<CalendarioAgendamento> {
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
  static const _diasDaSemana = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
  ];
  static const _nomesDiasDaSemana = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  late DateTime _mesVisivel;

  @override
  void initState() {
    super.initState();
    _mesVisivel = DateTime(
      widget.dataSelecionada.year,
      widget.dataSelecionada.month,
    );
  }

  @override
  void didUpdateWidget(CalendarioAgendamento oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateUtils.isSameDay(
      oldWidget.dataSelecionada,
      widget.dataSelecionada,
    )) {
      _mesVisivel = DateTime(
        widget.dataSelecionada.year,
        widget.dataSelecionada.month,
      );
    }
  }

  DateTime get _mesAtual {
    final hoje = DateTime.now();
    return DateTime(hoje.year, hoje.month);
  }

  void _mudarMes(int quantidade) {
    final proximoMes = DateTime(
      _mesVisivel.year,
      _mesVisivel.month + quantidade,
    );
    if (proximoMes.isBefore(_mesAtual)) return;

    final ultimoDia = DateTime(proximoMes.year, proximoMes.month + 1, 0).day;
    var diaSelecionado = math.min(widget.dataSelecionada.day, ultimoDia);
    if (proximoMes == _mesAtual && diaSelecionado < DateTime.now().day) {
      diaSelecionado = DateTime.now().day;
    }
    setState(() => _mesVisivel = proximoMes);
    widget.onDataSelecionada(
      DateTime(proximoMes.year, proximoMes.month, diaSelecionado),
    );
  }

  void _selecionarData(DateTime data) {
    final selecionada = DateUtils.dateOnly(data);
    if (selecionada.isBefore(DateUtils.dateOnly(DateTime.now()))) return;

    setState(() => _mesVisivel = DateTime(data.year, data.month));
    widget.onDataSelecionada(selecionada);
    widget.onDiaSelecionado?.call(selecionada);
  }

  @override
  Widget build(BuildContext context) {
    final compacto = widget.compacto;
    final alturaCalendario = widget.alturaCalendario;
    final alturaTotal = alturaCalendario + (widget.mostrarEtiqueta ? 30 : 0);
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

    return SizedBox(
      width: widget.largura,
      height: alturaTotal * widget.escala,
      child: LayoutBuilder(
        builder: (context, constraints) => FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: constraints.maxWidth / widget.escala,
            height: alturaTotal,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: const ValueKey('fundo-calendario'),
                  width: double.infinity,
                  height: alturaCalendario,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  decoration: BoxDecoration(
                    color: VetCores.rosaEscuro,
                    borderRadius: BorderRadius.vertical(
                      top: widget.arredondarTopo
                          ? const Radius.circular(26)
                          : Radius.zero,
                      bottom: const Radius.circular(26),
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
                              widget.dataSelecionada,
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
                if (widget.mostrarEtiqueta)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: EtiquetaPerfil(
                        compacto: compacto,
                        largura: compacto ? 280 : 200,
                        altura: compacto ? 60 : 68,
                        raioInferior: 70,
                        espessuraBorda: compacto ? 5 : 7,
                        conteudo: Text(
                          '${widget.dataSelecionada.day} - ${_nomesDiasDaSemana[widget.dataSelecionada.weekday % 7]}',
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
        ),
      ),
    );
  }
}
