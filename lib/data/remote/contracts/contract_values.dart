String observedDate(String? value) {
  if (value == null || value.isEmpty) return '';
  final parts = value.split('/');
  if (parts.length != 3) return value;
  return '${parts[2]}-${parts[1]}-${parts[0]}';
}

String observedDigits(String? value) =>
    (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
