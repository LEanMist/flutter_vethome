String _two(int n) => n.toString().padLeft(2, '0');

String fmtData(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';
String fmtDiaMes(DateTime d) => '${_two(d.day)}/${_two(d.month)}';
String fmtHora(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
String fmtHorario(DateTime start, DateTime? end) =>
    end == null ? fmtHora(start) : '${fmtHora(start)} — ${fmtHora(end)}';

String fmtPeso(double kg) => '${kg.toStringAsFixed(1).replaceAll('.', ',')} kg';

int ageInYears(DateTime birthDate, DateTime today) {
  final years = today.year - birthDate.year;
  final birthdayPending =
      today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day);
  return birthdayPending ? years - 1 : years;
}
