// lib/main.dart
import 'package:flutter/material.dart';
import 'main_screen.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clínica App',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Elige un color primario que te guste
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Puedes definir más estilos aquí
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(secondary: Colors.amber),
         useMaterial3: true, // Opcional, si quieres usar Material 3
      ),
      home: const MainScreen(), // Inicia con MainScreen
      debugShowCheckedModeBanner: false,
    );
  }
}