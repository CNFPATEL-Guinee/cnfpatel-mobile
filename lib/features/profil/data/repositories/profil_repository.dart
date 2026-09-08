import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class ErreurModificationMotDePasse implements Exception {
  final String message;
  ErreurModificationMotDePasse(this.message);
}

class ProfilRepository {
  final Dio _dio;
  ProfilRepository(this._dio);

  Future<void> modifierMotDePasse({
    required String utilisateurId,
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    try {
      await _dio.patch(
        ApiEndpoints.modifierMotDePasse(utilisateurId),
        data: {
          'ancienMotDePasse': ancienMotDePasse,
          'nouveauMotDePasse': nouveauMotDePasse,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ErreurModificationMotDePasse('Ancien mot de passe incorrect.');
      }
      throw ErreurModificationMotDePasse('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}

final profilRepositoryProvider = Provider<ProfilRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfilRepository(dio);
});
