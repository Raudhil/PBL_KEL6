import 'package:flutter/material.dart';

class NotificationSettingsModel {
  final int userId;
  final bool enablePengumuman;
  final bool enableKegiatan;
  final bool enableIuran;
  final bool enableMarketplace;
  final bool enableSystem;
  final bool enablePush;
  final bool enableSound;
  final bool enableVibration;
  final String? quietHoursStart; // Format: 'HH:MM:SS'
  final String? quietHoursEnd;
  final int autoClearDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationSettingsModel({
    required this.userId,
    this.enablePengumuman = true,
    this.enableKegiatan = true,
    this.enableIuran = true,
    this.enableMarketplace = true,
    this.enableSystem = true,
    this.enablePush = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.autoClearDays = 30,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      userId: json['user_id'] as int,
      enablePengumuman: json['enable_pengumuman'] as bool? ?? true,
      enableKegiatan: json['enable_kegiatan'] as bool? ?? true,
      enableIuran: json['enable_iuran'] as bool? ?? true,
      enableMarketplace: json['enable_marketplace'] as bool? ?? true,
      enableSystem: json['enable_system'] as bool? ?? true,
      enablePush: json['enable_push'] as bool? ?? true,
      enableSound: json['enable_sound'] as bool? ?? true,
      enableVibration: json['enable_vibration'] as bool? ?? true,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
      autoClearDays: json['auto_clear_days'] as int? ?? 30,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'enable_pengumuman': enablePengumuman,
      'enable_kegiatan': enableKegiatan,
      'enable_iuran': enableIuran,
      'enable_marketplace': enableMarketplace,
      'enable_system': enableSystem,
      'enable_push': enablePush,
      'enable_sound': enableSound,
      'enable_vibration': enableVibration,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'auto_clear_days': autoClearDays,
    };
  }

  NotificationSettingsModel copyWith({
    int? userId,
    bool? enablePengumuman,
    bool? enableKegiatan,
    bool? enableIuran,
    bool? enableMarketplace,
    bool? enableSystem,
    bool? enablePush,
    bool? enableSound,
    bool? enableVibration,
    String? quietHoursStart,
    String? quietHoursEnd,
    int? autoClearDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettingsModel(
      userId: userId ?? this.userId,
      enablePengumuman: enablePengumuman ?? this.enablePengumuman,
      enableKegiatan: enableKegiatan ?? this.enableKegiatan,
      enableIuran: enableIuran ?? this.enableIuran,
      enableMarketplace: enableMarketplace ?? this.enableMarketplace,
      enableSystem: enableSystem ?? this.enableSystem,
      enablePush: enablePush ?? this.enablePush,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      autoClearDays: autoClearDays ?? this.autoClearDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method untuk cek quiet hours
  bool isQuietTime() {
    if (quietHoursStart == null || quietHoursEnd == null) return false;

    final now = TimeOfDay.now();
    final start = _parseTimeOfDay(quietHoursStart!);
    final end = _parseTimeOfDay(quietHoursEnd!);

    if (start.hour < end.hour) {
      // Normal case: 22:00 - 07:00
      return now.hour >= start.hour || now.hour < end.hour;
    } else {
      // Edge case: 07:00 - 22:00
      return now.hour >= start.hour && now.hour < end.hour;
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
