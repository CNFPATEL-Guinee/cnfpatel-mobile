import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/utilisateur_model.dart';

class ResultatConnexion {
  final String token;
  final Utilisateur utilisateur;
  ResultatConnexion({required this.token, required this.utilisateur});
}

class ErreurConnexion implements Exception {
  final String message;
  ErreurConnexion(this.message);
}

class ErreurInscription implements Exception {
  final String message;
  ErreurInscription(this.message);
}

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<ResultatConnexion> connecter({
    required String telephone,
    required String motDePasse,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.connexion(),
        data: {'telephone': telephone, 'motDePasse': motDePasse},
      );
      final data = response.data as Map<String, dynamic>;
      return ResultatConnexion(
        token: data['token'] as String,
        utilisateur: Utilisateur.fromJson(
          data['utilisateur'] as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      throw ErreurConnexion(_messageLisible(e));
    }
  }

  // Auto-inscription : renvoie simplement un message de succes, puisque
  // le compte reste en attente d approbation (pas de connexion automatique).
  Future<String> inscrire({
    required String nom,
    required String prenom,
    required String telephone,
    required String motDePasse,
    required String role,
    String? rang,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.inscription(),
        data: {
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'motDePasse': motDePasse,
          'role': role,
          if (rang != null) 'rang': rang,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ErreurInscription('Ce numéro de téléphone est déjà utilisé.');
      }
      throw ErreurInscription('Une erreur est survenue. Veuillez réessayer.');
    }
  }

  String _messageLisible(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Connexion internet instable. Vérifiez votre réseau et réessayez.';
    }
    // Compte en attente d approbation, ou refuse — le backend renvoie
    // un message clair dans ces deux cas (403).
    if (e.response?.statusCode == 403) {
      final data = e.response?.data as Map<String, dynamic>?;
      return data?['message'] as String? ?? 'Accès refusé.';
    }
    if (e.response?.statusCode == 401) {
      return 'Numéro de téléphone ou mot de passe incorrect.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});
