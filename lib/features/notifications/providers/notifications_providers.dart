import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentification/providers/auth_controller.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notifications_repository.dart';

final notificationsProvider = FutureProvider.autoDispose<List<NotificationApp>>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  final utilisateurId = authState is AuthConnecte ? authState.utilisateur.id : '';
  return repo.getNotifications(utilisateurId);
});
