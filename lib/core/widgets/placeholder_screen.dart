import 'package:flutter/material.dart';

// Écran temporaire, affiché pour un module qu'on n'a pas encore construit.
// Ça permet de tester la navigation dès maintenant, avant même d'avoir
// codé l'écran final (ex: l'Accueil, qui viendra à l'étape 2).
class PlaceholderScreen extends StatelessWidget {
  final String titre;
  final String etape;

  const PlaceholderScreen({super.key, required this.titre, required this.etape});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Module "$titre" — à construire ($etape)'),
          ],
        ),
      ),
    );
  }
}