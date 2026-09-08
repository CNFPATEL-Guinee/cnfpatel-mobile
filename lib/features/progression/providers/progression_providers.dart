import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentification/providers/auth_controller.dart';
import '../data/models/progression_model.dart';
import '../data/repositories/progression_repository.dart';

final progressionFormationProvider = FutureProvider.autoDispose
    .family<ProgressionFormation, String>((ref, formationId) async {
  final repo = ref.watch(progressionRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final utilisateurId = authState is AuthConnecte ? authState.utilisateur.id : '';
  return repo.getProgression(utilisateurId: utilisateurId, formationId: formationId);
});
