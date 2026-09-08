import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/certificat_model.dart';

class CertificatsRepository {
  final Dio _dio;
  CertificatsRepository(this._dio);

  Future<List<Certificat>> getCertificats(String utilisateurId) async {
    final response = await _dio.get(ApiEndpoints.certificats(utilisateurId));
    final data = response.data as List;
    return data.map((json) => Certificat.fromJson(json as Map<String, dynamic>)).toList();
  }
}

final certificatsRepositoryProvider = Provider<CertificatsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CertificatsRepository(dio);
});
