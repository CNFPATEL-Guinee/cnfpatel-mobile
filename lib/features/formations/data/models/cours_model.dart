enum TypeCours { video, document }

// Représente un cours d'un module, tel que renvoyé par le backend.
class Cours {
  final String id;
  final String moduleId;
  final String titre;
  final TypeCours type;
  final String urlFichier;
  final bool termine;

  const Cours({
    required this.id,
    required this.moduleId,
    required this.titre,
    required this.type,
    required this.urlFichier,
    this.termine = false,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['_id'] as String,
      moduleId: json['moduleId'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      type: (json['type'] as String?) == 'video'
          ? TypeCours.video
          : TypeCours.document,
      urlFichier: json['urlFichier'] as String? ?? '',
      termine: json['termine'] as bool? ?? false,
    );
  }
}