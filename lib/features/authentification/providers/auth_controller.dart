import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/models/utilisateur_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/session_storage.dart';

// Toutes les "situations" possibles dans lesquelles l'utilisateur peut se
// trouver vis-à-vis de la connexion.
sealed class AuthState {
  const AuthState();
}

// Au tout premier lancement de l'app : on vérifie s'il existe déjà une
// session enregistrée sur le téléphone, avant d'afficher quoi que ce soit.
class AuthVerificationEnCours extends AuthState {
  const AuthVerificationEnCours();
}

// Personne n'est connecté — l'écran de connexion doit s'afficher.
class AuthNonConnecte extends AuthState {
  final String? messageErreur;
  const AuthNonConnecte({this.messageErreur});
}

// L'utilisateur vient d'appuyer sur "Se connecter", on attend la réponse
// du serveur.
class AuthConnexionEnCours extends AuthState {
  const AuthConnexionEnCours();
}

// La connexion a réussi.
class AuthConnecte extends AuthState {
  final Utilisateur utilisateur;
  const AuthConnecte(this.utilisateur);
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SessionStorage _sessionStorage;
  final Ref _ref;

  AuthController(this._repository, this._sessionStorage, this._ref)
      : super(const AuthVerificationEnCours()) {
    _verifierSessionExistante();
  }

  Future<void> _verifierSessionExistante() async {
    final session = await _sessionStorage.lireSession();
    if (session == null) {
      state = const AuthNonConnecte();
      return;
    }
    final (token, utilisateur) = session;
    _ref.read(authTokenProvider.notifier).state = token;
    state = AuthConnecte(utilisateur);
  }

  Future<void> connecter({
    required String telephone,
    required String motDePasse,
  }) async {
    state = const AuthConnexionEnCours();
    try {
      final resultat = await _repository.connecter(
        telephone: telephone,
        motDePasse: motDePasse,
      );
      await _sessionStorage.enregistrer(
        token: resultat.token,
        utilisateur: resultat.utilisateur,
      );
      _ref.read(authTokenProvider.notifier).state = resultat.token;
      state = AuthConnecte(resultat.utilisateur);
    } on ErreurConnexion catch (e) {
      state = AuthNonConnecte(messageErreur: e.message);
    } catch (_) {
      state = const AuthNonConnecte(
        messageErreur: 'Une erreur est survenue. Veuillez réessayer.',
      );
    }
  }

  Future<void> deconnecter() async {
    await _sessionStorage.effacer();
    _ref.read(authTokenProvider.notifier).state = null;
    state = const AuthNonConnecte();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionStorageProvider),
    ref,
  );
});
