import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../providers/notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final formatDate = DateFormat('d MMM à HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(notificationsProvider),
            child: const Text('Erreur de chargement — Réessayer'),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucune notification pour le moment.'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return ListTile(
                  leading: Icon(
                    notif.lu ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                    color: notif.lu ? Colors.grey : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    notif.contenu,
                    style: TextStyle(fontWeight: notif.lu ? FontWeight.normal : FontWeight.w600),
                  ),
                  subtitle: Text(formatDate.format(notif.createdAt)),
                  onTap: () async {
                    if (!notif.lu) {
                      await ref.read(notificationsRepositoryProvider).marquerCommeLue(notif.id);
                      ref.invalidate(notificationsProvider);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
