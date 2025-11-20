import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/widgets/custom_top_bar.dart';

class KelolaPenggunaPage extends ConsumerStatefulWidget {
  const KelolaPenggunaPage({super.key});

  @override
  ConsumerState<KelolaPenggunaPage> createState() => _KelolaPenggunaPageState();
}

class _KelolaPenggunaPageState extends ConsumerState<KelolaPenggunaPage> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Aktif', 'Tidak Aktif'];

  // Dummy data - nanti diganti dengan data dari Supabase
  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'nama': 'Admin Jawara',
      'email': 'admin@jawara.com',
      'role': 'Admin',
      'status': 'Aktif',
    },
    {
      'id': 2,
      'nama': 'Jokowi',
      'email': 'jokowi@test.com',
      'role': 'Warga',
      'status': 'Aktif',
    },
    {
      'id': 3,
      'nama': 'Yanto Kopling',
      'email': 'yanto@test.com',
      'role': 'Bendahara',
      'status': 'Aktif',
    },
    {
      'id': 4,
      'nama': 'Budi Santoso',
      'email': 'budi@test.com',
      'role': 'Sekretaris',
      'status': 'Tidak Aktif',
    },
    {
      'id': 5,
      'nama': 'Ketua RT',
      'email': 'rt@test.com',
      'role': 'RT',
      'status': 'Aktif',
    },
    {
      'id': 6,
      'nama': 'Ketua RW',
      'email': 'rw@test.com',
      'role': 'RW',
      'status': 'Aktif',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _selectedFilter == 'Semua'
        ? _users
        : _users.where((user) => user['status'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(
        title: 'Kelola Pengguna',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.success
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.greyDark,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // User list
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.greyDark,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada pengguna',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.greyDark,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _UserCard(
                        nama: user['nama'],
                        email: user['email'],
                        role: user['role'],
                        status: user['status'],
                        onTap: () {
                          // TODO: Navigate to user detail/edit page
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Edit ${user['nama']}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add user page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tambah Pengguna - Dalam Pengembangan'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        backgroundColor: AppColors.success,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Tambah Pengguna',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String nama;
  final String email;
  final String role;
  final String status;
  final VoidCallback onTap;

  const _UserCard({
    required this.nama,
    required this.email,
    required this.role,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Aktif';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  nama[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 13, color: AppColors.greyDark),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary600.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.greyDark),
          ],
        ),
      ),
    );
  }
}
