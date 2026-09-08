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

  String _messageLisible(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Connexion internet instable. Vérifiez votre réseau et réessayez.';
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
