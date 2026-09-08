class ResultatQuiz {
  final String id;
  final int score;
  final bool reussite;
  const ResultatQuiz({required this.id, required this.score, required this.reussite});

  factory ResultatQuiz.fromJson(Map<String, dynamic> json, {int seuilReussite = 50}) {
    final score = (json['score'] as num).toInt();
    return ResultatQuiz(
      id: json['_id'] as String,
      score: score,
      reussite: score >= seuilReussite,
    );
  }
}
