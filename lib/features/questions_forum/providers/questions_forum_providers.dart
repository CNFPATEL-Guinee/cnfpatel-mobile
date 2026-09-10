import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/question_forum_model.dart';
import '../data/repositories/questions_forum_repository.dart';

final questionsForumProvider = FutureProvider.autoDispose
    .family<List<QuestionForum>, String>((ref, formationId) async {
  final repo = ref.watch(questionsForumRepositoryProvider);
  return repo.getQuestions(formationId);
});
