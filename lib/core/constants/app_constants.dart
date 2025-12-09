/// Application-wide constants for configuration and magic numbers
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ==================== Pengumuman Module ====================

  /// Jumlah pengumuman yang ditampilkan di dashboard warga
  static const int dashboardPengumumanLimit = 3;

  /// Tinggi header detail pengumuman (SliverAppBar expanded height)
  static const double pengumumanDetailHeaderHeight = 250.0;

  /// Tinggi thumbnail pengumuman di card list
  static const double pengumumanThumbnailSize = 90.0;

  /// Tinggi foto preview di all pengumuman page
  static const double pengumumanPreviewHeight = 180.0;

  /// Border radius untuk card pengumuman
  static const double pengumumanCardRadius = 12.0;

  /// Jarak antar card pengumuman di dashboard
  static const double pengumumanCardSpacing = 6.0;

  // ==================== Realtime Channels ====================

  /// Channel name untuk realtime pengumuman aktif (dashboard)
  static const String realtimeChannelPengumumanAktif = 'pengumuman_aktif';

  /// Channel name untuk realtime pengumuman user (kelola)
  static const String realtimeChannelPengumumanUser = 'pengumuman_user';

  /// Channel name untuk realtime semua pengumuman (warga)
  static const String realtimeChannelPengumumanAll = 'pengumuman_all';

  // ==================== UI Text Constants ====================

  /// Text untuk placeholder pengumuman tanpa foto
  static const String pengumumanNoPhotoText = 'Pengumuman Tanpa Foto';

  /// Text untuk placeholder thumbnail tanpa foto
  static const String pengumumanNoPhotoShort = 'Tanpa\nFoto';

  /// Text untuk error loading foto
  static const String pengumumanPhotoErrorText = 'Gagal memuat foto';
}
