import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/movie_review.dart';
import '../models/credits.dart';
import '../services/movie_service.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton.dart';
import 'package:intl/intl.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  MovieReviewsResponse? _reviews;
  Credits? _credits;
  bool _isLoadingReviews = false;
  bool _isLoadingCredits = false;
  String? _error;
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  final _reviewController = TextEditingController();
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadCredits();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _movieService.getMovieReviews(
        widget.movie.movieId!,
      );
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _loadCredits() async {
    if (widget.movie.movieId == null) {
      setState(() {
        _isLoadingCredits = false;
      });
      return;
    }

    setState(() {
      _isLoadingCredits = true;
    });

    try {
      final credits = await _movieService.getMovieCredits(
        widget.movie.movieId!,
      );
      if (mounted) {
        setState(() {
          _credits = credits;
          _isLoadingCredits = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCredits = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los créditos: $e'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  String _formatRuntime(int? minutes) {
    if (minutes == null) return '';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }

  Future<void> _showReviewDialog() async {
    final TextEditingController descriptionController = TextEditingController();
    double rating = 0.0;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text(
                    'Escribe tu reseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                rating = index + 1.0;
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Escribe tu opinión sobre la película...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor, selecciona una calificación',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (descriptionController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor, escribe una descripción',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          await _movieService.postMovieReview(
                            widget.movie.movieId!,
                            rating,
                            descriptionController.text.trim(),
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _loadReviews();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reseña publicada con éxito'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al publicar la reseña: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Publicar'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildReviewCard(MovieReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 20,
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '@${review.username}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.timestamp != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimestamp(review.timestamp),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Widget _buildCreditsSection() {
    if (_isLoadingCredits) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_credits == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Reparto y Equipo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Directors
        if (_credits!.directors.isNotEmpty) ...[
          Text(
            'Directores',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _credits!.directors.map((director) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      director.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Producers
        if (_credits!.producers.isNotEmpty) ...[
          Text(
            'Productores',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _credits!.producers.map((producer) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      producer.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Cast
        if (_credits!.cast.isNotEmpty) ...[
          Text(
            'Reparto',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _credits!.cast.length,
              itemBuilder: (context, index) {
                final actor = _credits!.cast[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      // Actor photo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                          image:
                              actor.profilePath != null
                                  ? DecorationImage(
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w185${actor.profilePath}',
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            actor.profilePath == null
                                ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white54,
                                )
                                : null,
                      ),
                      const SizedBox(height: 8),
                      // Actor name
                      Text(
                        actor.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Character name
                      Text(
                        actor.character,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.movie.backdropPath != null)
                      Image.network(
                        '$_imageBaseUrl${widget.movie.backdropPath}',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Skeleton(
                            width: double.infinity,
                            height: double.infinity,
                          );
                        },
                      )
                    else
                      Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            size: 100,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.movie.posterPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '$_imageBaseUrl${widget.movie.posterPath}',
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Skeleton(
                                  width: 120,
                                  height: 180,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.title ?? '',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.movie.originalTitle != null &&
                                  widget.movie.originalTitle !=
                                      widget.movie.title) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.movie.originalTitle!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[400],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                widget.movie.releaseDate ?? '',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.movie.voteAverage?.toStringAsFixed(
                                          1,
                                        ) ??
                                        'N/A',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${widget.movie.voteCount ?? 0} votos)',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (widget.movie.runtime != null) ...[
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatRuntime(widget.movie.runtime),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (widget.movie.tagline != null &&
                        widget.movie.tagline!.isNotEmpty) ...[
                      Text(
                        widget.movie.tagline!,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[300],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (widget.movie.overview != null) ...[
                      Text(
                        'Sinopsis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.movie.overview!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (widget.movie.genres != null &&
                        widget.movie.genres!.isNotEmpty) ...[
                      Text(
                        'Géneros',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            widget.movie.genres!.map((genre) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  genre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (widget.movie.budget != null ||
                        widget.movie.revenue != null) ...[
                      Text(
                        'Información Financiera',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.movie.budget != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Presupuesto: ${_formatCurrency(widget.movie.budget)}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (widget.movie.revenue != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recaudación: ${_formatCurrency(widget.movie.revenue)}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                    if (widget.movie.productionCompanies != null &&
                        widget.movie.productionCompanies!.isNotEmpty) ...[
                      Text(
                        'Compañías Productoras',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            widget.movie.productionCompanies!.map((company) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  company,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildCreditsSection(),
                    if (_reviews != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Últimas Reseñas',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showReviewDialog,
                            icon: const Icon(
                              Icons.rate_review,
                              color: Colors.white,
                            ),
                            label: const Text('Escribir reseña'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingReviews)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      else if (_reviews!.latestReviews.isEmpty)
                        const Center(
                          child: Text(
                            'No hay reseñas disponibles',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        ..._reviews!.latestReviews.map(_buildReviewCard),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
