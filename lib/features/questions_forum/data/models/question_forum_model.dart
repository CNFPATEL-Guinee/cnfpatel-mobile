// Represente une reponse a une question du forum d une formation.
class ReponseForum {
  final String id;
  final String auteurNom;
  final String texte;
  final DateTime dateCreation;
  const ReponseForum({
    required this.id,
    required this.auteurNom,
    required this.texte,
    required this.dateCreation,
  });
  factory ReponseForum.fromJson(Map<String, dynamic> json) {
    final auteur = json['utilisateurId'] as Map<String, dynamic>?;
    return ReponseForum(
      id: json['_id'] as String,
      auteurNom: auteur != null ? '${auteur['prenom']} ${auteur['nom']}' : 'Formateur',
      texte: json['texte'] as String,
      dateCreation: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// Represente une question posee par un apprenant sur une formation,
// avec ses eventuelles reponses du formateur assigne.
class QuestionForum {
  final String id;
  final String auteurNom;
  final String texte;
  final DateTime dateCreation;
  final List<ReponseForum> reponses;
  const QuestionForum({
    required this.id,
    required this.auteurNom,
    required this.texte,
    required this.dateCreation,
    required this.reponses,
  });
  factory QuestionForum.fromJson(Map<String, dynamic> json) {
    final auteur = json['utilisateurId'] as Map<String, dynamic>?;
    final reponsesJson = json['reponses'] as List? ?? [];
    return QuestionForum(
      id: json['_id'] as String,
      auteurNom: auteur != null ? '${auteur['prenom']} ${auteur['nom']}' : 'Apprenant',
      texte: json['texte'] as String,
      dateCreation: DateTime.parse(json['createdAt'] as String),
      reponses: reponsesJson
          .map((r) => ReponseForum.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
