import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/formations_providers.dart';
import '../widgets/formation_card.dart';
import 'formation_detail_screen.dart';

class FormationsListScreen extends ConsumerWidget {
  const FormationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formationsAsync = ref.watch(formationsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Formations')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(formationsListProvider.future),
        child: formationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            debugPrint('ERREUR FORMATIONS : $error');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'Impossible de charger les formations.\nVérifiez votre connexion.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(formationsListProvider),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          },
          data: (formations) {
            if (formations.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Aucune formation disponible pour le moment.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: formations.length,
              itemBuilder: (context, index) {
                final formation = formations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FormationCard(
                    formation: formation,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FormationDetailScreen(
                            formationId: formation.id,
                            formationTitre: formation.titre,
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
      ),
    );
  }
}
