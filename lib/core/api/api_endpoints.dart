// Contrat d'API complet.
class ApiEndpoints {
  ApiEndpoints._();
  static String inscription() => '/auth/inscription';
  static String connexion() => '/auth/connexion';
  static String formations() => '/formations';
  static String formationModules(String formationId) => '/formations/$formationId/modules';
  static String moduleCours(String moduleId) => '/modules/$moduleId/cours';
  static String formationClasses(String formationId) => '/formations/$formationId/classes';
  static String formationEnregistrements(String formationId) =>
      '/formations/$formationId/enregistrements';
  static String moduleQuiz(String moduleId) => '/modules/$moduleId/quiz';
  static String quizQuestions(String quizId) => '/quiz/$quizId/questions';
  static String quizVerifier(String quizId) => '/quiz/$quizId/verifier';
  static String quizSoumettre(String quizId) => '/quiz/$quizId/soumettre';
  static String quizResultat(String quizId, String utilisateurId) =>
      '/quiz/$quizId/resultat/$utilisateurId';
  static String progression(String utilisateurId, String formationId) =>
      '/progression/$utilisateurId/$formationId';
  static String certificats(String utilisateurId) => '/certificats/$utilisateurId';
  // Genere et telecharge le PDF officiel du certificat (bordure, logos, sceau).
  static String certificatPdf(String certificatId) => '/certificats/$certificatId/pdf';
  static String notifications(String utilisateurId) => '/notifications/$utilisateurId';
  static String notificationLue(String notificationId) => '/notifications/$notificationId/lue';
  static String modifierMotDePasse(String utilisateurId) => '/profil/$utilisateurId/mot-de-passe';
  static String presences() => '/presences';
}
