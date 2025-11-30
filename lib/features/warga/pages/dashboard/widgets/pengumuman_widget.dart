import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/pengumuman_provider.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/widgets/pengumuman_placeholder.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../sekretaris/pengumuman/detail_pengumuman_page.dart';
import '../../pengumuman/all_pengumuman_page.dart';

/// Widget untuk menampilkan pengumuman terbaru di dashboard warga
class PengumumanWidget extends ConsumerWidget {
  const PengumumanWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pengumumanAsync = ref.watch(pengumumanAktifProvider);

    return pengumumanAsync.when(
      data: (pengumumanList) {
        if (pengumumanList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.campaign,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pengumuman Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Push tanpa CustomTopBar dan navbar
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => const AllPengumumanPage(),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List Pengumuman Cards - Compact Design
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  pengumumanList.length > AppConstants.dashboardPengumumanLimit
                  ? AppConstants.dashboardPengumumanLimit
                  : pengumumanList.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppConstants.pengumumanCardSpacing),
              itemBuilder: (context, index) {
                final pengumuman = pengumumanList[index];
                return Card(
                  elevation: 2,
                  color: Colors.white,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Push tanpa CustomTopBar dan navbar
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPengumumanPage(pengumumanId: pengumuman.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail (jika ada foto)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: pengumuman.hasFoto
                                ? Image.network(
                                    pengumuman.fotoUrl!,
                                    width: AppConstants.pengumumanThumbnailSize,
                                    height:
                                        AppConstants.pengumumanThumbnailSize,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) {
                                      return PengumumanPlaceholder.thumbnail();
                                    },
                                  )
                                : PengumumanPlaceholder.thumbnail(),
                          ),
                          const SizedBox(width: 14),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Judul
                                Text(
                                  pengumuman.judul,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                // Preview Isi
                                Text(
                                  pengumuman.isi,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Footer: Tanggal, Role & Dokumen Icon
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormatter.formatDateTime(
                                        pengumuman.updatedAt ??
                                            pengumuman.createdAt,
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        pengumuman.rolePembuat,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (pengumuman.hasDokumen) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.attach_file,
                                        size: 16,
                                        color: Colors.grey[600],
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
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.campaign, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pengumuman Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
