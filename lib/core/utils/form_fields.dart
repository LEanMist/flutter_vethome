import 'package:flutter/services.dart';

class DigitsMask extends TextInputFormatter {
  const DigitsMask(this.pattern);
  final String pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final count = pattern.split('').where((c) => c == '#').length;
    final value = digits.substring(0, digits.length.clamp(0, count));
    final out = StringBuffer();
    var index = 0;
    for (final char in pattern.split('')) {
      if (index >= value.length) break;
      if (char == '#') {
        out.write(value[index++]);
      } else {
        out.write(char);
      }
    }
    final text = out.toString();
    final digitsBefore = newValue.text
        .substring(
          0,
          newValue.selection.extentOffset.clamp(0, newValue.text.length),
        )
        .replaceAll(RegExp(r'\D'), '')
        .length;
    var cursor = 0, seen = 0;
    while (cursor < text.length && seen < digitsBefore) {
      if (RegExp(r'\d').hasMatch(text[cursor])) seen++;
      cursor++;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}

class PhoneMask extends TextInputFormatter {
  const PhoneMask();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final length = newValue.text.replaceAll(RegExp(r'\D'), '').length;
    return DigitsMask(
      length <= 10 ? '(##) ####-####' : '(##) #####-####',
    ).formatEditUpdate(oldValue, newValue);
  }
}

DateTime? parseBirthDate(String text) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
  if (match == null) return null;
  final day = int.parse(match[1]!),
      month = int.parse(match[2]!),
      year = int.parse(match[3]!);
  final date = DateTime(year, month, day);
  return year >= 1900 &&
          date.day == day &&
          date.month == month &&
          !date.isAfter(DateTime.now())
      ? date
      : null;
}

String normalizedText(String text) {
  const accents = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const plain = 'aaaaaeeeeiiiiooooouuuuc';
  var result = text.toLowerCase().trim();
  for (var i = 0; i < accents.length; i++) {
    result = result.replaceAll(accents[i], plain[i]);
  }
  return result;
}

List<String> breedsFor(String species) => species.toLowerCase().contains('gato')
    ? const [
        'SRD / Sem raça definida',
        'Siamês',
        'Persa',
        'Maine Coon',
        'Ragdoll',
        'Bengal',
        'Sphynx',
        'British Shorthair',
      ]
    : const [
        'SRD / Sem raça definida',
        'Golden Retriever',
        'Labrador Retriever',
        'Lulu da Pomerânia',
        'Poodle',
        'Shih Tzu',
        'Yorkshire Terrier',
        'Bulldog',
        'Beagle',
        'Pastor Alemão',
        'Dachshund',
        'Rottweiler',
        'Border Collie',
      ];
