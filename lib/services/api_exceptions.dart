/// Exceções customizadas para captura e tratamento sistemático de erros
/// na camada de comunicação de rede do cliente CineClick.
sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Disparada em caso de falha de conexão física, DNS ou ausência de internet.
class NetworkConnectionException extends ApiException {
  const NetworkConnectionException([
    String message = 'Sem conexão com a internet. Verifique sua rede e tente novamente.',
  ]) : super(message);
}

/// Disparada quando o tempo limite de requisição expira.
class RequestTimeoutException extends ApiException {
  const RequestTimeoutException([
    String message = 'O servidor demorou muito para responder. Tente novamente em instantes.',
  ]) : super(message);
}

/// Disparada quando o servidor TMDb retorna status HTTP 4xx ou 5xx.
class ServerResponseException extends ApiException {
  final int statusCode;
  const ServerResponseException(
    this.statusCode, [
    String message = 'Falha ao processar requisição no servidor.',
  ]) : super(message);
}

/// Disparada em caso de falha de decodificação do payload JSON.
class DataParsingException extends ApiException {
  const DataParsingException([
    String message = 'Erro ao processar e converter a resposta dos dados.',
  ]) : super(message);
}
