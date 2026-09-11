class ResultatQuiz {
  final String id;
  final int score;
  final bool reussite;
  final DateTime dateCreation;
  const ResultatQuiz({
    required this.id,
    required this.score,
    required this.reussite,
    required this.dateCreation,
  });

  // Le module n est desormais valide qu avec un score parfait (100%),
  // quel que soit l ancien "seuilReussite" du quiz.
  factory ResultatQuiz.fromJson(Map<String, dynamic> json) {
    final score = (json['score'] as num).toInt();
    return ResultatQuiz(
      id: json['_id'] as String,
      score: score,
      reussite: score >= 100,
      dateCreation: DateTime.parse(json['createdAt'] as String),
    );
  }
}
