class Movie {
  final int? movieId;
  final int? tmdbId;
  final String? imdbId;
  final String? title;
  final String? originalTitle;
  final String? overview;
  final String? tagline;
  final String? releaseDate;
  final int? runtime;
  final int? budget;
  final int? revenue;
  final double? popularity;
  final double? voteAverage;
  final int? voteCount;
  final String? status;
  final int? adult;
  final int? video;
  final String? posterPath;
  final String? backdropPath;
  final String? homepage;
  final String? originalLanguage;
  final List<String>? genres;
  final List<String>? productionCompanies;
  final List<String>? productionCountries;
  final List<String>? spokenLanguages;
  final Map<String, dynamic>? belongsToCollection;
  final double? predictedRating;

  Movie({
    this.movieId,
    this.tmdbId,
    this.imdbId,
    this.title,
    this.originalTitle,
    this.overview,
    this.tagline,
    this.releaseDate,
    this.runtime,
    this.budget,
    this.revenue,
    this.popularity,
    this.voteAverage,
    this.voteCount,
    this.status,
    this.adult,
    this.video,
    this.posterPath,
    this.backdropPath,
    this.homepage,
    this.originalLanguage,
    this.genres,
    this.productionCompanies,
    this.productionCountries,
    this.spokenLanguages,
    this.belongsToCollection,
    this.predictedRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      movieId: json['movie_id'],
      tmdbId: json['tmdb_id'],
      imdbId: json['imdb_id'],
      title: json['title'],
      originalTitle: json['original_title'],
      overview: json['overview'],
      tagline: json['tagline'],
      releaseDate: json['release_date'],
      runtime: json['runtime'],
      budget: json['budget'],
      revenue: json['revenue'],
      popularity: json['popularity']?.toDouble(),
      voteAverage: json['vote_average']?.toDouble(),
      voteCount: json['vote_count'],
      status: json['status'],
      adult: json['adult'],
      video: json['video'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      homepage: json['homepage'],
      originalLanguage: json['original_language'],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      productionCompanies:
          json['production_companies'] != null
              ? List<String>.from(json['production_companies'])
              : null,
      productionCountries:
          json['production_countries'] != null
              ? List<String>.from(json['production_countries'])
              : null,
      spokenLanguages:
          json['spoken_languages'] != null
              ? List<String>.from(json['spoken_languages'])
              : null,
      belongsToCollection: json['belongs_to_collection'],
      predictedRating: json['predicted_rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movie_id': movieId,
      'tmdb_id': tmdbId,
      'imdb_id': imdbId,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'tagline': tagline,
      'release_date': releaseDate,
      'runtime': runtime,
      'budget': budget,
      'revenue': revenue,
      'popularity': popularity,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'status': status,
      'adult': adult,
      'video': video,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'homepage': homepage,
      'original_language': originalLanguage,
      'genres': genres,
      'production_companies': productionCompanies,
      'production_countries': productionCountries,
      'spoken_languages': spokenLanguages,
      'belongs_to_collection': belongsToCollection,
      'predicted_rating': predictedRating,
    };
  }

  // Helper getters
  String get year {
    final yearMatch = RegExp(r'\((\d{4})\)').firstMatch(title ?? '');
    return yearMatch?.group(1) ?? '';
  }

  String get cleanTitle {
    return (title ?? '').replaceAll(RegExp(r'\(\d{4}\)'), '').trim();
  }
}
