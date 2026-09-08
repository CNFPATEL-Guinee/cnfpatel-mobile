import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentification/providers/auth_controller.dart';
import '../data/models/certificat_model.dart';
import '../data/repositories/certificats_repository.dart';

final certificatsProvider = FutureProvider.autoDispose<List<Certificat>>((ref) async {
  final repo = ref.watch(certificatsRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final utilisateurId = authState is AuthConnecte ? authState.utilisateur.id : '';
  return repo.getCertificats(utilisateurId);
});
