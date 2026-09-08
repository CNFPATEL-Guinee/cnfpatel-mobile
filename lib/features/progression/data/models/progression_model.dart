class ProgressionModule {
  final String moduleId;
  final String titre;
  final int pourcentage;

  const ProgressionModule({
    required this.moduleId,
    required this.titre,
    required this.pourcentage,
  });

  factory ProgressionModule.fromJson(Map<String, dynamic> json) {
    return ProgressionModule(
      moduleId: json['moduleId'] as String,
      titre: json['titre'] as String,
      pourcentage: (json['pourcentage'] as num).toInt(),
    );
  }
}

class ProgressionFormation {
  final String formationId;
  final int pourcentageGlobal;
  final List<ProgressionModule> modules;

  const ProgressionFormation({
    required this.formationId,
    required this.pourcentageGlobal,
    required this.modules,
  });

  factory ProgressionFormation.fromJson(Map<String, dynamic> json) {
    return ProgressionFormation(
      formationId: json['formationId'] as String,
      pourcentageGlobal: (json['pourcentageGlobal'] as num).toInt(),
      modules: (json['modules'] as List)
          .map((m) => ProgressionModule.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
