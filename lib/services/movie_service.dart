import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/movie_review.dart';
import '../models/movie_search_response.dart';
import 'storage_service.dart';
import '../models/credits.dart';
import 'package:streamly/config/api_config.dart';

class MovieService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Singleton pattern
  static final MovieService _instance = MovieService._internal();
  factory MovieService() => _instance;
  MovieService._internal();

  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/movies/genre/$genre'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Movie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Si el token no es válido, lo eliminamos
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
      print('Error in getMoviesByGenre: $e');
      return [];
    }
  }

  Future<List<Movie>> getUserRecommendations(String id) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
        body: jsonEncode({
          'n_recommendations': 10, // Default number of recommendations
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> recommendations = data['recommendations'];
        return recommendations.map((json) => Movie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
      print('Error in getUserRecommendations: $e');
      return [];
    }
  }

  Future<List<Movie>> getRecommendationsFromMovies(int id) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/movie/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
        body: jsonEncode({
          'n_recommendations': 10, // Default number of recommendations
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> recommendations = data['recommendations'];
        return recommendations.map((json) => Movie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
      print('Error in getUserRecommendations: $e');
      return [];
    }
  }

  Future<List<Movie>> getUserWorstRecommendations(String id) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.post(
        Uri.parse('$_baseUrl/worstrecommendations/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
        body: jsonEncode({
          'n_recommendations': 10, // Default number of recommendations
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> recommendations = data['recommendations'];
        return recommendations.map((json) => Movie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
      print('Error in getUserRecommendations: $e');
      return [];
    }
  }

  Future<List<Movie>> getTopMovies() async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/top-movies'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Movie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
      print('Error in getTopMovies: $e');
      return [];
    }
  }

  Future<MovieReviewsResponse> getMovieReviews(int movieId) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/movies/$movieId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MovieReviewsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  Future<Map<String, dynamic>> postMovieReview(
    int movieId,
    double rating,
    String description,
  ) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/movies/$movieId/review'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
        body: jsonEncode({
          'rating': rating.toInt(),
          'movie_id': movieId,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        throw Exception('Unauthorized');
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Invalid review data');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to post review');
      }
    } catch (e) {
      throw Exception('Failed to post review: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query, {String? tipo}) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No token found');
      }

      print('Searching for: $query'); // Debug log

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/api/search?query=$query${tipo != null ? '&tipo=$tipo' : ''}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final List<dynamic> results = data['resultados'];
          return results.map((json) => Movie.fromJson(json)).toList();
        } catch (e, stackTrace) {
          print('Error parsing response: $e');
          print('Stack trace: $stackTrace');
          throw Exception('Failed to parse search response: $e');
        }
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        return []; // Return empty list for no results
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to search movies');
      }
    } catch (e, stackTrace) {
      print('Error in searchMovies: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to search movies: $e');
    }
  }

  Future<Credits> getMovieCredits(int movieId) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No token found');
      }

      print('Fetching credits for movie ID: $movieId'); // Debug log

      final response = await http.get(
        Uri.parse('$_baseUrl/api/movies/$movieId/credits'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('Decoded JSON data: $data'); // Debug log
          return Credits.fromJson(data);
        } catch (e, stackTrace) {
          print('Error parsing response: $e');
          print('Stack trace: $stackTrace');
          throw Exception('Failed to parse credits response: $e');
        }
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        throw Exception('Movie not found');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to get movie credits');
      }
    } catch (e, stackTrace) {
      print('Error in getMovieCredits: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get movie credits: $e');
    }
  }

  Future<Map<String, dynamic>> registerWatchedMovie(int movieId) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No hay sesión activa');
      }

      final userId = token['user_id'];
      if (userId == null) {
        throw Exception('ID de usuario no encontrado');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/user/film'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
        body: jsonEncode({'user_id': int.parse(userId), 'movie_id': movieId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permiso para realizar esta acción');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error al registrar la película');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Movie>> getSvdRecommendations(String userId) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/svd/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> recommendations = data['recommendations'];
        return recommendations.map((json) => Movie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
      print('Error in getSvdRecommendations: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGenreRecommendations(
    String userId,
  ) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/genres/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> recommendations = data['recommended_genres'];
        return recommendations
            .map(
              (json) => {
                'genre_id': json['genre_id'],
                'name': json['name'],
                'predicted_score': json['predicted_score'],
                'already_seen': json['already_seen'],
                'view_count': json['view_count'],
              },
            )
            .toList();
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
      print('Error in getGenreRecommendations: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserWatchHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/api/user/watch-history?limit=$limit&offset=$offset',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'total_movies': data['total_movies'],
          'current_page': data['current_page'],
          'total_pages': data['total_pages'],
          'movies':
              (data['movies'] as List)
                  .map((json) => Movie.fromJson(json))
                  .toList(),
        };
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to load watch history');
      }
    } catch (e) {
      throw Exception('Failed to load watch history: $e');
    }
  }
}
