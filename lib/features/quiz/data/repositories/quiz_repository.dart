import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/quiz_model.dart';
import '../models/resultat_quiz_model.dart';

// Exception levee quand le serveur refuse une nouvelle tentative
// (delai de 24h pas encore ecoule, ou score deja parfait).
class TentativeRefuseeException implements Exception {
  final String message;
  final DateTime? prochaineTentativePossible;
  TentativeRefuseeException(this.message, {this.prochaineTentativePossible});
}

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

  // Soumission finale — leve TentativeRefuseeException si le serveur
  // refuse (deja 100%, ou delai de 24h pas encore ecoule).
  Future<ResultatQuiz> soumettre({
    required String quizId,
    required String utilisateurId,
    required List<Map<String, String>> reponses,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.quizSoumettre(quizId),
        data: {'utilisateurId': utilisateurId, 'reponses': reponses},
      );
      return ResultatQuiz.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 || e.response?.statusCode == 429) {
        final data = e.response?.data as Map<String, dynamic>?;
        final dateTexte = data?['prochaineTentativePossible'] as String?;
        throw TentativeRefuseeException(
          data?['message'] as String? ?? 'Nouvelle tentative refusee.',
          prochaineTentativePossible: dateTexte != null ? DateTime.parse(dateTexte) : null,
        );
      }
      rethrow;
    }
  }

  // Renvoie la tentative la plus recente de l apprenant sur ce quiz,
  // ou null s il n en a jamais passe.
  Future<ResultatQuiz?> getResultatExistant({
    required String quizId,
    required String utilisateurId,
  }) async {
    try {
      final response = await _dio.get(ApiEndpoints.quizResultat(quizId, utilisateurId));
      if (response.data == null) return null;
      return ResultatQuiz.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return QuizRepository(dio);
});
