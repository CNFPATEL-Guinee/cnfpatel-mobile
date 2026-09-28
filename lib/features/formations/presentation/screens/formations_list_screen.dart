import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/formations_providers.dart';
import '../widgets/formation_card.dart';
import 'formation_detail_screen.dart';

class FormationsListScreen extends ConsumerStatefulWidget {
  const FormationsListScreen({super.key});

  @override
  ConsumerState<FormationsListScreen> createState() => _FormationsListScreenState();
}

class _FormationsListScreenState extends ConsumerState<FormationsListScreen> {
  final _rechercheController = TextEditingController();
  String _recherche = '';

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formationsAsync = ref.watch(formationsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Formations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _rechercheController,
              onChanged: (valeur) => setState(() => _recherche = valeur),
              decoration: InputDecoration(
                hintText: 'Rechercher une formation...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _recherche.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _rechercheController.clear();
                          setState(() => _recherche = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
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
                            'Impossible de charger les formations.\nVerifiez votre connexion.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => ref.invalidate(formationsListProvider),
                            child: const Text('Reessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                data: (formations) {
                  final terme = _recherche.trim().toLowerCase();
                  final formationsFiltrees = terme.isEmpty
                      ? formations
                      : formations.where((f) {
                          return f.titre.toLowerCase().contains(terme) ||
                              f.description.toLowerCase().contains(terme);
                        }).toList();

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

                  if (formationsFiltrees.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune formation ne correspond a "$_recherche".',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: formationsFiltrees.length,
                    itemBuilder: (context, index) {
                      final formation = formationsFiltrees[index];
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
          ),
        ],
      ),
    );
  }
}
