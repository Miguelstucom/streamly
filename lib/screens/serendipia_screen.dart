import 'package:flutter/material.dart';
import 'package:streamly/models/movie.dart';
import 'package:streamly/screens/movie_detail_screen.dart';
import 'package:streamly/theme/app_theme.dart';
import 'dart:math' as math;

class SerendipiaScreen extends StatefulWidget {
  final List<Movie> movies;

  const SerendipiaScreen({super.key, required this.movies});

  @override
  State<SerendipiaScreen> createState() => _SerendipiaScreenState();
}

class _SerendipiaScreenState extends State<SerendipiaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _angle = 0;
  bool _isSpinning = false;
  Movie? _selectedMovie;
  final _random = math.Random();
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi * 5, // 5 full rotations
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addListener(() {
      setState(() {
        _angle = _animation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          // Select a random movie with equal probability
          _selectedMovie = widget.movies[_random.nextInt(widget.movies.length)];
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (!_isSpinning) {
      setState(() {
        _isSpinning = true;
        _selectedMovie = null;
      });
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Serendipia',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Roulette wheel
                      Transform.rotate(
                        angle: _angle,
                        child: Container(
                          width: _selectedMovie != null ? 150 : 200,
                          height: _selectedMovie != null ? 150 : 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background circles
                              for (int i = 0; i < 2; i++)
                                Container(
                                  margin: EdgeInsets.all(
                                    i * (_selectedMovie != null ? 10.0 : 15.0),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              // Movie posters
                              for (int i = 0; i < widget.movies.length; i++)
                                Transform.rotate(
                                  angle:
                                      (2 * math.pi * i) / widget.movies.length,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        _selectedMovie != null ? -75 : -100,
                                      ),
                                      child: Transform.rotate(
                                        angle: math.pi / 2,
                                        child: Container(
                                          width:
                                              _selectedMovie != null ? 50 : 70,
                                          height:
                                              _selectedMovie != null ? 50 : 70,
                                          margin: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child:
                                                widget.movies[i].posterPath !=
                                                        null
                                                    ? Image.network(
                                                      '$_imageBaseUrl${widget.movies[i].posterPath}',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color:
                                                              Colors.grey[800],
                                                          child: Icon(
                                                            Icons.movie,
                                                            size:
                                                                _selectedMovie !=
                                                                        null
                                                                    ? 20
                                                                    : 30,
                                                            color:
                                                                Colors.white54,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                    : Container(
                                                      color: Colors.grey[800],
                                                      child: Icon(
                                                        Icons.movie,
                                                        size:
                                                            _selectedMovie !=
                                                                    null
                                                                ? 20
                                                                : 30,
                                                        color: Colors.white54,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Center pointer
                      Container(
                        width: _selectedMovie != null ? 10 : 15,
                        height: _selectedMovie != null ? 20 : 25,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedMovie != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '¡Película Seleccionada!',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (_selectedMovie!.posterPath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                '$_imageBaseUrl${_selectedMovie!.posterPath}',
                                width: 100,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedMovie!.title ?? 'Sin título',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_selectedMovie!.releaseDate != null)
                                  Text(
                                    DateTime.parse(
                                      _selectedMovie!.releaseDate!,
                                    ).year.toString(),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MovieDetailScreen(
                                              movie: _selectedMovie!,
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text('Ver detalles'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isSpinning ? null : _spinWheel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _isSpinning ? 'Girando...' : '¡Girar!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
