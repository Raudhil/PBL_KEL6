import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../data/models/kegiatan_model.dart';
import '../../../../core/providers/kegiatan_provider.dart';
import 'kegiatan_form_page.dart';

class KegiatanDetailPage extends ConsumerWidget {
  final String kegiatanId;
  final bool readOnly;

  const KegiatanDetailPage({
    super.key,
    required this.kegiatanId,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kegiatanAsync = ref.watch(kegiatanDetailProvider(kegiatanId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: kegiatanAsync.when(
        data: (kegiatan) {
          if (kegiatan == null) {
            return const Center(child: Text('Kegiatan tidak ditemukan'));
          }
          return _buildContent(context, ref, kegiatan);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: AppColors.danger),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    KegiatanModel kegiatan,
  ) {
    return CustomScrollView(
      slivers: [
        // App bar dengan foto
        SliverAppBar(
          expandedHeight: kegiatan.fotoUrl != null ? 250 : 120,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: kegiatan.fotoUrl != null
                ? GestureDetector(
                    onTap: () =>
                        _showFullPhotoDialog(context, kegiatan.fotoUrl!),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          kegiatan.fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primary,
                              child: const Icon(
                                Icons.event,
                                size: 80,
                                color: AppColors.white,
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary600, AppColors.primary400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status dan kategori badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                kegiatan.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              kegiatan.status.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(kegiatan.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getKategoriColor(
                                kegiatan.kategori,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              kegiatan.kategori.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getKategoriColor(kegiatan.kategori),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Judul
                      Text(
                        kegiatan.judul,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Penyelenggara
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary600.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 20,
                              color: AppColors.primary600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Penyelenggara',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  kegiatan.penyelenggara,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Pembuat (Created by) - Jika ada
                      if (kegiatan.createdBy != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary600.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 20,
                                color: AppColors.primary600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  // Debug print
                                  print(
                                    '🔑 Created By ID: ${kegiatan.createdBy}',
                                  );

                                  return FutureBuilder<String>(
                                    future: ref
                                        .read(userInfoServiceProvider)
                                        .getUserName(kegiatan.createdBy!),
                                    builder: (context, snapshot) {
                                      final creatorName =
                                          snapshot.data ?? 'Loading...';
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dibuat oleh',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            creatorName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info cards
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'Tanggal',
                  value: kegiatan.durasi,
                  iconColor: AppColors.primary600,
                ),

                const SizedBox(height: 12),

                _buildInfoCard(
                  icon: Icons.location_on,
                  title: 'Lokasi',
                  value: kegiatan.lokasi ?? 'Belum ditentukan',
                  iconColor: AppColors.primary600,
                ),

                if (kegiatan.kuotaPeserta != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.people,
                    title: 'Kuota Peserta',
                    value: '${kegiatan.kuotaPeserta} orang',
                    iconColor: AppColors.primary600,
                  ),
                ],

                const SizedBox(height: 20),

                // Deskripsi
                if (kegiatan.deskripsi != null &&
                    kegiatan.deskripsi!.isNotEmpty) ...[
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      kegiatan.deskripsi!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Action buttons - RBAC protected (Vertical Layout)
                if (!readOnly)
                  FutureBuilder<bool>(
                    future: ref
                        .read(userInfoServiceProvider)
                        .canEditKegiatan(kegiatan.createdBy ?? ''),
                    builder: (context, snapshot) {
                      final canEdit = snapshot.data ?? false;
                      if (!canEdit) return const SizedBox.shrink();

                      return Column(
                        children: [
                          // Edit Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        KegiatanFormPage(kegiatan: kegiatan),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_rounded, size: 20),
                              label: const Text(
                                'Edit Kegiatan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Delete Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showDeleteDialog(context, ref, kegiatan.id),
                              icon: const Icon(Icons.delete_rounded, size: 20),
                              label: const Text(
                                'Hapus Kegiatan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: const BorderSide(
                                  color: AppColors.danger,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hapus Kegiatan?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kegiatan yang dihapus tidak dapat dikembalikan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.greyLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.danger,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(kegiatanListProvider.notifier).deleteKegiatan(id);
        if (context.mounted) {
          // Show success modal instead of snackbar
          await _showSuccessDialog(
            context,
            'Hapus Berhasil',
            'Kegiatan berhasil dihapus',
          );
          // Navigate back after user closes success dialog
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _showSuccessDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.success,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getKategoriColor(KategoriKegiatan kategori) {
    switch (kategori) {
      case KategoriKegiatan.sosial:
        return AppColors.primary600;
      case KategoriKegiatan.kebersihan:
        return AppColors.success;
      case KategoriKegiatan.kesehatan:
        return AppColors.danger;
      case KategoriKegiatan.pendidikan:
        return AppColors.info;
      case KategoriKegiatan.keagamaan:
        return AppColors.success;
      case KategoriKegiatan.olahraga:
        return AppColors.warning;
      case KategoriKegiatan.budaya:
        return AppColors.primary400;
      case KategoriKegiatan.lainnya:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(StatusKegiatan status) {
    switch (status) {
      case StatusKegiatan.akanDatang:
        return AppColors.primary600;
      case StatusKegiatan.sedangBerlangsung:
        return AppColors.warning;
      case StatusKegiatan.selesai:
        return AppColors.success;
      case StatusKegiatan.dibatalkan:
        return AppColors.danger;
    }
  }

  void _showFullPhotoDialog(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Semi-transparent background
              Container(color: Colors.black.withOpacity(0.9)),
              // Close button
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              // Image
              InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat foto',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
