// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'pages/doctors_page.dart'; // Crearemos esta página a continuación
import 'pages/patients_page.dart'; // Crearemos esta página a continuación
import 'pages/appointments_page.dart'; // Adaptaremos HomePage a esta

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Índice para la pestaña seleccionada

  // Lista de páginas que se mostrarán
  static final List<Widget> _widgetOptions = <Widget>[
    const DoctorsPage(),
    const PatientsPage(),
    const AppointmentsPage(),
  ];

  // Lista de títulos para el AppBar
  static const List<String> _appBarTitles = <String>[
    'Doctores',
    'Pacientes',
    'Citas',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        elevation: 2.0, // Sombra sutil para el AppBar
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services), // Icono activo
            label: 'Doctores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Color del ítem seleccionado
        unselectedItemColor: Colors.grey, // Color de ítems no seleccionados
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Para más de 3 ítems, o si quieres que siempre se vean las etiquetas
      ),
    );
  }
}