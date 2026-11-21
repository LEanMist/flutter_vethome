import 'package:flutter/material.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

class SeletorHorario extends StatelessWidget {
  const SeletorHorario({
    super.key,
    required this.data,
    required this.horarios,
    this.horariosOcupados = const {},
    this.larguraMaxima = 430,
    this.larguraBotao = 90,
    this.alturaBotao = 48,
  }) : assert(larguraMaxima > 0),
       assert(larguraBotao > 0),
       assert(alturaBotao > 0);

  final DateTime data;
  final List<String> horarios;
  final Set<String> horariosOcupados;
  final double larguraMaxima;
  final double larguraBotao;
  final double alturaBotao;

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
    final diaDaSemana = _diasDaSemana[data.weekday % 7];
    final dataFormatada =
        '${data.day} - $diaDaSemana, ${_meses[data.month - 1]} ${data.year}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: larguraMaxima),
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
                    width: larguraBotao,
                    height: alturaBotao,
                    child: ElevatedButton(
                      key: ValueKey('horario-$horario'),
                      onPressed: horariosOcupados.contains(horario)
                          ? null
                          : () => Navigator.of(context).pop(horario),
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
                horarios.every(horariosOcupados.contains)) ...[
              const SizedBox(height: 20),
              Text(
                'Todos os horários já foram agendados.',
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
