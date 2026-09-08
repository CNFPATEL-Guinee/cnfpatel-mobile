class ChoixQuestion {
  final String id;
  final String texte;
  const ChoixQuestion({required this.id, required this.texte});

  factory ChoixQuestion.fromJson(Map<String, dynamic> json) {
    return ChoixQuestion(id: json['_id'] as String, texte: json['texte'] as String);
  }
}

class QuestionQuiz {
  final String id;
  final String texte;
  final List<ChoixQuestion> choix;
  const QuestionQuiz({required this.id, required this.texte, required this.choix});

  factory QuestionQuiz.fromJson(Map<String, dynamic> json) {
    return QuestionQuiz(
      id: json['_id'] as String,
      texte: json['texte'] as String,
      choix: (json['choix'] as List)
          .map((c) => ChoixQuestion.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Quiz {
  final String id;
  final String moduleId;
  final String titre;
  final int seuilReussite;
  const Quiz({
    required this.id,
    required this.moduleId,
    required this.titre,
    required this.seuilReussite,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['_id'] as String,
      moduleId: json['moduleId'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      seuilReussite: (json['seuilReussite'] as num?)?.toInt() ?? 50,
    );
  }
}
