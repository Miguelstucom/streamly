import 'package:flutter/material.dart';
import 'package:streamly/screens/login_screen.dart';
import 'package:streamly/screens/register_screen.dart';
import 'package:streamly/screens/main_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      main: (context) => const MainScreen(),
    };
  }
}
