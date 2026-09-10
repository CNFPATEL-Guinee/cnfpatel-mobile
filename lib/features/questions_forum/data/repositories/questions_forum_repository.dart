import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/question_forum_model.dart';

class QuestionsForumRepository {
  final Dio _dio;
  QuestionsForumRepository(this._dio);

  Future<List<QuestionForum>> getQuestions(String formationId) async {
    final response = await _dio.get(ApiEndpoints.formationQuestions(formationId));
    final data = response.data as List;
    return data.map((json) => QuestionForum.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> poserQuestion(String formationId, String utilisateurId, String texte) async {
    await _dio.post(
      ApiEndpoints.formationQuestions(formationId),
      data: {'utilisateurId': utilisateurId, 'texte': texte},
    );
  }
}

final questionsForumRepositoryProvider = Provider<QuestionsForumRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return QuestionsForumRepository(dio);
});
