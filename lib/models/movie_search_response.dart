import 'movie.dart';

class MovieSearchResponse {
  final String? query;
  final int page;
  final int perPage;
  final int totalPages;
  final int totalMovies;
  final String? sortBy;
  final String? sortOrder;
  final List<Movie> movies;

  MovieSearchResponse({
    this.query,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalMovies,
    this.sortBy,
    this.sortOrder,
    required this.movies,
  });

  factory MovieSearchResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing MovieSearchResponse from JSON: $json'); // Debug log
    
    try {
      final query = json['query'] as String?;
      print('Query: $query');
      
      final page = json['page'] as int;
      print('Page: $page');
      
      final perPage = json['per_page'] as int;
      print('Per Page: $perPage');
      
      final totalPages = json['total_pages'] as int;
      print('Total Pages: $totalPages');
      
      final totalMovies = json['total_movies'] as int;
      print('Total Movies: $totalMovies');
      
      final sortBy = json['sort_by'] as String?;
      print('Sort By: $sortBy');
      
      final sortOrder = json['sort_order'] as String?;
      print('Sort Order: $sortOrder');
      
      final movies = (json['movies'] as List<dynamic>)
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
      print('Movies count: ${movies.length}');
      
      return MovieSearchResponse(
        query: query,
        page: page,
        perPage: perPage,
        totalPages: totalPages,
        totalMovies: totalMovies,
        sortBy: sortBy,
        sortOrder: sortOrder,
        movies: movies,
      );
    } catch (e, stackTrace) {
      print('Error parsing MovieSearchResponse: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
} 