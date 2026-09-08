import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/classe_virtuelle_model.dart';
import '../data/repositories/classes_virtuelles_repository.dart';

final classesVirtuellesProvider = FutureProvider.autoDispose
    .family<List<ClasseVirtuelle>, String>((ref, formationId) async {
  final repo = ref.watch(classesVirtuellesRepositoryProvider);
  return repo.getClasses(formationId);
});
