enum ApiExceptionKind { configuration, network, timeout, http }

/// Erro seguro da camada remota.
///
/// Não armazena corpo de resposta, payload, CPF, senha ou outros dados
/// pessoais. Detalhes de contrato continuam pendentes de confirmação.
class ApiException implements Exception {
  const ApiException._(this.kind, this.message, {this.statusCode});

  factory ApiException.configuration(String message) =>
      ApiException._(ApiExceptionKind.configuration, message);

  factory ApiException.network() => const ApiException._(
    ApiExceptionKind.network,
    'Não foi possível acessar o serviço do VetHome.',
  );

  factory ApiException.timeout() => const ApiException._(
    ApiExceptionKind.timeout,
    'O serviço do VetHome não respondeu dentro do prazo.',
  );

  factory ApiException.http(int statusCode) => ApiException._(
    ApiExceptionKind.http,
    'O serviço do VetHome rejeitou a solicitação.',
    statusCode: statusCode,
  );

  final ApiExceptionKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'ApiException(${kind.name}): $message'
      : 'ApiException(${kind.name}, status $statusCode): $message';
}
