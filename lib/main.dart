import 'package:flutter/material.dart';
import 'components/AfterButton.dart';
import 'theme/colors.dart';
import 'theme/AfterlifeTheme.dart';

void main() {
  runApp(const AfterlifeApp());
}

class AfterlifeApp extends StatelessWidget {
  const AfterlifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AfterlifeTheme.darkTheme, // Usa el tema que arreglamos
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Al dejar solo uno aquí, solo aparecerá uno en pantalla
        child: AfterButton(
          label: 'ENTRAR', // El texto que tú quieras
          size: 100,       // El tamaño que tú quieras
          color: AfterlifeColors.electricPurple, // El color que tú quieras
          onPressed: () {
            print('¡Botón reutilizable funcionando!');
          },
        ),
      ),
    );
  }
}