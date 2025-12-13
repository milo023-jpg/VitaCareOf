import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:vitacareof/presentation/screens/appointments/appointments_screen.dart';

//    Screens
import 'package:vitacareof/presentation/screens/home/home_screen.dart';
import 'package:vitacareof/presentation/screens/login/login_screen.dart';
import 'package:vitacareof/presentation/screens/profile/profile_screen.dart';
import 'package:vitacareof/presentation/screens/pruebadatos/add_name_screen.dart';
import 'package:vitacareof/presentation/screens/pruebadatos/edit_name_screen.dart';
import 'package:vitacareof/presentation/screens/pruebadatos/prueba_datos_screen.dart';
import 'package:vitacareof/presentation/screens/register/register_screen.dart';
import 'package:vitacareof/presentation/screens/theme/theme_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [


    //    LOGIN
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

    //    BOTTOM NAVIGATION BAR
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/appointments',
      name: 'appointments',
      builder: (context, state) => const AppointmentsScreen(),
    ),


    //    SIDE MENU
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/theme',
      name: 'theme',
      builder: (context, state) => const ThemeScreen(),
    ),

    //    PRUEBA DATOS
    GoRoute(
      path: '/datos',
      name: 'datos',
      builder: (context, state) => const PruebaDatos(),
    ),
    GoRoute(
      path: '/add',
      name: 'add',
      builder: (context, state) => const AddNameScreen(),
    ),
    GoRoute(
      path: '/edit',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return EditNameScreen(data: data);
      },
    ),
  ],

  // Manejo de errores
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  // Redirect opcional para verificar autenticación
  redirect: (context, state) {
    // Aquí puedes agregar lógica para verificar si el usuario está autenticado
    // y redirigir según sea necesario
    return null; // null significa que no hay redirección
  },
);
