class Certificat {
  final String id;
  final String formationTitre;
  final DateTime dateDelivrance;

  const Certificat({
    required this.id,
    required this.formationTitre,
    required this.dateDelivrance,
  });

  factory Certificat.fromJson(Map<String, dynamic> json) {
    // formationId est "populé" côté backend, donc c est un objet avec titre.
    final formation = json['formationId'] as Map<String, dynamic>?;
    return Certificat(
      id: json['_id'] as String,
      formationTitre: formation?['titre'] as String? ?? 'Formation',
      dateDelivrance: DateTime.parse(json['createdAt'] as String),
    );
  }
}
