import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/progression_providers.dart';

class ProgressionScreen extends ConsumerWidget {
  final String formationId;
  final String formationTitre;
  const ProgressionScreen({
    super.key,
    required this.formationId,
    required this.formationTitre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressionAsync = ref.watch(progressionFormationProvider(formationId));

    return Scaffold(
      appBar: AppBar(title: Text('Progression — $formationTitre')),
      body: progressionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(progressionFormationProvider(formationId)),
            child: const Text('Erreur de chargement — Réessayer'),
          ),
        ),
        data: (progression) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: progression.pourcentageGlobal / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        Text(
                          '${progression.pourcentageGlobal}%',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progression globale',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text('Détail par module', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...progression.modules.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(m.titre)),
                            Text('${m.pourcentage}%'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: m.pourcentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            color: m.pourcentage >= 100 ? Colors.green : null,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
