import 'package:flutter/material.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      appBar: AppBar(title: const Text("Perfil")),
      body: const Center(child: Text("Bienvenido al perfil")),
    );
  }
}
