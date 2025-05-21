import 'package:flutter/material.dart';
import 'package:streamly/models/movie.dart';
import 'package:streamly/screens/movie_detail_screen.dart';
import 'package:streamly/services/movie_service.dart';
import 'package:streamly/widgets/skeleton.dart';
import 'package:streamly/widgets/skeleton_movie_card.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _authService = AuthService();
  final _movieService = MovieService();
  final _searchController = TextEditingController();
  User? _user;
  Map<String, List<Movie>> _moviesByGenre = {};
  List<Movie> _topMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _recommendedMovies = [];
  List<Movie> _worstrecommendedMovies = [];
  List<Movie> _svdRecommendations = [];
  List<Map<String, dynamic>> _genreRecommendations = [];
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  bool _isLoading = true;
  bool _isSearching = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalMovies = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      print('Starting search for: $query'); // Debug log
      final movies = await _movieService.searchMovies(query);
      print('Search response received: ${movies.length} movies'); // Debug log

      if (mounted) {
        setState(() {
          _searchResults = movies;
        });
        print(
          'State updated with ${_searchResults.length} movies',
        ); // Debug log
      }
    } catch (e) {
      print('Error in _searchMovies: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar películas: $e'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (!mounted) return;

      setState(() {
        _user = user;
      });

      // Load top-rated movies
      final topMovies = await _movieService.getTopMovies();
      if (!mounted) return;
      setState(() {
        _topMovies = topMovies;
      });

      // Get genre recommendations
      final genreRecommendations = await _movieService.getGenreRecommendations(
        user!.userId,
      );

      // Load movies for recommended genres
      for (final genre in genreRecommendations) {
        final movies = await _movieService.getMoviesByGenre(genre['name']);
        if (!mounted) return;
        setState(() {
          _moviesByGenre[genre['name']] = movies;
        });
      }

      // Load movies for user's favorite genres (only if they exist)
      if (user.preferredGenres != null) {
        for (final genre in user.preferredGenres!) {
          // Skip if this genre is already in recommended genres
          if (genreRecommendations.any((g) => g['name'] == genre)) continue;

          final movies = await _movieService.getMoviesByGenre(genre);
          if (!mounted) return;
          setState(() {
            _moviesByGenre[genre] = movies;
          });
        }
      }

      final recommendedMovies = await _movieService.getUserRecommendations(
        user.userId,
      );

      final worstrecommendedMovies = await _movieService
          .getUserWorstRecommendations(user.userId);

      final svdRecommendations = await _movieService.getSvdRecommendations(
        user.userId,
      );

      if (!mounted) return;
      setState(() {
        _recommendedMovies = recommendedMovies;
        _worstrecommendedMovies = worstrecommendedMovies;
        _svdRecommendations = svdRecommendations;
        _genreRecommendations = genreRecommendations;
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al cargar los datos'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print(
      'Building HomeScreen with search results: ${_searchResults.length}',
    ); // Debug log
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), AppTheme.backgroundColor],
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? _buildSkeletonLoading()
                  : FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/logo.png",
                                height: 55,
                                width: 55,
                              ),
                              Text(
                                'Welcome, ${_user?.firstName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Search Bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Search movies...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                              ? IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  _searchMovies('');
                                                },
                                              )
                                              : null,
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        _searchMovies('');
                                      }
                                    },
                                    onSubmitted: _searchMovies,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Search Results
                                if (_isSearching) ...[
                                  _buildSectionHeader(
                                    'Search Results',
                                    subtitle:
                                        _searchController.text.isNotEmpty
                                            ? 'Results for "${_searchController.text}"'
                                            : null,
                                  ),
                                  if (_searchResults.isEmpty)
                                    const Center(
                                      child: Text(
                                        'No movies found',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  else ...[
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.6,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                          ),
                                      itemCount: _searchResults.length,
                                      itemBuilder: (context, index) {
                                        return buildMovieCard(
                                          _searchResults[index],
                                        );
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 32),
                                ],

                                // Top 10 Movies section
                                if (!_isSearching && _topMovies.isNotEmpty) ...[
                                  _buildSectionHeader('Top 10 Films'),
                                  SizedBox(
                                    height: 400,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          _topMovies.length > 10
                                              ? 10
                                              : _topMovies.length,
                                      itemBuilder: (context, index) {
                                        return _buildTopMovieCard(
                                          _topMovies[index],
                                          index + 1,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],

                                // Add this section after the search results and before the Top 10 Movies section
                                if (!_isSearching &&
                                    _recommendedMovies.isNotEmpty) ...[
                                  _buildSectionHeader(
                                    'Personalized Recommendations',
                                  ),
                                  SizedBox(
                                    height: 280,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _recommendedMovies.length,
                                      itemBuilder: (context, index) {
                                        return buildMovieCard(
                                          _recommendedMovies[index],
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                                if (!_isSearching &&
                                    _recommendedMovies.isNotEmpty) ...[
                                  _buildSectionHeader('Maybe You\'ll Like'),
                                  SizedBox(
                                    height: 280,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _worstrecommendedMovies.length,
                                      itemBuilder: (context, index) {
                                        return buildMovieCard(
                                          _worstrecommendedMovies[index],
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],

                                // Add SVD recommendations section
                                if (!_isSearching &&
                                    _svdRecommendations.isNotEmpty) ...[
                                  _buildSectionHeader('Users Like You Watched'),
                                  SizedBox(
                                    height: 280,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _svdRecommendations.length,
                                      itemBuilder: (context, index) {
                                        return buildMovieCard(
                                          _svdRecommendations[index],
                                        );
                                      },
                                    ),
                                  ),

                                ],

                                // Add recommended genres section
                                if (!_isSearching &&
                                    _genreRecommendations.isNotEmpty) ...[
                                  _buildSectionHeader(''),
                                  ..._genreRecommendations.map((genre) {
                                    final genreName = genre['name'] as String;
                                    final movies =
                                        _moviesByGenre[genreName] ?? [];
                                    if (movies.isEmpty)
                                      return const SizedBox.shrink();

                                    return _buildGenreSection(
                                      genreName,
                                      movies,
                                      viewCount: '${genre['view_count']} views',
                                    );
                                  }).toList(),
                                ],

                                // Show favorite genres that are not in recommended genres
                                if (!_isSearching &&
                                    _user?.preferredGenres != null) ...[
                                  ..._user!.preferredGenres!
                                      .where(
                                        (genre) =>
                                            !_genreRecommendations.any(
                                              (g) => g['name'] == genre,
                                            ),
                                      )
                                      .map((genre) {
                                        final movies =
                                            _moviesByGenre[genre] ?? [];
                                        if (movies.isEmpty)
                                          return const SizedBox.shrink();

                                        return _buildGenreSection(
                                          genre,
                                          movies,
                                        );
                                      })
                                      .toList(),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Skeleton(width: 200, height: 24),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top 10 Movies skeleton
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 150, height: 32),
                    Skeleton(width: 100, height: 32),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Genre sections skeletons
                ...List.generate(3, (index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(width: 150, height: 24),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return const SkeletonMovieCard();
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopMovieCard(Movie movie, int position) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            // Movie poster
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  movie.posterPath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          '$_imageBaseUrl${movie.posterPath}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.movie,
                                size: 64,
                                color: Colors.white54,
                              ),
                            );
                          },
                        ),
                      )
                      : const Center(
                        child: Icon(
                          Icons.movie,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
            ),
            // Gradient overlay
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            // Position indicator
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    position.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Movie info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.cleanTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${movie.voteCount})',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          movie.year,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      movie.posterPath != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              '$_imageBaseUrl${movie.posterPath}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.movie,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                );
                              },
                            ),
                          )
                          : const Center(
                            child: Icon(
                              Icons.movie,
                              size: 64,
                              color: Colors.white54,
                            ),
                          ),
                ),
                // Rating overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Center(
              child:             Text(
                movie.cleanTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenreSection(
    String genreName,
    List<Movie> movies, {
    String? viewCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "$genreName Films",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return buildMovieCard(movies[index]);
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
