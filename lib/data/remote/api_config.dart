import 'api_exception.dart';

class ApiConfig {
  const ApiConfig._({required this.baseUri, required this.timeout});

  static const environmentKey = 'VETHOME_API_BASE_URL';

  /// Lê a URL de `--dart-define=VETHOME_API_BASE_URL=https://...`.
  ///
  /// Somente HTTPS é aceito porque os contratos observados transportam CPF,
  /// telefone e senha. Os endereços HTTP da branch Nicolly permanecem
  /// explicitamente pendentes de substituição por uma origem segura.
  factory ApiConfig.fromEnvironment({
    String baseUrl = const String.fromEnvironment(environmentKey),
    Duration timeout = const Duration(seconds: 10),
  }) {
    final value = baseUrl.trim();
    final uri = Uri.tryParse(value);
    if (value.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ApiException.configuration(
        'Configure $environmentKey com uma URL HTTPS válida.',
      );
    }
    if (uri.scheme.toLowerCase() != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ApiException.configuration(
        '$environmentKey deve usar HTTPS e não pode conter credenciais, '
        'consulta ou fragmento.',
      );
    }
    if (timeout <= Duration.zero) {
      throw ApiException.configuration('O timeout da API deve ser positivo.');
    }
    return ApiConfig._(baseUri: uri, timeout: timeout);
  }

  final Uri baseUri;
  final Duration timeout;

  Uri resolve(String path) {
    final cleanPath = path.replaceFirst(RegExp(r'^/+'), '');
    final prefix = baseUri.path.endsWith('/')
        ? baseUri.path
        : '${baseUri.path}/';
    return baseUri.replace(path: '$prefix$cleanPath');
  }
}
