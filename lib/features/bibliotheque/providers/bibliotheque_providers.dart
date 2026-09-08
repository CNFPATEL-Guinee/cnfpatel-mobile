import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/enregistrement_model.dart';
import '../data/repositories/bibliotheque_repository.dart';

final enregistrementsProvider = FutureProvider.autoDispose
    .family<List<Enregistrement>, String>((ref, formationId) async {
  final repo = ref.watch(bibliothequeRepositoryProvider);
  return repo.getEnregistrements(formationId);
});
