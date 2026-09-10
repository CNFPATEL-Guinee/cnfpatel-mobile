import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bibliotheque/presentation/screens/bibliotheque_screen.dart';
import '../../../classes_virtuelles/presentation/screens/classes_virtuelles_screen.dart';
import '../../../documents/data/models/document_model.dart';
import '../../../documents/presentation/widgets/document_tile.dart';
import '../../../progression/presentation/screens/progression_screen.dart';
import '../../../quiz/data/repositories/quiz_repository.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../../data/models/cours_model.dart';
import '../../../questions_forum/presentation/screens/questions_forum_screen.dart';
import '../../providers/formations_providers.dart';
import 'cours_video_screen.dart';

class FormationDetailScreen extends ConsumerWidget {
  final String formationId;
  final String formationTitre;
  const FormationDetailScreen({
    super.key,
    required this.formationId,
    required this.formationTitre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(formationModulesProvider(formationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(formationTitre),
        actions: [
          IconButton(
            icon: const Icon(Icons.donut_large_rounded),
            tooltip: 'Ma progression',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProgressionScreen(
                    formationId: formationId,
                    formationTitre: formationTitre,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('Questions'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuestionsForumScreen(formationId: formationId),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Classes virtuelles'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClassesVirtuellesScreen(formationId: formationId),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.video_library_outlined),
                    label: const Text('Bibliothèque'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BibliothequeScreen(formationId: formationId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: modulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(formationModulesProvider(formationId)),
                  child: const Text('Erreur de chargement — Réessayer'),
                ),
              ),
              data: (modules) {
                if (modules.isEmpty) {
                  return const Center(child: Text('Aucun module pour cette formation.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ExpansionTile(
                        title: Text(
                          '${module.ordre}. ${module.titre}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final coursAsync = ref.watch(moduleCoursProvider(module.id));
                              return coursAsync.when(
                                loading: () => const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: LinearProgressIndicator(),
                                ),
                                error: (e, s) => const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Erreur de chargement des cours.'),
                                ),
                                data: (coursList) {
                                  if (coursList.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('Aucun cours dans ce module.'),
                                    );
                                  }
                                  return Column(
                                    children: coursList.map((c) {
                                      if (c.type == TypeCours.video) {
                                        return ListTile(
                                          leading: const Icon(Icons.play_circle_outline),
                                          title: Text(c.titre),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => CoursVideoScreen(cours: c),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      return DocumentTile(
                                        document: DocumentCours(
                                          id: c.id,
                                          moduleId: c.moduleId,
                                          titre: c.titre,
                                          urlFichier: c.urlFichier,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              );
                            },
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              return FutureBuilder(
                                future: ref.read(quizRepositoryProvider).getQuizDuModule(module.id),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  final quizList = snapshot.data!;
                                  return Column(
                                    children: quizList.map((quiz) {
                                      return ListTile(
                                        leading: const Icon(Icons.quiz_outlined, color: Colors.purple),
                                        title: Text(quiz.titre),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => QuizScreen(quiz: quiz),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

