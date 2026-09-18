import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/models/utilisateur_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/session_storage.dart';

sealed class AuthState {
  const AuthState();
}

class AuthVerificationEnCours extends AuthState {
  const AuthVerificationEnCours();
}

class AuthNonConnecte extends AuthState {
  final String? messageErreur;
  const AuthNonConnecte({this.messageErreur});
}

class AuthConnexionEnCours extends AuthState {
  const AuthConnexionEnCours();
}

class AuthConnecte extends AuthState {
  final Utilisateur utilisateur;
  const AuthConnecte(this.utilisateur);
}

// Etats propres a l ecran d inscription (separes de la connexion, pour
// ne pas se marcher dessus si les deux ecrans existent en meme temps).
sealed class InscriptionState {
  const InscriptionState();
}

class InscriptionInitiale extends InscriptionState {
  const InscriptionInitiale();
}

class InscriptionEnCours extends InscriptionState {
  const InscriptionEnCours();
}

class InscriptionReussie extends InscriptionState {
  final String message;
  const InscriptionReussie(this.message);
}

class InscriptionEchouee extends InscriptionState {
  final String message;
  const InscriptionEchouee(this.message);
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

// Controleur separe pour l inscription, pour ne pas interferer avec l
// etat de connexion (l utilisateur n est jamais connecte apres une
// inscription, puisqu elle reste en attente d approbation).
class InscriptionController extends StateNotifier<InscriptionState> {
  final AuthRepository _repository;
  InscriptionController(this._repository) : super(const InscriptionInitiale());

  Future<void> inscrire({
    required String nom,
    required String prenom,
    required String telephone,
    required String motDePasse,
    required String role,
    String? rang,
  }) async {
    state = const InscriptionEnCours();
    try {
      final message = await _repository.inscrire(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        motDePasse: motDePasse,
        role: role,
        rang: rang,
      );
      state = InscriptionReussie(message);
    } on ErreurInscription catch (e) {
      state = InscriptionEchouee(e.message);
    } catch (_) {
      state = const InscriptionEchouee('Une erreur est survenue. Veuillez réessayer.');
    }
  }

  void reinitialiser() => state = const InscriptionInitiale();
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionStorageProvider),
    ref,
  );
});

final inscriptionControllerProvider =
    StateNotifierProvider<InscriptionController, InscriptionState>((ref) {
  return InscriptionController(ref.watch(authRepositoryProvider));
});
