import 'package:flutter/material.dart';
import 'package:streamly/screens/home_screen.dart';
import 'package:streamly/screens/profile_screen.dart';
import 'package:streamly/screens/chat_screen.dart';
import 'package:streamly/screens/serendipia_screen.dart';
import 'package:streamly/theme/app_theme.dart';
import 'package:streamly/services/movie_service.dart';
import 'package:streamly/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _movieService = MovieService();
  final _authService = AuthService();
  late List<Widget> _screens;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreens();
  }

  Future<void> _loadScreens() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final worstMovies = await _movieService.getUserWorstRecommendations(
        user.userId,
      );
      setState(() {
        _screens = [
          const HomeScreen(),
          SerendipiaScreen(movies: worstMovies),
          const ChatScreen(),
          const ProfileScreen(),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black.withOpacity(0.8),
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Games'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
