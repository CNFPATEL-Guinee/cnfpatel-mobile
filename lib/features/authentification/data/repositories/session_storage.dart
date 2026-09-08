import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/utilisateur_model.dart';

// Ce fichier sauvegarde la connexion de l'utilisateur SUR SON TÉLÉPHONE,
// pour qu'il n'ait pas à se reconnecter à chaque fois qu'il rouvre
// l'application (important vu que la connexion internet est parfois
// difficile — se reconnecter à chaque fois coûterait des données).
class SessionStorage {
  // Noms utilisés pour retrouver les informations sauvegardées.
  static const _cleToken = 'auth_token';
  static const _cleUtilisateur = 'auth_utilisateur';

  // Sauvegarde le jeton de connexion et les infos de l'utilisateur.
  Future<void> enregistrer({
    required String token,
    required Utilisateur utilisateur,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleToken, token);
    await prefs.setString(
      _cleUtilisateur,
      jsonEncode({
        'id': utilisateur.id,
        'nom': utilisateur.nom,
        'prenom': utilisateur.prenom,
        'telephone': utilisateur.telephone,
        'role': utilisateur.role.name,
        'region_id': utilisateur.regionId,
      }),
    );
  }

  // Relit la session sauvegardée (s'il y en a une). Utilisé au démarrage
  // de l'app pour savoir si on doit montrer l'écran de connexion ou non.
  Future<(String, Utilisateur)?> lireSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_cleToken);
    final utilisateurJson = prefs.getString(_cleUtilisateur);
    if (token == null || utilisateurJson == null) return null;
    return (token, Utilisateur.fromJson(jsonDecode(utilisateurJson)));
  }

  // Supprime la session sauvegardée (utilisé lors de la déconnexion).
  Future<void> effacer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cleToken);
    await prefs.remove(_cleUtilisateur);
  }
}

final sessionStorageProvider = Provider<SessionStorage>((ref) => SessionStorage());