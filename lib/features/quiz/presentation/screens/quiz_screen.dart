import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../authentification/providers/auth_controller.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/quiz_repository.dart';

// Écran de passage d un quiz : question par question, avec correction
// immédiate après chaque réponse, puis score final à la fin.
// Règle : il faut 100% pour valider le module. Sinon, une nouvelle
// tentative est possible, mais seulement 24h après la précédente.
class QuizScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<QuestionQuiz>? _questions;
  int _indexActuel = 0;
  String? _choixSelectionne;
  bool? _dernierEstCorrect;
  String? _choixCorrectId;
  bool _verificationEnCours = false;
  final List<Map<String, String>> _reponsesDonnees = [];

  int? _scoreFinal;
  bool? _reussiteFinale;
  String? _erreur;

  // Si non nul, l apprenant doit attendre avant de repasser le quiz.
  DateTime? _prochaineTentativePossible;
  // Si vrai, l apprenant a deja obtenu 100% : plus besoin de repasser.
  bool _dejaValide = false;

  @override
  void initState() {
    super.initState();
    _initialiser();
  }

  Future<void> _initialiser() async {
    final repo = ref.read(quizRepositoryProvider);
    final authState = ref.read(authControllerProvider);
    final utilisateurId = authState is AuthConnecte ? authState.utilisateur.id : '';

    final resultatExistant = await repo.getResultatExistant(
      quizId: widget.quiz.id,
      utilisateurId: utilisateurId,
    );

    if (resultatExistant != null) {
      if (resultatExistant.reussite) {
        // Deja 100% : le module est valide, pas besoin de repasser.
        setState(() {
          _dejaValide = true;
          _scoreFinal = resultatExistant.score;
          _reussiteFinale = true;
        });
        return;
      }
      final prochaine = resultatExistant.dateCreation.add(const Duration(hours: 24));
      if (DateTime.now().isBefore(prochaine)) {
        // Delai de 24h pas encore ecoule.
        setState(() {
          _prochaineTentativePossible = prochaine;
          _scoreFinal = resultatExistant.score;
          _reussiteFinale = false;
        });
        return;
      }
      // 24h ecoulees : on laisse l apprenant repasser le quiz normalement.
    }

    try {
      final questions = await repo.getQuestions(widget.quiz.id);
      setState(() => _questions = questions);
    } catch (_) {
      setState(() => _erreur = 'Impossible de charger le quiz.');
    }
  }

  Future<void> _repondre(String choixId) async {
    if (_verificationEnCours || _choixSelectionne != null) return;
    setState(() {
      _choixSelectionne = choixId;
      _verificationEnCours = true;
    });

    final question = _questions![_indexActuel];
    final repo = ref.read(quizRepositoryProvider);
    final (estCorrect, choixCorrectId) = await repo.verifierReponse(
      quizId: widget.quiz.id,
      questionId: question.id,
      choixId: choixId,
    );

    _reponsesDonnees.add({'questionId': question.id, 'choixId': choixId});

    setState(() {
      _dernierEstCorrect = estCorrect;
      _choixCorrectId = choixCorrectId;
      _verificationEnCours = false;
    });
  }

  Future<void> _suivant() async {
    if (_indexActuel < _questions!.length - 1) {
      setState(() {
        _indexActuel++;
        _choixSelectionne = null;
        _dernierEstCorrect = null;
        _choixCorrectId = null;
      });
      return;
    }

    // Dernière question répondue — on soumet le quiz complet.
    final repo = ref.read(quizRepositoryProvider);
    final authState = ref.read(authControllerProvider);
    final utilisateurId = authState is AuthConnecte ? authState.utilisateur.id : '';

    try {
      final resultat = await repo.soumettre(
        quizId: widget.quiz.id,
        utilisateurId: utilisateurId,
        reponses: _reponsesDonnees,
      );
      setState(() {
        _scoreFinal = resultat.score;
        _reussiteFinale = resultat.reussite;
        if (resultat.reussite) _dejaValide = true;
      });
    } on TentativeRefuseeException catch (e) {
      setState(() {
        _prochaineTentativePossible = e.prochaineTentativePossible;
        _dejaValide = e.prochaineTentativePossible == null; // 409 = deja 100%
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.titre)),
      body: _construireCorps(),
    );
  }

  Widget _construireCorps() {
    if (_dejaValide || _prochaineTentativePossible != null || _scoreFinal != null) {
      return _ecranResultat();
    }
    if (_erreur != null) {
      return Center(child: Text(_erreur!));
    }
    if (_questions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = _questions![_indexActuel];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${_indexActuel + 1} / ${_questions!.length}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Text(question.texte, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          ...question.choix.map((c) => _optionChoix(c)),
          const Spacer(),
          if (_choixSelectionne != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _suivant,
                child: Text(
                  _indexActuel < _questions!.length - 1 ? 'Question suivante' : 'Voir mon résultat',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _optionChoix(ChoixQuestion c) {
    Color? couleurFond;
    IconData? icone;
    if (_choixSelectionne != null) {
      if (c.id == _choixCorrectId) {
        couleurFond = Colors.green.shade50;
        icone = Icons.check_circle;
      } else if (c.id == _choixSelectionne) {
        couleurFond = Colors.red.shade50;
        icone = Icons.cancel;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _repondre(c.id),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: couleurFond ?? Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: couleurFond != null ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(c.texte)),
              if (icone != null)
                Icon(icone, color: icone == Icons.check_circle ? Colors.green : Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ecranResultat() {
    final formatDateHeure = DateFormat('d MMMM à HH:mm', 'fr_FR');

    String titre;
    IconData icone;
    Color couleur;
    String sousTitre;

    if (_dejaValide) {
      titre = 'Module validé !';
      icone = Icons.emoji_events_rounded;
      couleur = Colors.amber;
      sousTitre = 'Vous avez obtenu un score parfait de 100%.';
    } else if (_prochaineTentativePossible != null) {
      titre = 'Score insuffisant';
      icone = Icons.replay_circle_filled_rounded;
      couleur = Colors.grey;
      sousTitre = 'Un score de 100% est requis pour valider ce module.\n'
          'Prochaine tentative possible le ${formatDateHeure.format(_prochaineTentativePossible!)}.';
    } else {
      titre = 'Quiz terminé';
      icone = Icons.info_outline_rounded;
      couleur = Colors.grey;
      sousTitre = '';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: couleur),
            const SizedBox(height: 16),
            Text(
              titre,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_scoreFinal != null) ...[
              const SizedBox(height: 8),
              Text('Score : $_scoreFinal%'),
            ],
            const SizedBox(height: 12),
            Text(
              sousTitre,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
