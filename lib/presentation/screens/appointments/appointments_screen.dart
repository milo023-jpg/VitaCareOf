import 'package:flutter/material.dart';
import 'package:vitacareof/presentation/widgets/bottom_nav_bar.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      appBar: AppBar(title: const Text("Citas")),
      body: const Center(child: Text("Bienvenido a la pantalla de Citas")),
      bottomNavigationBar: BottomNavBar()
      );
  }
}
