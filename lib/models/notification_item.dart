class NotificationItem {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime at;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.read = false,
    required this.at,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as int? ?? 0,
        type: json['type'] as String? ?? 'system',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: json['data'] as Map<String, dynamic>? ?? {},
        read: json['read'] as bool? ?? false,
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
      );

  NotificationItem markRead() => NotificationItem(
        id: id,
        type: type,
        title: title,
        body: body,
        data: data,
        read: true,
        at: at,
      );

  String get category {
    if (type.startsWith('bid')) return 'bid';
    if (type.startsWith('auction')) return 'auction';
    if (type.startsWith('wallet') || type.startsWith('emd')) return 'wallet';
    if (type.startsWith('order')) return 'order';
    return 'system';
  }
}
