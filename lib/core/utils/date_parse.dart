DateTime? parseFlexibleDate(String value) {
  final parts = value.trim().split(RegExp(r'[/.-]'));
  if (parts.length != 3) return DateTime.tryParse(value);
  final a = int.tryParse(parts[0]);
  final b = int.tryParse(parts[1]);
  final c = int.tryParse(parts[2]);
  if (a == null || b == null || c == null) return null;
  final yearFirst = a > 31;
  final date = yearFirst ? DateTime(a, b, c) : DateTime(c, b, a);
  final expectedDay = yearFirst ? c : a;
  if (date.year < 1900 ||
      date.month != b ||
      date.day != expectedDay ||
      date.isAfter(DateTime.now())) {
    return null;
  }
  return date;
}