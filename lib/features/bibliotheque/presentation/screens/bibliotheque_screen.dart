import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../formations/data/models/cours_model.dart';
import '../../../formations/presentation/screens/cours_video_screen.dart';
import '../../providers/bibliotheque_providers.dart';

// Écran affichant la bibliothèque des sessions enregistrées d une formation.
class BibliothequeScreen extends ConsumerWidget {
  final String formationId;
  const BibliothequeScreen({super.key, required this.formationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enregistrementsAsync = ref.watch(enregistrementsProvider(formationId));
    final formatDate = DateFormat('d MMMM yyyy', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Bibliothèque des sessions')),
      body: enregistrementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(enregistrementsProvider(formationId)),
            child: const Text('Erreur de chargement — Réessayer'),
          ),
        ),
        data: (enregistrements) {
          if (enregistrements.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune session enregistrée disponible pour le moment.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: enregistrements.length,
            itemBuilder: (context, index) {
              final enreg = enregistrements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: const Icon(Icons.play_circle_fill_rounded, size: 36, color: Colors.blue),
                  title: Text(enreg.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Publié le ${formatDate.format(enreg.createdAt)}'),
                  onTap: () {
                    // Réutilise le lecteur vidéo déjà construit pour les cours,
                    // en construisant un objet Cours équivalent.
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CoursVideoScreen(
                          cours: Cours(
                            id: enreg.id,
                            moduleId: '',
                            titre: enreg.titre,
                            type: TypeCours.video,
                            urlFichier: enreg.urlVideo,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
