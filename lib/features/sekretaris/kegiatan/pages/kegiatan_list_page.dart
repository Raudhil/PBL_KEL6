import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../data/models/kegiatan_model.dart';
import '../../../../core/providers/kegiatan_provider.dart';
import 'kegiatan_detail_page.dart';
import 'kegiatan_form_page.dart';

class KegiatanListPage extends ConsumerStatefulWidget {
  const KegiatanListPage({super.key});

  @override
  ConsumerState<KegiatanListPage> createState() => _KegiatanListPageState();
}

class _KegiatanListPageState extends ConsumerState<KegiatanListPage> {
  final TextEditingController _searchController = TextEditingController();
  StatusKegiatan? _selectedStatus;
  KategoriKegiatan? _selectedKategori;

  @override
  void initState() {
    super.initState();
    // Set filter untuk hanya menampilkan kegiatan user yang login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kegiatanListProvider.notifier).setCreatedByCurrentUser(true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kegiatanState = ref.watch(kegiatanListProvider);

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kelola Kegiatan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari kegiatan...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                                ref
                                    .read(kegiatanListProvider.notifier)
                                    .setSearchQuery(null);
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.greyLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      ref
                          .read(kegiatanListProvider.notifier)
                          .setSearchQuery(value.isEmpty ? null : value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Filter button
                _buildFilterButton(),
              ],
            ),
          ),

          // Filter chips
          if (_selectedStatus != null || _selectedKategori != null)
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  if (_selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedStatus!.label),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _selectedStatus = null);
                          ref
                              .read(kegiatanListProvider.notifier)
                              .setStatusFilter(null);
                        },
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_selectedKategori != null)
                    Chip(
                      label: Text(_selectedKategori!.label),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() => _selectedKategori = null);
                        ref
                            .read(kegiatanListProvider.notifier)
                            .setKategoriFilter(null);
                      },
                      backgroundColor: AppColors.primary400.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: AppColors.primary400,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

          // List kegiatan
          Expanded(
            child: kegiatanState.when(
              data: (kegiatanList) {
                if (kegiatanList.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(kegiatanListProvider.notifier).loadKegiatan();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: kegiatanList.length,
                    itemBuilder: (context, index) {
                      final kegiatan = kegiatanList[index];
                      return _buildKegiatanCard(kegiatan);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(kegiatanListProvider.notifier).loadKegiatan();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const KegiatanFormPage()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'Tambah Kegiatan',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildKegiatanCard(KegiatanModel kegiatan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.greyLight.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => KegiatanDetailPage(kegiatanId: kegiatan.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getKategoriColor(kegiatan.kategori).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getKategoriIcon(kegiatan.kategori),
                  color: _getKategoriColor(kegiatan.kategori),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Right side - Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(kegiatan.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        kegiatan.status.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Judul
                    Text(
                      kegiatan.judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Kategori
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _getKategoriColor(kegiatan.kategori),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          kegiatan.kategori.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getKategoriColor(kegiatan.kategori),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Info rows
                    _buildInfoRow(
                      Icons.calendar_today_rounded,
                      kegiatan.durasi,
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.location_on_rounded,
                      kegiatan.lokasi ?? 'Belum ditentukan',
                    ),
                    if (kegiatan.kuotaPeserta != null) ...[
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.people_rounded,
                        'Kuota: ${kegiatan.kuotaPeserta} orang',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getKategoriIcon(KategoriKegiatan kategori) {
    switch (kategori) {
      case KategoriKegiatan.sosial:
        return Icons.people_rounded;
      case KategoriKegiatan.kebersihan:
        return Icons.cleaning_services_rounded;
      case KategoriKegiatan.kesehatan:
        return Icons.local_hospital_rounded;
      case KategoriKegiatan.pendidikan:
        return Icons.school_rounded;
      case KategoriKegiatan.keagamaan:
        return Icons.mosque_rounded;
      case KategoriKegiatan.olahraga:
        return Icons.sports_soccer_rounded;
      case KategoriKegiatan.budaya:
        return Icons.theater_comedy_rounded;
      case KategoriKegiatan.lainnya:
        return Icons.more_horiz_rounded;
    }
  }

  Widget _buildFilterButton() {
    final hasFilter = _selectedStatus != null || _selectedKategori != null;

    return Container(
      decoration: BoxDecoration(
        color: hasFilter ? AppColors.primary : AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFilter ? AppColors.primary : AppColors.greyLight,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showFilterBottomSheet,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: hasFilter ? AppColors.white : AppColors.textPrimary,
                  size: 22,
                ),
                if (hasFilter)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada kegiatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kegiatan baru dengan tombol di bawah',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.filter_list_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Filter Kegiatan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status filter
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: StatusKegiatan.values.map((status) {
                        final isSelected = _selectedStatus == status;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              _selectedStatus = isSelected ? null : status;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.greyLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              status.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Kategori filter
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: KategoriKegiatan.values.map((kategori) {
                        final isSelected = _selectedKategori == kategori;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              _selectedKategori = isSelected ? null : kategori;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _getKategoriColor(
                                      kategori,
                                    ).withOpacity(0.15)
                                  : AppColors.greyLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? _getKategoriColor(kategori)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              kategori.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? _getKategoriColor(kategori)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedStatus = null;
                                _selectedKategori = null;
                              });
                              setState(() {
                                _selectedStatus = null;
                                _selectedKategori = null;
                              });
                              ref
                                  .read(kegiatanListProvider.notifier)
                                  .clearFilters();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(
                                color: AppColors.greyLight,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              ref
                                  .read(kegiatanListProvider.notifier)
                                  .setStatusFilter(_selectedStatus);
                              ref
                                  .read(kegiatanListProvider.notifier)
                                  .setKategoriFilter(_selectedKategori);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.white,
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getKategoriColor(KategoriKegiatan kategori) {
    switch (kategori) {
      case KategoriKegiatan.sosial:
        return AppColors.primary;
      case KategoriKegiatan.kebersihan:
        return AppColors.success;
      case KategoriKegiatan.kesehatan:
        return const Color(0xFFEF4444);
      case KategoriKegiatan.pendidikan:
        return const Color(0xFF8B5CF6);
      case KategoriKegiatan.keagamaan:
        return const Color(0xFF10B981);
      case KategoriKegiatan.olahraga:
        return const Color(0xFFF59E0B);
      case KategoriKegiatan.budaya:
        return const Color(0xFFEC4899);
      case KategoriKegiatan.lainnya:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(StatusKegiatan status) {
    switch (status) {
      case StatusKegiatan.akanDatang:
        return AppColors.primary;
      case StatusKegiatan.sedangBerlangsung:
        return AppColors.warning;
      case StatusKegiatan.selesai:
        return AppColors.success;
      case StatusKegiatan.dibatalkan:
        return AppColors.danger;
    }
  }
}
