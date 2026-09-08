// Repository Formations avec mise en cache locale simple, pour rester
// consultable meme sans connexion (une fois charge une premiere fois).
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/cours_model.dart';
import '../models/formation_model.dart';
import '../models/module_model.dart';
class FormationsRepository {
  final Dio _dio;
  FormationsRepository(this._dio);
  static const _cleCache = 'cache_formations';
  // Si un rang est fourni, seules les formations accessibles a ce rang
  // (rang cible identique OU aucun rang cible) sont renvoyees par le
  // serveur.
  Future<List<Formation>> getFormations({String? rang}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.formations(),
        queryParameters: rang != null ? {'rang': rang} : null,
      );
      final data = response.data as List;
      final formations = data
          .map((json) => Formation.fromJson(json as Map<String, dynamic>))
          .toList();
      // Sauvegarde en cache pour consultation hors-ligne future.
      await _sauvegarderCache(data);
      return formations;
    } on DioException {
      // Pas de connexion — on tente de servir depuis le cache local.
      final donneesCachees = await _lireCache();
      if (donneesCachees != null) {
        return donneesCachees
            .map((json) => Formation.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      rethrow; // aucun cache disponible, on laisse l erreur remonter normalement
    }
  }
  Future<void> _sauvegarderCache(List donnees) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleCache, jsonEncode(donnees));
  }
  Future<List?> _lireCache() async {
    final prefs = await SharedPreferences.getInstance();
    final texte = prefs.getString(_cleCache);
    if (texte == null) return null;
    return jsonDecode(texte) as List;
  }
  Future<List<ModuleFormation>> getModules(String formationId) async {
    final response = await _dio.get(ApiEndpoints.formationModules(formationId));
    final data = response.data as List;
    return data
        .map((json) => ModuleFormation.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  Future<List<Cours>> getCoursDuModule(String moduleId) async {
    final response = await _dio.get(ApiEndpoints.moduleCours(moduleId));
    final data = response.data as List;
    return data.map((json) => Cours.fromJson(json as Map<String, dynamic>)).toList();
  }
}
final formationsRepositoryProvider = Provider<FormationsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FormationsRepository(dio);
});
