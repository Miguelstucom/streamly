import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../theme/app_theme.dart';
import 'movie_detail_screen.dart';

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  final _movieService = MovieService();
  List<Movie> _movies = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  int _totalPages = 1;
  static const int _moviesPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadWatchHistory();
  }

  Future<void> _loadWatchHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final result = await _movieService.getUserWatchHistory(
        limit: _moviesPerPage,
        offset: (_currentPage - 1) * _moviesPerPage,
      );

      if (mounted) {
        setState(() {
          _movies = result['movies'];
          _totalPages = result['total_pages'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el historial: $e'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    setState(() {
      _currentPage = page;
    });
    _loadWatchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Películas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), AppTheme.backgroundColor],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child:
                  _hasError
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Error al cargar el historial',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadWatchHistory,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                      : _movies.isEmpty && !_isLoading
                      ? const Center(
                        child: Text(
                          'No hay películas en tu historial',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                      : _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: Colors.grey[900],
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    movie.posterPath != null
                                        ? Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                          width: 60,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 60,
                                              height: 90,
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.movie,
                                                color: Colors.white54,
                                              ),
                                            );
                                          },
                                        )
                                        : Container(
                                          width: 60,
                                          height: 90,
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.movie,
                                            color: Colors.white54,
                                          ),
                                        ),
                              ),
                              title: Text(
                                movie.cleanTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        movie.voteAverage?.toStringAsFixed(1) ??
                                            'N/A',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        movie.year,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            MovieDetailScreen(movie: movie),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
            if (!_isLoading && !_hasError && _movies.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed:
                          _currentPage > 1
                              ? () => _goToPage(_currentPage - 1)
                              : null,
                      icon: const Icon(Icons.chevron_left),
                      color: _currentPage > 1 ? Colors.white : Colors.grey,
                    ),
                    Text(
                      'Página $_currentPage de $_totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _currentPage < _totalPages
                              ? () => _goToPage(_currentPage + 1)
                              : null,
                      icon: const Icon(Icons.chevron_right),
                      color:
                          _currentPage < _totalPages
                              ? Colors.white
                              : Colors.grey,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
