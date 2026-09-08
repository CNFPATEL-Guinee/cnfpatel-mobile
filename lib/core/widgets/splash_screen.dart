import 'package:flutter/material.dart';

// Petit écran affiché très brièvement au tout premier lancement de l'app,
// le temps de vérifier si une session de connexion existe déjà sur le
// téléphone (voir auth_controller.dart). L'utilisateur ne le voit
// généralement qu'une fraction de seconde.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(Icons.school_rounded, size: 64, color: Color(0xFF1F3864)),
      ),
    );
  }
}