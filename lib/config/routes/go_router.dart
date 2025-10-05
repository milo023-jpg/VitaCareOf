import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:vitacareof/presentation/screens/home/home_screen.dart';
import 'package:vitacareof/presentation/screens/login/login_screen.dart';
import 'package:vitacareof/presentation/screens/register/register_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
     GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],

  // Manejo de errores
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
  // Redirect opcional para verificar autenticación
  redirect: (context, state) {
    // Aquí puedes agregar lógica para verificar si el usuario está autenticado
    // y redirigir según sea necesario
    return null; // null significa que no hay redirección
  },
);