import 'package:flutter/material.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

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

  late DateTime _mesVisivel;
  late DateTime _dataSelecionada;

  DateTime get _mesAtual {
    final hoje = DateTime.now();
    return DateTime(hoje.year, hoje.month);
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
      final diaSelecionado = _dataSelecionada.day > ultimoDia
          ? ultimoDia
          : _dataSelecionada.day;
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
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCalendario = compacto ? 380 : 500.0;
        final double alturaCelula = compacto ? 40 : 80;   
        final double tamanhoFonte = compacto ? 15 : 20;
        final hoje = DateUtils.dateOnly(DateTime.now());
        final primeiroDia = DateTime(_mesVisivel.year, _mesVisivel.month);
        final inicioGrade = DateTime(
          primeiroDia.year,
          primeiroDia.month,
          1 - primeiroDia.weekday % 7,
        );

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Container(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        child: Row(
                          children: [
                            if (_mesVisivel.isAfter(_mesAtual))
                              IconButton(
                                tooltip: 'Mês anterior',
                                onPressed: () => _mudarMes(-1),
                                icon: const Icon(
                                  Icons.chevron_left_rounded,
                                ),
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
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                              ),
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
                            final hojeSelecionado =
                                DateUtils.isSameDay(data, hoje);
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
                                      border: hojeSelecionado &&
                                              !selecionada
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
                                        fontWeight: selecionada
                                            ? FontWeight.bold
                                            : FontWeight.bold,
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
              ),
            ),
          ],
        );
      },
    );
  }
}