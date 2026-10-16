

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

}
 