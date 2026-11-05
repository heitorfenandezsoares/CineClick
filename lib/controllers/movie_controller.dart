import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../services/api_exceptions.dart';
import '../services/tmdb_service.dart';

/// Enumeração dos estados possíveis da interface para controle de fluxo e feedback visual.
enum MovieViewState { initial, loading, success, empty, error }

/// Controlador de estado da aplicação CineClick fundamentado no padrão ChangeNotifier.
/// Gerencia as requisições assíncronas, filtragem local e os estados de renderização da GUI.
class MovieController extends ChangeNotifier {
  final TmdbService _service;

  MovieController({required TmdbService service}) : _service = service;

  MovieViewState _state = MovieViewState.initial;
  MovieViewState get state => _state;

  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  List<Movie> get movies => _filteredMovies;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  double _minRatingFilter = 0.0;
  double get minRatingFilter => _minRatingFilter;

  /// Carrega filmes populares consumindo a API REST de forma assíncrona.
  Future<void> fetchPopularMovies() async {
    _setState(MovieViewState.loading);
    _currentQuery = '';

    try {
      final results = await _service.getPopularMovies();
      _allMovies = results;
      _applyLocalFilters();

      if (_filteredMovies.isEmpty) {
        _setState(MovieViewState.empty);
      } else {
        _setState(MovieViewState.success);
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setState(MovieViewState.error);
    } catch (e) {
      _errorMessage = 'Ocorreu um erro inesperado: $e';
      _setState(MovieViewState.error);
    }
  }

  /// Realiza a busca assíncrona em tempo real conforme a digitação do usuário.
  Future<void> searchMovies(String query) async {
    _currentQuery = query;

    if (query.trim().isEmpty) {
      return fetchPopularMovies();
    }

    _setState(MovieViewState.loading);

    try {
      final results = await _service.searchMovies(query: query);
      _allMovies = results;
      _applyLocalFilters();

      if (_filteredMovies.isEmpty) {
        _setState(MovieViewState.empty);
      } else {
        _setState(MovieViewState.success);
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setState(MovieViewState.error);
    } catch (e) {
      _errorMessage = 'Falha ao pesquisar filmes: $e';
      _setState(MovieViewState.error);
    }
  }

  /// Filtro dinâmico local por avaliação mínima (nota média TMDb).
  void setRatingFilter(double minRating) {
    _minRatingFilter = minRating;
    _applyLocalFilters();
    if (_filteredMovies.isEmpty && _state == MovieViewState.success) {
      _setState(MovieViewState.empty);
    } else if (_filteredMovies.isNotEmpty && _state == MovieViewState.empty) {
      _setState(MovieViewState.success);
    } else {
      notifyListeners();
    }
  }

  void _applyLocalFilters() {
    if (_minRatingFilter <= 0.0) {
      _filteredMovies = List.from(_allMovies);
    } else {
      _filteredMovies = _allMovies
          .where((movie) => movie.voteAverage >= _minRatingFilter)
          .toList();
    }
  }

  void _setState(MovieViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
