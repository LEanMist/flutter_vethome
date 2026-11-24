

class Utils{
 static String formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    final parts = value.split('/');
    if (parts.length != 3) return value;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

   static String limparCpf(String? value) => (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');

   static String limparTelefone(String? value) => (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
   
   static String limparCep(String? value) => (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');

   static String enumNormalizado(String? value) {
    final cleaned = (value ?? '').trim();
    if (cleaned.isEmpty) return '';

    return cleaned
        .toUpperCase()
        .replaceAll('Â', 'A')
        .replaceAll('À', 'A')
        .replaceAll('Á', 'A')
        .replaceAll('Ã', 'A')
        .replaceAll('Ê', 'E')
        .replaceAll('È', 'E')
        .replaceAll('É', 'E')
        .replaceAll('Î', 'I')
        .replaceAll('Ì', 'I')
        .replaceAll('Í', 'I')
        .replaceAll('Ô', 'O')
        .replaceAll('Ò', 'O')
        .replaceAll('Ó', 'O')
        .replaceAll('Õ', 'O')
        .replaceAll('Û', 'U')
        .replaceAll('Ù', 'U')
        .replaceAll('Ú', 'U')
        .replaceAll('Ç', 'C');
  }

}
 