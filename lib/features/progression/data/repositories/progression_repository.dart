import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/progression_model.dart';

class ProgressionRepository {
  final Dio _dio;
  ProgressionRepository(this._dio);

  Future<ProgressionFormation> getProgression({
    required String utilisateurId,
    required String formationId,
  }) async {
    final response = await _dio.get(ApiEndpoints.progression(utilisateurId, formationId));
    return ProgressionFormation.fromJson(response.data as Map<String, dynamic>);
  }
}

final progressionRepositoryProvider = Provider<ProgressionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProgressionRepository(dio);
});
