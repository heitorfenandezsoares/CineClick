import 'package:flutter/material.dart';
import '../models/movie_model.dart';

/// Tela de detalhes com apresentação aprofundada dos metadados cinematográficos.
class MovieDetailView extends StatelessWidget {
  final Movie movie;

  const MovieDetailView({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar expansível com imagem de destaque (Backdrop)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 8),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.fullBackdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.movie, size: 64, color: Colors.grey),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Conteúdo detalhado dos metadados
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha com avaliação, ano e contagem de votos
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 18, color: Colors.black87),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 14),
                        label: Text(movie.releaseDate),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        avatar: const Icon(Icons.thumb_up, size: 14),
                        label: Text('${movie.voteCount} votos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sinopse',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Informações de integração com sistemas distribuídos
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Origem dos Metadados (REST TMDb):',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID do Recurso: ${movie.id} • Endpoint: /movie/${movie.id}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
