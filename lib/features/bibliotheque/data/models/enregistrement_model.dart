// Représente un enregistrement (replay) d une classe virtuelle.
class Enregistrement {
  final String id;
  final String classeVirtuelleId;
  final String formationId;
  final String titre;
  final String urlVideo;
  final DateTime createdAt;

  const Enregistrement({
    required this.id,
    required this.classeVirtuelleId,
    required this.formationId,
    required this.titre,
    required this.urlVideo,
    required this.createdAt,
  });

  factory Enregistrement.fromJson(Map<String, dynamic> json) {
    return Enregistrement(
      id: json['_id'] as String,
      classeVirtuelleId: json['classeVirtuelleId'] as String? ?? '',
      formationId: json['formationId'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      urlVideo: json['urlVideo'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
