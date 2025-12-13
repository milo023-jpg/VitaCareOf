import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Detecta la ruta actual
    final String location = GoRouterState.of(context).uri.toString();

    // Determina el índice activo según la ruta
    int selectedIndex = 0;
    if (location.startsWith('/citas')) selectedIndex = 1;

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        // Cambia de ruta usando GoRouter
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/appointments');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Citas'),
      ],
    );
  }
}
