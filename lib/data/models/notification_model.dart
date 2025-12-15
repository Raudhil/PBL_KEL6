class NotificationModel {
  final int id;
  final int userId;
  final String
  type; // 'pengumuman', 'kegiatan', 'iuran', 'marketplace', 'system'
  final String? category;
  final String priority; // 'high', 'medium', 'low'
  final String title;
  final String message;
  final int? referenceId;
  final String? referenceType;
  final String? actionUrl;
  final String? imageUrl;
  final Map<String, dynamic>? extraData;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? expiresAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.category,
    required this.priority,
    required this.title,
    required this.message,
    this.referenceId,
    this.referenceType,
    this.actionUrl,
    this.imageUrl,
    this.extraData,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.expiresAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: json['type'] as String,
      category: json['category'] as String?,
      priority: json['priority'] as String? ?? 'low',
      title: json['title'] as String,
      message: json['message'] as String,
      referenceId: json['reference_id'] as int?,
      referenceType: json['reference_type'] as String?,
      actionUrl: json['action_url'] as String?,
      imageUrl: json['image_url'] as String?,
      extraData: json['extra_data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'category': category,
      'priority': priority,
      'title': title,
      'message': message,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'action_url': actionUrl,
      'image_url': imageUrl,
      'extra_data': extraData,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? category,
    String? priority,
    String? title,
    String? message,
    int? referenceId,
    String? referenceType,
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? extraData,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      extraData: extraData ?? this.extraData,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  bool get isHighPriority => priority == 'high';
  bool get isMediumPriority => priority == 'medium';
  bool get isLowPriority => priority == 'low';
}
