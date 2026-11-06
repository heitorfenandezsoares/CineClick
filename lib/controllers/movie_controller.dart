import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../services/api_exceptions.dart';
import '../services/tmdb_service.dart';

/// Enumeração dos estados possíveis da interface para controle de fluxo e feedback visual.
enum MovieViewState { initial, loading, success, empty, error }

/// Modelo de filtro por faixa de avaliação (rating).
class RatingFilter {
  final String label;
  final double? min;
  final double? max;

  const RatingFilter({
    required this.label,
    this.min,
    this.max,
  });

  /// Verifica se a nota do filme pertence à faixa estrita do filtro.
  bool matches(double rating) {
    if (min != null && rating < min!) return false;
    if (max != null) {
      // Se for o teto máximo (10.0), inclui o valor igual; caso contrário, intervalo semiaberto [min, max)
      if (max! >= 10.0) {
        if (rating > max!) return false;
      } else {
        if (rating >= max!) return false;
      }
    }
    return true;
  }
}

/// Controlador de estado da aplicação CineClick fundamentado no padrão ChangeNotifier.
/// Gerencia as requisições assíncronas, filtragem local e os estados de renderização da GUI.
class MovieController extends ChangeNotifier {
  final TmdbService _service;

  MovieController({required TmdbService service}) : _service = service;

  static const List<RatingFilter> availableFilters = [
    RatingFilter(label: 'Todos'),
    RatingFilter(label: '★ 5.0 - 5.9', min: 5.0, max: 6.0),
    RatingFilter(label: '★ 6.0 - 6.9', min: 6.0, max: 7.0),
    RatingFilter(label: '★ 7.0 - 7.9', min: 7.0, max: 8.0),
    RatingFilter(label: '★ 8.0+', min: 8.0, max: 10.0),
  ];

  MovieViewState _state = MovieViewState.initial;
  MovieViewState get state => _state;

  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  List<Movie> get movies => _filteredMovies;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  RatingFilter _selectedFilter = availableFilters[0];
  RatingFilter get selectedFilter => _selectedFilter;

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

  /// Filtro dinâmico local por faixa de avaliação (nota TMDb).
  void setRatingFilter(RatingFilter filter) {
    _selectedFilter = filter;
    _applyLocalFilters();
    if (_filteredMovies.isEmpty && _state == MovieViewState.success) {
      _setState(MovieViewState.empty);
    } else if (_filteredMovies.isNotEmpty && _state == MovieViewState.empty) {
      _setState(MovieViewState.success);
    } else {
      notifyListeners();
    }
  }

  /// Redefine a filtragem de avaliação para exibir todos os títulos.
  void resetFilters() {
    _selectedFilter = availableFilters[0];
    _applyLocalFilters();
  }

  void _applyLocalFilters() {
    if (_selectedFilter.min == null && _selectedFilter.max == null) {
      _filteredMovies = List.from(_allMovies);
    } else {
      _filteredMovies = _allMovies
          .where((movie) => _selectedFilter.matches(movie.voteAverage))
          .toList();
    }
  }

  void _setState(MovieViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
