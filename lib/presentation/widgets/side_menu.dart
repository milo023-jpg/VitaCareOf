import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vitacareof/presentation/providers/auth_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthNotifier>();
    final user = authProvider.user;

    return NavigationDrawer(
      selectedIndex: null,
      children: [
        // ---------- CABECERA CON DATOS DEL USUARIO ----------
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // ---------- OPCIONES DE NAVEGACIÓN ----------
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          label: const Text('Inicio'),
          selectedIcon: const Icon(Icons.home),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.person_outline),
          label: const Text('Perfil'),
          selectedIcon: const Icon(Icons.person),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.palette_outlined),
          label: const Text('Tema'),
          selectedIcon: const Icon(Icons.palette),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.data_usage),
          label: const Text('Prueba Datos'),
          selectedIcon: const Icon(Icons.data_usage),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.logout_outlined),
          label: const Text('Cerrar sesión'),
          selectedIcon: const Icon(Icons.logout),
        ),
        /* NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Configuración'),
          selectedIcon: const Icon(Icons.settings),
        ), */
      ],

      // ---------- MANEJO DE NAVEGACIÓN ----------
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/profile');
            break;
          case 2:
            context.go('/theme');
            break;
          case 3:
            context.go('/datos');
            break;
          case 4:
            authProvider.logout();
            context.go('/login');
            break;
          /* case 3:
            context.go('/configuracion');
            break; */
        }
      },
    );
  }
}
