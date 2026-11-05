import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';
import 'api_exceptions.dart';

/// Serviço responsável pelo consumo assíncrono dos serviços web RESTful do The Movie Database (TMDb)
/// utilizando o protocolo seguro HTTPS.
class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  
  // Chave da API TMDb (pode ser substituída por variável de ambiente ou chave própria do estudante)
  final String apiKey;
  final http.Client _client;

  TmdbService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Headers padrão para as requisições HTTP REST
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };

  /// Obtém a lista de filmes populares (metadados cinematográficos em tempo real).
  Future<List<Movie>> getPopularMovies({int page = 1, String language = 'pt-BR'}) async {
    final uri = Uri.parse('$_baseUrl/movie/popular').replace(
      queryParameters: {
        'api_key': apiKey,
        'language': language,
        'page': page.toString(),
      },
    );

    return _performGetRequest(uri);
  }

  /// Realiza a busca de filmes por termo/palavra-chave com suporte a paginação.
  Future<List<Movie>> searchMovies({
    required String query,
    int page = 1,
    String language = 'pt-BR',
  }) async {
    if (query.trim().isEmpty) {
      return getPopularMovies(page: page, language: language);
    }

    final uri = Uri.parse('$_baseUrl/search/movie').replace(
      queryParameters: {
        'api_key': apiKey,
        'query': query,
        'language': language,
        'page': page.toString(),
        'include_adult': 'false',
      },
    );

    return _performGetRequest(uri);
  }

  /// Método encapsulado para execução de requisições GET com tratamento de exceções de rede.
  Future<List<Movie>> _performGetRequest(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> results = decodedData['results'] as List<dynamic>? ?? [];

        // Desserialização mapeada: JSON bruto -> Lista de Entidades Movie
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw const ServerResponseException(
          401,
          'Chave de API inválida ou não autorizada. Verifique suas credenciais do TMDb.',
        );
      } else {
        throw ServerResponseException(
          response.statusCode,
          'Erro na comunicação com o TMDb. Código HTTP: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const NetworkConnectionException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on FormatException {
      throw const DataParsingException();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkConnectionException('Falha inesperada de rede: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
