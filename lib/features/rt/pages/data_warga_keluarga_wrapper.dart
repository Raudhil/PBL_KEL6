import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/warga_provider.dart';
import '../../../core/widgets/custom_top_bar.dart';
import '../../../theme/app_colors.dart';
import '../widgets/warga_card.dart';
import '../widgets/keluarga_card.dart';
import 'create_warga_page.dart';

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

  // Search & Filter states
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter; // 'Aktif', 'Tidak Aktif', atau null (semua)

  // Expansion state management
  int? _expandedWargaId; // Track expanded warga card
  final Map<int, GlobalKey> _cardKeys = {}; // Keys for each card

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Reset search dan filter saat pindah tab
      if (mounted) {
        setState(() {
          _searchController.clear();
          _searchQuery = '';
          _statusFilter = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                      const SizedBox(height: 16),

                      // Search & Filter Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSearchAndFilter(),
                      ),
                      const SizedBox(height: 16),

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CreateWargaPage()));
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // Widget Search & Filter
  Widget _buildSearchAndFilter() {
    final isWargaTab = _tabController.index == 0;

    return Row(
      children: [
        // Search Field
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: isWargaTab
                    ? 'Cari nama atau NIK...'
                    : 'Cari nomor KK...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),

        // Filter Button (hanya untuk tab warga)
        if (isWargaTab) ...[
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _statusFilter != null ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _statusFilter != null
                    ? AppColors.primary
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildWargaFilter(),
          ),
        ],
      ],
    );
  }

  // Widget untuk filter warga berdasarkan status
  Widget _buildWargaFilter() {
    return PopupMenuButton<String?>(
      icon: Icon(
        Icons.filter_list,
        color: _statusFilter != null ? Colors.white : AppColors.primary,
        size: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 8),
      onSelected: (value) {
        setState(() {
          _statusFilter = value;
        });
      },
      onCanceled: () {
        setState(() {
          _statusFilter = null;
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Semua Status'),
              if (_statusFilter == null) ...[
                const Spacer(),
                const Icon(Icons.check, size: 18, color: AppColors.primary),
              ],
            ],
          ),
        ),
        const PopupMenuItem(
          height: 1,
          enabled: false,
          child: Divider(height: 1),
        ),
        PopupMenuItem(
          value: 'Aktif',
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Aktif'),
              if (_statusFilter == 'Aktif') ...[
                const Spacer(),
                const Icon(Icons.check, size: 18, color: AppColors.primary),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Tidak Aktif',
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Tidak Aktif'),
              if (_statusFilter == 'Tidak Aktif') ...[
                const Spacer(),
                const Icon(Icons.check, size: 18, color: AppColors.primary),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWargaList(List<dynamic> list, BuildContext context) {
    // Filter berdasarkan search dan status
    final filteredList = list.where((warga) {
      // Filter search
      final matchesSearch =
          _searchQuery.isEmpty ||
          warga.namaLengkap.toLowerCase().contains(_searchQuery) ||
          warga.nik.toLowerCase().contains(_searchQuery);

      // Filter status
      final matchesStatus =
          _statusFilter == null ||
          (warga.userStatus ?? 'Tidak Aktif') == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data yang sesuai',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final w = filteredList[index];
        final wargaId = w.id;

        // Ensure each card has a unique key
        _cardKeys.putIfAbsent(wargaId, () => GlobalKey());

        return WargaCard(
          key: _cardKeys[wargaId],
          cardKey: _cardKeys[wargaId],
          warga: w,
          isExpanded: _expandedWargaId == wargaId,
          onToggle: () {
            setState(() {
              // Toggle: close if already open, open if closed
              _expandedWargaId = _expandedWargaId == wargaId ? null : wargaId;
            });
          },
        );
      },
    );
  }

  Widget _buildKeluargaList(
    List<MapEntry<int, List<dynamic>>> kkList,
    BuildContext context,
  ) {
    // Filter berdasarkan search saja
    final filteredList = kkList.where((entry) {
      final idKk = entry.key;
      final members = entry.value;
      final kepalaKeluarga = members.first;

      // Search bisa berdasarkan nomor KK atau nama kepala keluarga
      final kkNumber = 'KK${idKk.toString().padLeft(9, '0')}';
      final matchesSearch =
          _searchQuery.isEmpty ||
          kkNumber.toLowerCase().contains(_searchQuery) ||
          idKk.toString().contains(_searchQuery) ||
          kepalaKeluarga.namaLengkap.toLowerCase().contains(_searchQuery);

      return matchesSearch;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data yang sesuai',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final entry = filteredList[index];
        final idKk = entry.key;
        final members = entry.value;
        final kepalaKeluarga = members.first;

        return KeluargaCard(
          idKk: idKk,
          kepalaKeluarga: kepalaKeluarga,
          members: members,
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
