import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import '../../../authentification/providers/auth_controller.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../providers/classes_virtuelles_providers.dart';

class ClassesVirtuellesScreen extends ConsumerWidget {
  final String formationId;
  const ClassesVirtuellesScreen({super.key, required this.formationId});

  // Extrait le nom de la salle depuis l URL complete (ex: https://meet.jit.si/MaSalle -> MaSalle),
  // requis par le SDK Jitsi embarque (il ne prend pas une URL complete, juste
  // un nom de salle + un serveur separement).
  String _extraireNomSalle(String lienDirect) {
    final uri = Uri.tryParse(lienDirect);
    if (uri == null || uri.pathSegments.isEmpty) return lienDirect;
    return uri.pathSegments.last;
  }

  Future<void> _rejoindreClasse(
    BuildContext context,
    WidgetRef ref,
    dynamic classe,
  ) async {
    // Enregistre automatiquement la présence dès le clic, avant même
    // d ouvrir la session (best-effort, on n empêche pas l accès si ça échoue).
    final authState = ref.read(authControllerProvider);
    String? nomAffiche;
    if (authState is AuthConnecte) {
      nomAffiche = '${authState.utilisateur.prenom} ${authState.utilisateur.nom}';
      try {
        final dio = ref.read(dioProvider);
        await dio.post(
          ApiEndpoints.presences(),
          data: {
            'utilisateurId': authState.utilisateur.id,
            'classeVirtuelleId': classe.id,
          },
        );
      } catch (_) {
        // Silencieux : ne bloque pas l accès à la classe.
      }
    }

    final nomSalle = _extraireNomSalle(classe.lienDirect);

    final jitsiMeet = JitsiMeet();
    final options = JitsiMeetConferenceOptions(
      room: nomSalle,
      userInfo: nomAffiche != null ? JitsiMeetUserInfo(displayName: nomAffiche) : null,
      // Desactive certaines fonctions non utiles pour nos sessions de formation
      // (partage d écran, invitation, etc.) — garde une interface simple.
      featureFlags: {
        'invite.enabled': false,
        'add-people.enabled': false,
        'calendar.enabled': false,
        'chat.enabled': true,
      },
    );

    try {
      await jitsiMeet.join(options);
    } catch (erreur) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de rejoindre la session : $erreur')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesVirtuellesProvider(formationId));
    final formatDate = DateFormat('EEEE d MMMM à HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Classes virtuelles')),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(classesVirtuellesProvider(formationId)),
            child: const Text('Erreur de chargement — Réessayer'),
          ),
        ),
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune classe virtuelle programmée pour le moment.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classe = classes[index];
              final passee = classe.estPassee;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: Icon(
                    Icons.videocam_rounded,
                    color: passee ? Colors.grey : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    classe.titre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: passee ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(formatDate.format(classe.dateHeure)),
                  trailing: passee
                      ? const Chip(label: Text('Terminée'))
                      : FilledButton(
                          onPressed: () => _rejoindreClasse(context, ref, classe),
                          child: const Text('Rejoindre'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
