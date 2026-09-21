import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../authentification/presentation/screens/inscription_screen.dart';

// Page d accueil PUBLIQUE, affichee avant toute connexion — presente
// le Centre et sa mission, avant de proposer de se connecter ou de
// creer un compte.
class BienvenueScreen extends StatelessWidget {
  const BienvenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.school_rounded, size: 64, color: Color(0xFF1F3864)),
              const SizedBox(height: 14),
              Text(
                'CNFPATEL Guinée',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF1F3864),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Centre National de Formation et de Perfectionnement des\n'
                'Administrateurs Territoriaux et Elus Locaux',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Section institutionnelle : photo et vision du Directeur General.
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundImage: AssetImage('assets/directeur/photo-directeur.jpg'),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Mamady Magassouba',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F3864),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Directeur Général du CNFPATEL',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Icon(Icons.format_quote_rounded, color: Color(0xFFD4AF37), size: 28),
                    const SizedBox(height: 4),
                    Text(
                      'Notre vision est de faire du CNFPATEL un pôle d\'excellence pour '
                      'la formation continue des administrateurs territoriaux et des '
                      'élus locaux de Guinée, afin de renforcer une administration '
                      'publique compétente, intègre et au service du développement '
                      'de nos communautés à la base.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: () => context.go('/connexion'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Se connecter', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InscriptionScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Créer un compte', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

