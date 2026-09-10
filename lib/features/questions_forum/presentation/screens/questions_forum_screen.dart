import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../authentification/providers/auth_controller.dart';
import '../../data/repositories/questions_forum_repository.dart';
import '../../providers/questions_forum_providers.dart';

class QuestionsForumScreen extends ConsumerStatefulWidget {
  final String formationId;
  const QuestionsForumScreen({super.key, required this.formationId});

  @override
  ConsumerState<QuestionsForumScreen> createState() => _QuestionsForumScreenState();
}

class _QuestionsForumScreenState extends ConsumerState<QuestionsForumScreen> {
  final _controleur = TextEditingController();
  bool _envoi = false;

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  Future<void> _poserQuestion() async {
    final texte = _controleur.text.trim();
    if (texte.isEmpty) return;

    final authState = ref.read(authControllerProvider);
    if (authState is! AuthConnecte) return;

    setState(() => _envoi = true);
    try {
      await ref.read(questionsForumRepositoryProvider).poserQuestion(
            widget.formationId,
            authState.utilisateur.id,
            texte,
          );
      _controleur.clear();
      ref.invalidate(questionsForumProvider(widget.formationId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi de la question.')),
        );
      }
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsForumProvider(widget.formationId));
    final formatDate = DateFormat('d MMM à HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Questions / Réponses')),
      body: Column(
        children: [
          Expanded(
            child: questionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(questionsForumProvider(widget.formationId)),
                  child: const Text('Erreur de chargement — Réessayer'),
                ),
              ),
              data: (questions) {
                if (questions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucune question pour le moment.\nSoyez le premier à en poser une !',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(question.auteurNom, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  formatDate.format(question.dateCreation),
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(question.texte),
                            if (question.reponses.isNotEmpty) ...[
                              const Divider(height: 20),
                              ...question.reponses.map((reponse) => Padding(
                                    padding: const EdgeInsets.only(left: 12, bottom: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 3,
                                          height: 36,
                                          color: Theme.of(context).colorScheme.primary,
                                          margin: const EdgeInsets.only(right: 10, top: 2),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${reponse.auteurNom} (formateur)',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(reponse.texte, style: const TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ] else ...[
                              const SizedBox(height: 8),
                              Text(
                                'En attente de réponse du formateur...',
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controleur,
                      decoration: const InputDecoration(
                        hintText: 'Posez votre question...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _envoi ? null : _poserQuestion,
                    icon: _envoi
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
