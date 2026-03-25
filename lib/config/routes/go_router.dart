import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:vitacareof/domain/entities/appointment.dart';
import 'package:vitacareof/domain/entities/medicine.dart';
import 'package:vitacareof/presentation/screens/appointments/appointment_detail_page.dart';
import 'package:vitacareof/presentation/screens/appointments/new_appointment_screen.dart';

//    Screens
import 'package:vitacareof/presentation/screens/home/home_screen.dart';
import 'package:vitacareof/presentation/screens/login/login_screen.dart';
import 'package:vitacareof/presentation/screens/medicines/medicine_detail.dart';
import 'package:vitacareof/presentation/screens/profile/profile_screen.dart';
import 'package:vitacareof/presentation/screens/register/register_screen.dart';
import 'package:vitacareof/presentation/screens/theme/theme_screen.dart';
import 'package:vitacareof/presentation/screens/appointments/edit_appointment_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
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
      name: NewAppointmentScreen.name,
      builder: (context, state) => const NewAppointmentScreen(),
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

    GoRoute(
      path: '/appointment_detail',
      name: AppointmentDetailPage.name,
      builder: (context, state) {
        final appointment = state.extra as Appointment;
        return AppointmentDetailPage(appointment: appointment);
      },
    ),

    GoRoute(
      path: '/medicine_detail',
      name: MedicineDetail.name,
      builder: (context, state) {
        final medicine = state.extra as Medicine;
        return MedicineDetail(medicine: medicine);
      },
    ),

    GoRoute(
      path: '/edit_appointment',
      builder: (context, state) {
        final appointment = state.extra as Appointment;
        return EditAppointmentPage(appointment: appointment);
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
