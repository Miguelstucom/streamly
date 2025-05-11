class Movie {
  final int movieId;
  final String title;
  final List<String> genres;
  final String? titleFeatures;
  final int ratingCount;
  final double ratingMean;
  final String? posterPath;
  final String? overview;
  final String? backdropPath;

  Movie({
    required this.movieId,
    required this.title,
    required this.genres,
    this.titleFeatures,
    required this.ratingCount,
    required this.ratingMean,
    this.posterPath,
    this.overview,
    this.backdropPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      movieId: json['movieId'],
      title: json['title'],
      genres: (json['genres'] as String).split('|'),
      titleFeatures: json['title_features'] as String?,
      ratingCount: json['rating_count'],
      ratingMean: (json['rating_mean'] as num).toDouble(),
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String?,
      backdropPath: json['backdrop_path'] as String?,
    );
  }

  // Helper getters
  String get year {
    final yearMatch = RegExp(r'\((\d{4})\)').firstMatch(title);
    return yearMatch?.group(1) ?? '';
  }

  String get cleanTitle {
    return title.replaceAll(RegExp(r'\(\d{4}\)'), '').trim();
  }
} 