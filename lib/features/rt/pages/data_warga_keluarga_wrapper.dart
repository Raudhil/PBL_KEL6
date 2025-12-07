import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/warga_provider.dart';
import '../../../core/widgets/custom_top_bar.dart';
import '../../../theme/app_colors.dart';
import 'warga_detail_page.dart';
import 'warga_form_page.dart';

class DataWargaKeluargaWrapper extends ConsumerStatefulWidget {
  const DataWargaKeluargaWrapper({super.key});

  @override
  ConsumerState<DataWargaKeluargaWrapper> createState() =>
      _DataWargaKeluargaWrapperState();
}

class _DataWargaKeluargaWrapperState
    extends ConsumerState<DataWargaKeluargaWrapper>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wargaNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        // Handle back button
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/warga/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: CustomTopBar(
          title: 'Data Warga & Keluarga',
          showBackButton: true,
          showNotification: false,
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/warga/dashboard');
            }
          },
        ),
        body: state.when(
          data: (list) {
            // Hitung total KK unik
            final uniqueKK = list.map((w) => w.idKk).toSet().length;

            // Group data warga berdasarkan ID KK
            final kkMap = <int, List<dynamic>>{};
            for (var w in list) {
              if (!kkMap.containsKey(w.idKk)) {
                kkMap[w.idKk] = [];
              }
              kkMap[w.idKk]!.add(w);
            }
            final kkList = kkMap.entries.toList();

            return list.isEmpty
                ? const Center(child: Text('Belum ada data warga'))
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      // Statistics Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TabButton(
                                title: 'Total Warga',
                                count: list.length,
                                icon: Icons.people,
                                isActive: _tabController.index == 0,
                                onTap: () {
                                  setState(() {
                                    _tabController.animateTo(
                                      0,
                                      duration: Duration.zero,
                                    );
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TabButton(
                                title: 'Total Keluarga',
                                count: uniqueKK,
                                icon: Icons.home,
                                isActive: _tabController.index == 1,
                                onTap: () {
                                  setState(() {
                                    _tabController.animateTo(
                                      1,
                                      duration: Duration.zero,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Tab 1: List Warga
                            _buildWargaList(list, context),
                            // Tab 2: List Keluarga
                            _buildKeluargaList(kkList, context),
                          ],
                        ),
                      ),
                    ],
                  );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildWargaList(List<dynamic> list, BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final w = list[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          shadowColor: Colors.black.withOpacity(0.15),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WargaDetailPage(warga: w)),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary50,
                child: Icon(Icons.person, color: AppColors.primary, size: 28),
              ),
              title: Text(
                w.namaLengkap,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NIK: ${w.nik}',
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'HP: ${w.nomorHp ?? '-'}',
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeluargaList(
    List<MapEntry<int, List<dynamic>>> kkList,
    BuildContext context,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: kkList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final entry = kkList[index];
        final idKk = entry.key;
        final members = entry.value;
        final kepalaKeluarga = members.first;

        return Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          shadowColor: Colors.black.withOpacity(0.15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Row(
                  children: [
                    // Icon Keluarga
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Info Keluarga
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keluarga #$idKk',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  kepalaKeluarga.namaLengkap,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Badge jumlah anggota
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            members.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Divider(height: 1, color: Colors.grey[300]),

                const SizedBox(height: 16),

                // Informasi Alamat
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kepalaKeluarga.alamat ?? 'Alamat tidak tersedia',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Info NIK
                Row(
                  children: [
                    Icon(Icons.badge, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'NIK: ${kepalaKeluarga.nik}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
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
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.count,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primary.withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isActive ? 15 : 10,
              offset: Offset(0, isActive ? 6 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.25)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : AppColors.primary,
                    size: 24,
                  ),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : AppColors.primary,
                    height: 1,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
