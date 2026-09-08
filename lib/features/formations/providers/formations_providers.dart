import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentification/providers/auth_controller.dart';
import '../data/models/cours_model.dart';
import '../data/models/formation_model.dart';
import '../data/models/module_model.dart';
import '../data/repositories/formations_repository.dart';

// Liste des formations, filtree automatiquement selon le rang de
// l apprenant connecte (ex: un sous-prefet ne voit pas les formations
// reservees aux prefets). Les formateurs/admins voient tout (pas de rang).
final formationsListProvider = FutureProvider.autoDispose<List<Formation>>((
  ref,
) async {
  final repo = ref.watch(formationsRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final rang = authState is AuthConnecte ? authState.utilisateur.rang : null;
  return repo.getFormations(rang: rang);
});
final formationModulesProvider = FutureProvider.autoDispose
    .family<List<ModuleFormation>, String>((ref, formationId) async {
      final repo = ref.watch(formationsRepositoryProvider);
      return repo.getModules(formationId);
    });
final moduleCoursProvider = FutureProvider.autoDispose
    .family<List<Cours>, String>((ref, moduleId) async {
      final repo = ref.watch(formationsRepositoryProvider);
      return repo.getCoursDuModule(moduleId);
    });
