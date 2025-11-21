import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../pengumuman_detail_page.dart';

class AnnouncementItem {
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;
  final String? documentName;

  AnnouncementItem({
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    this.documentName,
  });
}

class AnnouncementListWidget extends StatelessWidget {
  final List<AnnouncementItem> announcements;

  const AnnouncementListWidget({super.key, required this.announcements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pengumuman Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: announcements.map((announcement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnnouncementCard(
                announcement: announcement,
                onTap: () => _openAnnouncementDetail(
                  context,
                  judul: announcement.title,
                  deskripsi: announcement.description,
                  foto: announcement.imageUrl,
                  dokumen: announcement.documentName,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _openAnnouncementDetail(
    BuildContext context, {
    required String judul,
    required String deskripsi,
    String? foto,
    String? dokumen,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailPage(
          judul: judul,
          deskripsi: deskripsi,
          foto: foto,
          dokumen: dokumen,
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementItem announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = date.day;
    final month = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month ${date.year}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  announcement.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.greyDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    announcement.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.greyDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(announcement.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyDark,
                        ),
                      ),
                      if (announcement.documentName != null) ...[
                        const Spacer(),
                        Icon(
                          Icons.attach_file,
                          size: 14,
                          color: AppColors.primary600,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
