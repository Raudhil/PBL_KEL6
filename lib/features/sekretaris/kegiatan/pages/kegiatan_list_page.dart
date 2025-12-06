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
    // Stream will automatically provide realtime data
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Reset filter saat keluar dari halaman
    _selectedStatus = null;
    _selectedKategori = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch realtime stream untuk auto-update (hanya kegiatan user yang login)
    final kegiatanStreamAsync = ref.watch(kegiatanStreamByUserProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kelola Kegiatan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter bar
          Container(
            color: AppColors.creamWhite,
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
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.greyLight,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      // Just trigger rebuild, filter applied in build method
                      setState(() {});
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
              color: AppColors.creamWhite,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (_selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedStatus!.label,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                setState(() => _selectedStatus = null);
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_selectedKategori != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedKategori!.label,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              setState(() => _selectedKategori = null);
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // List kegiatan
          Expanded(
            child: kegiatanStreamAsync.when(
              data: (allKegiatan) {
                // Apply filters locally
                var filteredKegiatan = allKegiatan;

                // Filter by status if selected
                if (_selectedStatus != null) {
                  filteredKegiatan = filteredKegiatan
                      .where((k) => k.status == _selectedStatus)
                      .toList();
                }

                // Filter by kategori if selected
                if (_selectedKategori != null) {
                  filteredKegiatan = filteredKegiatan
                      .where((k) => k.kategori == _selectedKategori)
                      .toList();
                }

                // Filter by search query
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  filteredKegiatan = filteredKegiatan.where((k) {
                    return k.judul.toLowerCase().contains(query) ||
                        (k.deskripsi?.toLowerCase().contains(query) ?? false);
                  }).toList();
                }

                if (filteredKegiatan.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredKegiatan.length,
                  itemBuilder: (context, index) {
                    final kegiatan = filteredKegiatan[index];
                    return _buildKegiatanCard(kegiatan);
                  },
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => KegiatanDetailPage(kegiatanId: kegiatan.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris 1: Kategori (Kiri) - Status (Kanan)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Kiri: Icon + Kategori
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary600.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getKategoriIcon(kegiatan.kategori),
                            color: AppColors.primary600,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          kegiatan.kategori.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    // Kanan: Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(kegiatan.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        kegiatan.status.label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Baris 2: Judul (Full Width)
                Text(
                  kegiatan.judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Baris 3: Tanggal (Kiri) - Lokasi (Kanan)
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDateShort(kegiatan.tanggalMulai),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              kegiatan.lokasi ?? 'TBA',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Baris 4: Penyelenggara (Kiri) - Kuota (Kanan jika ada)
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: AppColors.primary600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              kegiatan.penyelenggara,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tampilkan kuota hanya jika ditentukan
                    if (kegiatan.kuotaPeserta != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              size: 14,
                              color: AppColors.primary600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${kegiatan.kuotaPeserta} peserta',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    final months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary.withOpacity(0.7)),
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
        color: hasFilter ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFilter ? AppColors.primary : AppColors.greyLight,
          width: 1,
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
                  color: hasFilter ? Colors.white : AppColors.textPrimary,
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
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setModalState(() {
                                _selectedStatus = null;
                                _selectedKategori = null;
                              });
                              setState(() {
                                _selectedStatus = null;
                                _selectedKategori = null;
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: const Text(
                              'Reset',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(
                                color: AppColors.danger,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(
                                () {},
                              ); // Trigger rebuild with new filters
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check_circle, size: 20),
                            label: const Text(
                              'Terapkan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.white,
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
}
