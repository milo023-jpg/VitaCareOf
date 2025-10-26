import 'package:flutter/material.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      appBar: AppBar(title: const Text("Tema")),
      body: const Center(child: Text("Bienvenido a la configuración del tema")),
    );
  }
}
