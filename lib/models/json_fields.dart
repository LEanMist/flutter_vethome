// Validação de snapshots locais: dados inválidos não viram valores silenciosos.
String jsonString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('Campo inválido: $key');
  return value;
}

String? jsonOptionalString(Map<String, dynamic> json, String key) {
  return json[key] == null ? null : jsonString(json, key);
}

DateTime jsonDate(Map<String, dynamic> json, String key) {
  final text = jsonString(json, key);
  final date = DateTime.tryParse(text);
  // Rejeita também datas normalizadas, como 2026-02-31.
  if (date == null || date.toIso8601String() != text) {
    throw FormatException('Data inválida: $key');
  }
  return date;
}

double? jsonOptionalDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! num || !value.isFinite) {
    throw FormatException('Número inválido: $key');
  }
  return value.toDouble();
}

bool? jsonOptionalBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value != null && value is! bool) {
    throw FormatException('Booleano inválido: $key');
  }
  return value as bool?;
}

int? jsonOptionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value != null && value is! int) {
    throw FormatException('Inteiro inválido: $key');
  }
  return value as int?;
}
