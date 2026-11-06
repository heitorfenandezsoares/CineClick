import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/movie_controller.dart';
import '../models/movie_model.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_view.dart';

/// Tela principal do CineClick: integra busca em tempo real, filtros por avaliação
/// e visualização responsiva de metadados cinematográficos.
class HomeView extends StatefulWidget {
  final MovieController controller;

  const HomeView({super.key, required this.controller});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Dispara a carga inicial assíncrona ao montar o widget
    widget.controller.fetchPopularMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Otimização de requisições de busca através de Debounce (350ms)
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      widget.controller.searchMovies(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.movie_creation_outlined, color: Colors.tealAccent),
            SizedBox(width: 8),
            Text(
              'CineClick',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(115),
          child: Column(
            children: [
              // Barra de Busca em tempo real
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar títulos no TMDb...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.fetchPopularMovies();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Filtro dinâmico por faixa de classificação (evita que notas maiores vazem em categorias menores)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: MovieController.availableFilters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(filter),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      // ListenableBuilder consome as notificações do MovieController
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return switch (widget.controller.state) {
            MovieViewState.initial ||
            MovieViewState.loading =>
              _buildLoadingState(),
            MovieViewState.error => _buildErrorState(
                widget.controller.errorMessage,
                onRetry: () => widget.controller.fetchPopularMovies(),
              ),
            MovieViewState.empty => _buildEmptyState(),
            MovieViewState.success => _buildSuccessGrid(widget.controller.movies),
          };
        },
      ),
    );
  }

  Widget _buildFilterChip(RatingFilter filter) {
    final isSelected = widget.controller.selectedFilter == filter;
    return ChoiceChip(
      label: Text(filter.label),
      selected: isSelected,
      onSelected: (_) => widget.controller.setRatingFilter(filter),
      selectedColor: Colors.tealAccent.withOpacity(0.25),
      labelStyle: TextStyle(
        color: isSelected ? Colors.tealAccent : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Feedback visual de carregamento assíncrono
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Consultando serviços do TMDb...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Feedback visual de erro de rede ou exceção da API
  Widget _buildErrorState(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Falha na Comunicação',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Feedback visual para buscas ou filtros sem correspondência
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum filme encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente ajustar o termo de pesquisa ou reduza os filtros de avaliação.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                widget.controller.resetFilters();
                widget.controller.fetchPopularMovies();
              },
              child: const Text('Redefinir Filtros'),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid responsivo com adaptação automática ao tamanho de tela
  Widget _buildSuccessGrid(List<Movie> movies) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_searchController.text.isNotEmpty) {
          await widget.controller.searchMovies(_searchController.text);
        } else {
          await widget.controller.fetchPopularMovies();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsividade dinâmica: ajusta o número de colunas conforme a largura
          int crossAxisCount = 2;
          if (constraints.maxWidth > 900) {
            crossAxisCount = 5;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: movies.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailView(movie: movie),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
