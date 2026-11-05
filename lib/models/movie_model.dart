/// Entidade orientada a objetos representando um filme.
///
/// Implementa a desserialização e serialização de dados no formato JSON,
/// convertendo o payload recebido do endpoint REST do TMDb em atributos tipados.
class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
  });

  /// Factory constructor para desserialização do JSON (payload bruto da API).
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Sem título',
      overview: (json['overview'] as String?)?.isNotEmpty == true
          ? json['overview'] as String
          : 'Sinopse indisponível.',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String? ?? 'Data não informada',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );
  }

  /// Serialização do objeto em Map estruturado (para persistência ou envio).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'genre_ids': genreIds,
    };
  }

  /// Retorna a URL completa para download do pôster cinematográfico em resolução w500.
  String get fullPosterUrl => posterPath != null && posterPath!.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : 'https://via.placeholder.com/500x750?text=Sem+Poster';

  /// Retorna a URL completa da imagem de fundo (backdrop).
  String get fullBackdropUrl => backdropPath != null && backdropPath!.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : fullPosterUrl;

  /// Formatação do ano de lançamento para rápida visualização na interface.
  String get releaseYear {
    if (releaseDate.length >= 4) {
      return releaseDate.substring(0, 4);
    }
    return releaseDate;
  }
}
