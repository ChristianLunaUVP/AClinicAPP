// lib/main.dart
import 'package:flutter/material.dart';
import 'main_screen.dart'; // Asegúrate de que la ruta sea correcta

// Tu paleta de colores definida
const Color azulClaroPrimario = Color(0xFF56CCF2);    // Primario (botones principales, destacados)
const Color azulSuaveSecundario = Color(0xFFA7D8FF);  // Secundario (fondos, áreas grandes, acentos)
const Color azulOscuroTexto = Color(0xFF2C3E50);      // Texto Principal
const Color azulPastelAccionesSec = Color(0xFFD6EAF8); // Fondos de secciones, formularios
const Color azulGrisaceoInactivo = Color(0xFFB0BEC5); // Elementos desactivados
const Color azulAceroFondoNavBar = Color(0xFF34495E);  // Fondo de AppBar/BottomNavBar

// Un blanco suave para el fondo principal del scaffold, para buen contraste con azulOscuroTexto
const Color fondoScaffoldClaro = Color(0xFFF0F8FF); // AliceBlue como ejemplo, o Colors.white
const Color colorTextoSobreOscuro = Colors.white; // Texto para fondos oscuros como azulAceroFondoNavBar

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
        useMaterial3: true, // Recomendado para diseños más modernos
        brightness: Brightness.light,

        // Esquema de Color Principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: azulClaroPrimario, // El color primario principal
          primary: azulClaroPrimario,
          secondary: azulSuaveSecundario,
          surface: fondoScaffoldClaro, // Fondo de superficies como Cards (si no se define en cardTheme)
          background: fondoScaffoldClaro, // Fondo general del scaffold
          error: Colors.redAccent,
          onPrimary: azulOscuroTexto, // Texto/iconos sobre el color primario (ajustar para contraste)
                                     // Podría ser Colors.white si azulClaroPrimario es muy oscuro para azulOscuroTexto
          onSecondary: azulOscuroTexto, // Texto/iconos sobre el color secundario
          onSurface: azulOscuroTexto,   // Texto/iconos sobre superficies (cards, etc.)
          onBackground: azulOscuroTexto,// Texto/iconos sobre el fondo general
          onError: Colors.white,
          brightness: Brightness.light,
        ),

        // Color primario (para compatibilidad y algunos widgets que aún lo usan directamente)
        primaryColor: azulClaroPrimario,

        scaffoldBackgroundColor: fondoScaffoldClaro,

        // Tema para AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: azulAceroFondoNavBar,
          foregroundColor: colorTextoSobreOscuro, // Color para título e iconos en AppBar
          elevation: 4.0,
          titleTextStyle: const TextStyle(
            fontFamily: 'Roboto', // O la fuente que prefieras
            fontSize: 20,
            fontWeight: FontWeight.w600, // Un poco más de peso para el título
            color: colorTextoSobreOscuro,
          ),
        ),

        // Tema para BottomNavigationBar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: azulAceroFondoNavBar,
          selectedItemColor: azulClaroPrimario,
          unselectedItemColor: azulGrisaceoInactivo.withOpacity(0.8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
        ),

        // Tema para Textos
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: azulOscuroTexto, letterSpacing: 0.25),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: azulOscuroTexto, letterSpacing: 0.2),
          displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: azulOscuroTexto),

          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: azulOscuroTexto),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: azulOscuroTexto), // Para títulos de sección
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: azulOscuroTexto),

          titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: azulOscuroTexto), // Para títulos de ListTile
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: azulOscuroTexto),
          titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: azulOscuroTexto),

          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: azulOscuroTexto, height: 1.5), // Texto principal
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: azulOscuroTexto.withOpacity(0.85), height: 1.4), // Subtítulos o texto secundario
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: azulGrisaceoInactivo, height: 1.3), // Texto pequeño, leyendas

          labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorTextoSobreOscuro, letterSpacing: 0.5), // Para botones
          labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: azulOscuroTexto.withOpacity(0.9)),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: azulOscuroTexto.withOpacity(0.8)),
        ),

        // Tema para Botones Elevados (principales)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: azulClaroPrimario,
            foregroundColor: azulOscuroTexto, // O colorTextoSobreOscuro si es necesario para contraste
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 2,
          ),
        ),

        // Tema para TextButtons (acciones secundarias o de texto)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: azulClaroPrimario,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        
        // Tema para FloatingActionButton
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: azulSuaveSecundario, // O azulClaroPrimario si quieres que sea más prominente
          foregroundColor: azulOscuroTexto,
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),

        // Tema para Cards
        cardTheme: CardThemeData(
          elevation: 2.0, // Sombra sutil
          color: Colors.white, // Fondo blanco para las tarjetas para que resalten
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            // side: BorderSide(color: azulPastelAccionesSec.withOpacity(0.5), width: 1) // Borde sutil opcional
          ),
        ),

        // Tema para Campos de Entrada (TextFormField)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: azulPastelAccionesSec.withOpacity(0.4), // Un relleno muy sutil
          hintStyle: TextStyle(color: azulGrisaceoInactivo.withOpacity(0.9)),
          labelStyle: TextStyle(color: azulOscuroTexto.withOpacity(0.9), fontWeight: FontWeight.w500),
          iconColor: azulClaroPrimario,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // Sin borde por defecto, el fillColor lo define
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: azulGrisaceoInactivo.withOpacity(0.5), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: azulClaroPrimario, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.redAccent.shade200, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        ),
        
        // Tema para Diálogos
        dialogTheme: DialogThemeData(
          backgroundColor: fondoScaffoldClaro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: azulOscuroTexto),
        ),

        // Tema para Switch
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return azulClaroPrimario;
            }
            return azulGrisaceoInactivo;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return azulClaroPrimario.withOpacity(0.5);
            }
            return azulGrisaceoInactivo.withOpacity(0.3);
          }),
        ),

        // Densidad visual para adaptarse a diferentes plataformas
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}