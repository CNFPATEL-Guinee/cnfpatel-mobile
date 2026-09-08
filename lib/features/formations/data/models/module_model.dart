// Représente un module d'une formation, tel que renvoyé par le backend.
class ModuleFormation {
  final String id;
  final String formationId;
  final String titre;
  final int ordre;
  final double progressionPourcentage;

  const ModuleFormation({
    required this.id,
    required this.formationId,
    required this.titre,
    required this.ordre,
    this.progressionPourcentage = 0,
  });

  factory ModuleFormation.fromJson(Map<String, dynamic> json) {
    return ModuleFormation(
      id: json['_id'] as String,
      formationId: json['formationId'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      ordre: (json['ordre'] as num?)?.toInt() ?? 0,
      progressionPourcentage:
          (json['progressionPourcentage'] as num?)?.toDouble() ?? 0,
    );
  }
}
