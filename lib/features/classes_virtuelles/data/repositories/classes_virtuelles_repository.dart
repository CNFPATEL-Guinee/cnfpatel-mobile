import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/classe_virtuelle_model.dart';

class ClassesVirtuellesRepository {
  final Dio _dio;
  ClassesVirtuellesRepository(this._dio);

  Future<List<ClasseVirtuelle>> getClasses(String formationId) async {
    final response = await _dio.get(ApiEndpoints.formationClasses(formationId));
    final data = response.data as List;
    return data
        .map((json) => ClasseVirtuelle.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final classesVirtuellesRepositoryProvider =
    Provider<ClassesVirtuellesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ClassesVirtuellesRepository(dio);
});
