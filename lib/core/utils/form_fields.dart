String normalizedText(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String? requiredField(String? value) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? 'Campo obrigatório' : null;
}
