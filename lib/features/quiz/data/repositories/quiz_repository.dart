import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/quiz_model.dart';
import '../models/resultat_quiz_model.dart';

class QuizRepository {
  final Dio _dio;
  QuizRepository(this._dio);

  Future<List<Quiz>> getQuizDuModule(String moduleId) async {
    final response = await _dio.get(ApiEndpoints.moduleQuiz(moduleId));
    final data = response.data as List;
    return data.map((json) => Quiz.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<QuestionQuiz>> getQuestions(String quizId) async {
    final response = await _dio.get(ApiEndpoints.quizQuestions(quizId));
    final data = response.data as List;
    return data.map((json) => QuestionQuiz.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Vérifie une réponse à la volée — renvoie si c était correct, et
  // l identifiant du bon choix (pour l afficher à l apprenant).
  Future<(bool estCorrect, String choixCorrectId)> verifierReponse({
    required String quizId,
    required String questionId,
    required String choixId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.quizVerifier(quizId),
      data: {'questionId': questionId, 'choixId': choixId},
    );
    final data = response.data as Map<String, dynamic>;
    return (data['estCorrect'] as bool, data['choixCorrectId'] as String);
  }

  // Soumission finale de toutes les réponses — calcule et enregistre le score.
  Future<ResultatQuiz> soumettre({
    required String quizId,
    required String utilisateurId,
    required List<Map<String, String>> reponses,
    required int seuilReussite,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.quizSoumettre(quizId),
      data: {'utilisateurId': utilisateurId, 'reponses': reponses},
    );
    return ResultatQuiz.fromJson(
      response.data as Map<String, dynamic>,
      seuilReussite: seuilReussite,
    );
  }

  // Vérifie si l apprenant a déjà passé ce quiz (pour bloquer une 2e tentative).
  Future<ResultatQuiz?> getResultatExistant({
    required String quizId,
    required String utilisateurId,
    required int seuilReussite,
  }) async {
    try {
      final response = await _dio.get(ApiEndpoints.quizResultat(quizId, utilisateurId));
      if (response.data == null) return null;
      return ResultatQuiz.fromJson(
        response.data as Map<String, dynamic>,
        seuilReussite: seuilReussite,
      );
    } catch (_) {
      return null;
    }
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return QuizRepository(dio);
});
