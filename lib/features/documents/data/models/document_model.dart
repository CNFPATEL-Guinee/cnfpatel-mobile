// Représente un document (PDF) rattaché à une formation ou un module.
class DocumentCours {
  final String id;
  final String moduleId;
  final String titre;
  final String urlFichier;
  final int? tailleOctets; // taille du fichier, utile pour informer avant téléchargement

  const DocumentCours({
    required this.id,
    required this.moduleId,
    required this.titre,
    required this.urlFichier,
    this.tailleOctets,
  });

  factory DocumentCours.fromJson(Map<String, dynamic> json) {
    return DocumentCours(
      id: json['_id'] as String,
      moduleId: json['moduleId'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      urlFichier: json['urlFichier'] as String? ?? '',
      tailleOctets: (json['tailleOctets'] as num?)?.toInt(),
    );
  }

  // Convertit la taille en texte lisible, ex: "2,4 Mo".
  String get tailleLisible {
    if (tailleOctets == null) return '';
    final mo = tailleOctets! / (1024 * 1024);
    return '${mo.toStringAsFixed(1)} Mo';
  }
}
