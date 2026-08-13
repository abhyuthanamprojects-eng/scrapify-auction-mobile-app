import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';

final _notifService = NotificationService();

final notificationsProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  final result = await _notifService.list();
  return result.items;
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final result = await _notifService.list(unread: true, perPage: 1);
  return result.unreadCount;
});
