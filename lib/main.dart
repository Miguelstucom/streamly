import 'package:flutter/material.dart';
import 'package:streamly/routes.dart';
import 'package:streamly/theme/app_theme.dart';
import 'package:streamly/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.initialize();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamly',
      theme: AppTheme.darkTheme,
      initialRoute:
          authService.currentUser != null ? AppRoutes.main : AppRoutes.login,
      routes: AppRoutes.getRoutes(),
    );
  }
}
