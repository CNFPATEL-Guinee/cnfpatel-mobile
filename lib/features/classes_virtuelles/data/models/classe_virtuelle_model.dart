enum StatutClasse { prevue, enCours, terminee }

// Représente une classe virtuelle rattachée à une formation.
class ClasseVirtuelle {
  final String id;
  final String formationId;
  final String titre;
  final DateTime dateHeure;
  final String lienDirect;
  final StatutClasse statut;

  const ClasseVirtuelle({
    required this.id,
    required this.formationId,
    required this.titre,
    required this.dateHeure,
    required this.lienDirect,
    required this.statut,
  });

  factory ClasseVirtuelle.fromJson(Map<String, dynamic> json) {
    return ClasseVirtuelle(
      id: json['_id'] as String,
      formationId: json['formationId'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      dateHeure: DateTime.parse(json['dateHeure'] as String),
      lienDirect: json['lienDirect'] as String? ?? '',
      statut: switch (json['statut'] as String?) {
        'en_cours' => StatutClasse.enCours,
        'terminee' => StatutClasse.terminee,
        _ => StatutClasse.prevue,
      },
    );
  }

  bool get estPassee => dateHeure.isBefore(DateTime.now());
}
