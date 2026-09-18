import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../authentification/providers/auth_controller.dart';
import '../../../certificats/presentation/screens/certificats_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profil/presentation/screens/profil_screen.dart';

class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    final telephone = authState is AuthConnecte
        ? authState.utilisateur.telephone
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Se déconnecter',
            onPressed: () {
              ref.read(authControllerProvider.notifier).deconnecter();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.waving_hand_rounded, size: 48, color: Color(0xFF1F3864)),
            const SizedBox(height: 16),
            Text(
              'Bonjour !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Connecté avec le numéro $telephone',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/formations'),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Voir mes formations'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CertificatsScreen()),
                );
              },
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Mes certificats'),
            ),
            const SizedBox(height: 32),
            _blocDirecteurGeneral(context),
          ],
        ),
      ),
    );
  }

  // Presente le Directeur General et sa vision pour le Centre — donne
  // une touche institutionnelle a l ecran d accueil.
  Widget _blocDirecteurGeneral(BuildContext context) {
    return Container(
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
    );
  }
}
