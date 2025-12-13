import 'package:flutter/material.dart';
import 'package:vitacareof/presentation/screens/home/advice_page.dart';
import 'package:vitacareof/presentation/screens/home/appointments_page.dart';
import 'package:vitacareof/presentation/screens/home/calendar_page.dart';
import 'package:vitacareof/presentation/screens/home/medicine_page.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaActual = 0;

  final List<Widget> _paginas = const [
    AppointmentsPage(),
    CalendarPage(),
    MedicinePage(),
    AdvicePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(title: const Text("VitaCare")),
      body: _paginas[_paginaActual],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Citas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Calendario",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: "Medicinas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: "Consejos",
          ),
        ],
      ),
    );
  }
}
