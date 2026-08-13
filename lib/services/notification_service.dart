import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/notification_item.dart';

class NotificationService {
  final _api = ApiClient();

  Future<({List<NotificationItem> items, int unreadCount, int total})>
      list({bool? unread, int perPage = 30}) async {
    final data = await _api.get(Endpoints.notifications, queryParameters: {
      if (unread != null) 'unread': unread,
      'per_page': perPage,
    });

    final items = (data['data'] as List?)
            ?.map((e) =>
                NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final unreadCount = data['unread_count'] as int? ?? 0;
    final total = (data['meta'] as Map?)?['total'] as int? ?? items.length;
    return (items: items, unreadCount: unreadCount, total: total);
  }

  Future<void> markRead(int id) async {
    await _api.post(Endpoints.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _api.post(Endpoints.notificationsReadAll);
  }

  Future<List<Map<String, dynamic>>> preferences() async {
    final data = await _api.get(Endpoints.notificationPreferences);
    return (data['preferences'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> updatePreferences(
      List<Map<String, dynamic>> prefs) async {
    await _api.put(Endpoints.notificationPreferences, data: {
      'preferences': prefs,
    });
  }
}
