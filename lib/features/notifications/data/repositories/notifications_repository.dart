import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  final Dio _dio;
  NotificationsRepository(this._dio);

  Future<List<NotificationApp>> getNotifications(String utilisateurId) async {
    final response = await _dio.get(ApiEndpoints.notifications(utilisateurId));
    final data = response.data as List;
    return data.map((json) => NotificationApp.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> marquerCommeLue(String notificationId) async {
    await _dio.patch(ApiEndpoints.notificationLue(notificationId));
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsRepository(dio);
});
