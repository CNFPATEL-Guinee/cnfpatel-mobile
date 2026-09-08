import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/enregistrement_model.dart';

class BibliothequeRepository {
  final Dio _dio;
  BibliothequeRepository(this._dio);

  Future<List<Enregistrement>> getEnregistrements(String formationId) async {
    final response = await _dio.get(ApiEndpoints.formationEnregistrements(formationId));
    final data = response.data as List;
    return data
        .map((json) => Enregistrement.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final bibliothequeRepositoryProvider = Provider<BibliothequeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BibliothequeRepository(dio);
});
