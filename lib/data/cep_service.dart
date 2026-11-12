class CepResult {
  const CepResult({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;
}

class CepService {
  const CepService();

  Future<CepResult?> lookup(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    return CepResult(street: '', city: '');
  }
}
