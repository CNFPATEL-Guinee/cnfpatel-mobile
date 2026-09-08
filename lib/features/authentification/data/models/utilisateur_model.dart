// Ce fichier decrit ce qu est un "Utilisateur" dans notre application :
// quelles informations on garde sur lui, et comment les transformer
// depuis la reponse JSON envoyee par l API.
// La liste des roles possibles dans l application (voir le cahier des
// charges, section "Roles et permissions").
enum RoleUtilisateur { apprenant, formateur, adminRegional, adminNational }
// Convertit le texte du role envoye par l API (ex: "admin_regional")
// en une des valeurs de l enum ci-dessus.
RoleUtilisateur roleDepuisTexte(String texte) {
  switch (texte) {
    case 'formateur':
      return RoleUtilisateur.formateur;
    case 'admin_regional':
      return RoleUtilisateur.adminRegional;
    case 'admin_national':
      return RoleUtilisateur.adminNational;
    default:
      return RoleUtilisateur.apprenant;
  }
}
// Represente un utilisateur connecte (apprenant, formateur, ou admin).
// Correspond a la table "Utilisateur" du cahier des charges.
class Utilisateur {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final RoleUtilisateur role;
  final String? regionId; // vide (null) si l utilisateur est admin national
  // Fonction/rang administratif de l apprenant (ex: "Prefet",
  // "Sous-prefet"...), utilise pour filtrer les formations visibles.
  // Null si non precise, ou pour les formateurs/admins.
  final String? rang;
  const Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    this.regionId,
    this.rang,
  });
  // Petit raccourci pratique pour afficher "Prenom Nom" dans l interface.
  String get nomComplet => '$prenom $nom';
  // Transforme la reponse JSON de l API (un Map) en objet Utilisateur
  // que le reste de l application peut utiliser facilement.
  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'].toString(),
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      role: roleDepuisTexte(json['role'] as String? ?? 'apprenant'),
      regionId: json['region_id']?.toString(),
      rang: json['rang'] as String?,
    );
  }
}
