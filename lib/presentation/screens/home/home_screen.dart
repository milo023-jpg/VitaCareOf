import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      appBar: AppBar(title: const Text("Home")),
      body: const Center(child: Text("Bienvenido a la pantalla principal")),
    );
  }
}
