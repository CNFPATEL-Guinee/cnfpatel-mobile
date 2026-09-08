// Représente une formation, telle que renvoyée par notre backend.
class Formation {
  final String id;
  final String titre;
  final String description;
  final String? regionId;
  final String? imageUrl;
  final double progressionPourcentage;

  const Formation({
    required this.id,
    required this.titre,
    required this.description,
    this.regionId,
    this.imageUrl,
    this.progressionPourcentage = 0,
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['_id'] as String,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      regionId: json['regionId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      progressionPourcentage:
          (json['progressionPourcentage'] as num?)?.toDouble() ?? 0,
    );
  }

  bool get estNationale => regionId == null;
}