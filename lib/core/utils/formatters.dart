String _two(int n) => n.toString().padLeft(2, '0');

String fmtData(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';
String fmtDiaMes(DateTime d) => '${_two(d.day)}/${_two(d.month)}';
String fmtHora(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String fmtPeso(double kg) => '${kg.toStringAsFixed(1).replaceAll('.', ',')} kg';

/// 1234.5 -> "R$ 1.234,50"
String fmtMoeda(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final inteiro = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'R\$ $inteiro,${parts[1]}';
}
