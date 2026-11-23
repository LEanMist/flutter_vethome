import 'dart:async';

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

const horariosDisponiveisAgendamento = [
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '16:00',
];

Future<String?> selecionarHorarioAgendamento(
  BuildContext context, {
  required DateTime data,
  required AgendamentoRepository repository,
}) async {
  Set<String> horariosOcupados;
  try {
    horariosOcupados = await repository.horariosOcupados(data);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível consultar os horários: $error'),
        ),
      );
    }
    return null;
  }
  if (!context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (context) => SeletorHorario(
      data: data,
      horarios: horariosDisponiveisAgendamento,
      horariosOcupados: horariosOcupados,
    ),
  );
}

class SeletorHorario extends StatefulWidget {
  const SeletorHorario({
    super.key,
    required this.data,
    required this.horarios,
    this.horariosOcupados = const {},
    this.larguraMaxima = 430,
    this.larguraBotao = 90,
    this.alturaBotao = 48,
    this.agora,
  }) : assert(larguraMaxima > 0),
       assert(larguraBotao > 0),
       assert(alturaBotao > 0);

  final DateTime data;
  final List<String> horarios;
  final Set<String> horariosOcupados;
  final double larguraMaxima;
  final double larguraBotao;
  final double alturaBotao;
  final DateTime Function()? agora;

  @override
  State<SeletorHorario> createState() => _SeletorHorarioState();
}

class _SeletorHorarioState extends State<SeletorHorario> {
  Timer? _timer;
  late Set<String> _horariosPassados;

  Set<String> _calcularHorariosPassados() {
    final agora = (widget.agora ?? DateTime.now)();
    return {
      for (final horario in widget.horarios)
        if (horarioJaPassou(widget.data, horario, agora: agora)) horario,
    };
  }

  @override
  void initState() {
    super.initState();
    _horariosPassados = _calcularHorariosPassados();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final passados = _calcularHorariosPassados();
      if (!setEquals(passados, _horariosPassados)) {
        setState(() => _horariosPassados = passados);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SeletorHorario oldWidget) {
    super.didUpdateWidget(oldWidget);
    _horariosPassados = _calcularHorariosPassados();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final horarios = widget.horarios;
    final ocupados = widget.horariosOcupados;
    final indisponiveis = {...ocupados, ..._horariosPassados};
    final diaDaSemana = _diasDaSemana[data.weekday % 7];
    final dataFormatada =
        '${data.day} - $diaDaSemana, ${_meses[data.month - 1]} ${data.year}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: widget.larguraMaxima),
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
                    width: widget.larguraBotao,
                    height: widget.alturaBotao,
                    child: ElevatedButton(
                      key: ValueKey('horario-$horario'),
                      onPressed: indisponiveis.contains(horario)
                          ? null
                          : () {
                              if (horarioJaPassou(
                                widget.data,
                                horario,
                                agora: (widget.agora ?? DateTime.now)(),
                              )) {
                                setState(
                                  () => _horariosPassados =
                                      _calcularHorariosPassados(),
                                );
                                return;
                              }
                              Navigator.of(context).pop(horario);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VetCores.rosaEscuro,
                        foregroundColor: VetCores.branco,
                        disabledBackgroundColor: Colors.grey,
                        disabledForegroundColor: VetCores.branco,
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
            if (horarios.isNotEmpty &&
                horarios.every(indisponiveis.contains)) ...[
              const SizedBox(height: 20),
              Text(
                horarios.every(ocupados.contains)
                    ? 'Todos os horários já foram agendados.'
                    : 'Não há horários disponíveis para esta data.',
                textAlign: TextAlign.center,
                style: GoogleFonts.comfortaa(
                  color: VetCores.marrom,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
