enum NotificationType {
  commandeAcceptee,
  commandePrete,
  commandeEnRoute,
  reservationConfirmee,
  reservationRefusee,
  rappelReservation,
  autre,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
    this.type = NotificationType.autre,
  });

  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final NotificationType type;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readRaw = json['isRead'] ?? json['read'] ?? json['is_read'];
    final created = json['createdAt'] ?? json['created_at'] ?? json['date'];
    DateTime? createdAt;
    if (created is String) {
      createdAt = DateTime.tryParse(created);
    }

    return AppNotification(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? json['subject'] ?? 'Notification').toString(),
      body:
          (json['body'] ??
                  json['message'] ??
                  json['subtitle'] ??
                  json['content'] ??
                  '')
              .toString(),
      isRead: readRaw == true || readRaw == 'true',
      createdAt: createdAt,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.autre,
      ),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      type: type,
    );
  }
}
