import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/movie_review.dart';
import '../models/movie_search_response.dart';
import 'storage_service.dart';

class MovieService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/movies/genre/$genre'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> movies = data['movies'];
        return movies.map((json) => Movie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Si el token no es válido, lo eliminamos
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> getTopMovies() async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/movies/top-rated'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> movies = data['movies'];
        return movies.map((json) => Movie.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        return [];
      }
      return [];
    } catch (e) {
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
        Uri.parse('$baseUrl/movies/$movieId/reviews'),
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

  Future<Map<String, dynamic>> postMovieReview(int movieId, double rating, String description) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/movies/$movieId/review'),
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

  Future<MovieSearchResponse> searchMovies(String query) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No token found');
      }

      print('Searching for: $query'); // Debug log

      final response = await http.post(
        Uri.parse('$baseUrl/movies/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
        body: jsonEncode({
          'query': query,
        }),
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('Decoded JSON data: $data'); // Debug log
          final searchResponse = MovieSearchResponse.fromJson(data);
          print('Parsed movies count: ${searchResponse.movies.length}'); // Debug log
          return searchResponse;
        } catch (e, stackTrace) {
          print('Error parsing response: $e');
          print('Stack trace: $stackTrace');
          throw Exception('Failed to parse search response: $e');
        }
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        throw Exception('Unauthorized');
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
} 