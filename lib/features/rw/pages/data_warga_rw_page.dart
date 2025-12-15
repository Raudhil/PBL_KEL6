import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_top_bar.dart';
import '../../../theme/app_colors.dart';

class DataWargaRwPage extends ConsumerStatefulWidget {
  const DataWargaRwPage({super.key});

  @override
  ConsumerState<DataWargaRwPage> createState() => _DataWargaRwPageState();
}

class _DataWargaRwPageState extends ConsumerState<DataWargaRwPage> {
  String _selectedFilter = 'Semua RT';
  final List<String> _filterOptions = [
    'Semua RT',
    'RT 001',
    'RT 002',
    'RT 003',
    'RT 004',
  ];

  // Dummy data warga per RT
  final List<Map<String, dynamic>> _dataPerRT = [
    {
      'rt': 'RT 001',
      'jumlahKK': 42,
      'jumlahWarga': 125,
      'lakiLaki': 65,
      'perempuan': 60,
      'anak': 35,
      'dewasa': 70,
      'lansia': 20,
      'ketua': 'Budi Santoso',
    },
    {
      'rt': 'RT 002',
      'jumlahKK': 50,
      'jumlahWarga': 150,
      'lakiLaki': 78,
      'perempuan': 72,
      'anak': 42,
      'dewasa': 85,
      'lansia': 23,
      'ketua': 'Ahmad Fauzi',
    },
    {
      'rt': 'RT 003',
      'jumlahKK': 35,
      'jumlahWarga': 105,
      'lakiLaki': 55,
      'perempuan': 50,
      'anak': 28,
      'dewasa': 60,
      'lansia': 17,
      'ketua': 'Siti Aminah',
    },
    {
      'rt': 'RT 004',
      'jumlahKK': 45,
      'jumlahWarga': 135,
      'lakiLaki': 70,
      'perempuan': 65,
      'anak': 38,
      'dewasa': 75,
      'lansia': 22,
      'ketua': 'Joko Widodo',
    },
  ];

  List<Map<String, dynamic>> get _filteredData {
    if (_selectedFilter == 'Semua RT') {
      return _dataPerRT;
    }
    return _dataPerRT.where((data) => data['rt'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Hitung total keseluruhan
    int totalKK = 0;
    int totalWarga = 0;
    int totalLakiLaki = 0;
    int totalPerempuan = 0;
    int totalAnak = 0;
    int totalDewasa = 0;
    int totalLansia = 0;

    for (var data in _dataPerRT) {
      totalKK += data['jumlahKK'] as int;
      totalWarga += data['jumlahWarga'] as int;
      totalLakiLaki += data['lakiLaki'] as int;
      totalPerempuan += data['perempuan'] as int;
      totalAnak += data['anak'] as int;
      totalDewasa += data['dewasa'] as int;
      totalLansia += data['lansia'] as int;
    }

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Data Warga RW', showBackButton: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter RT
              _buildFilterRT(),
              const SizedBox(height: 20),

              // Total Summary (hanya tampil jika Semua RT)
              if (_selectedFilter == 'Semua RT') ...[
                _buildTotalSummaryCard(
                  totalKK,
                  totalWarga,
                  totalLakiLaki,
                  totalPerempuan,
                  totalAnak,
                  totalDewasa,
                  totalLansia,
                ),
                const SizedBox(height: 24),
              ],

              // Section Header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedFilter == 'Semua RT'
                        ? 'Data Per RT'
                        : 'Detail ${_selectedFilter}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List Data per RT
              ..._filteredData.map((data) => _buildRTCard(data)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRT() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          const Text(
            'Filter RT:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                items: _filterOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedFilter = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(
    int totalKK,
    int totalWarga,
    int lakiLaki,
    int perempuan,
    int anak,
    int dewasa,
    int lansia,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary600, AppColors.primary500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.groups, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Keseluruhan RW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Data warga dari semua RT',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // KK dan Warga
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.home, color: AppColors.white, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        '$totalKK',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const Text(
                        'Kepala Keluarga',
                        style: TextStyle(fontSize: 12, color: AppColors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.people, color: AppColors.white, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        '$totalWarga',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const Text(
                        'Total Warga',
                        style: TextStyle(fontSize: 12, color: AppColors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Jenis Kelamin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berdasarkan Jenis Kelamin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.male, color: AppColors.white, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Laki-laki',
                        style: TextStyle(fontSize: 13, color: AppColors.white),
                      ),
                    ),
                    Text(
                      '$lakiLaki orang',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.female, color: AppColors.white, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Perempuan',
                        style: TextStyle(fontSize: 13, color: AppColors.white),
                      ),
                    ),
                    Text(
                      '$perempuan orang',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Usia
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berdasarkan Kategori Usia',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$anak',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const Text(
                          'Anak',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white,
                          ),
                        ),
                        const Text(
                          '(0-17 th)',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.white.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '$dewasa',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const Text(
                          'Dewasa',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white,
                          ),
                        ),
                        const Text(
                          '(18-59 th)',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.white.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '$lansia',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const Text(
                          'Lansia',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white,
                          ),
                        ),
                        const Text(
                          '(≥60 th)',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRTCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header RT
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.home_work,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['rt'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Ketua: ${data['ketua']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistik
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greyLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // KK dan Warga
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        Icons.home,
                        'KK',
                        data['jumlahKK'].toString(),
                        AppColors.primary,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.greyLight),
                    Expanded(
                      child: _buildStatItem(
                        Icons.people,
                        'Warga',
                        data['jumlahWarga'].toString(),
                        AppColors.info,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),

                // Jenis Kelamin
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        Icons.male,
                        'Laki-laki',
                        data['lakiLaki'].toString(),
                        Colors.blue,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.greyLight),
                    Expanded(
                      child: _buildStatItem(
                        Icons.female,
                        'Perempuan',
                        data['perempuan'].toString(),
                        Colors.pink,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),

                // Kategori Usia
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        Icons.child_care,
                        'Anak',
                        data['anak'].toString(),
                        AppColors.success,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.greyLight),
                    Expanded(
                      child: _buildStatItem(
                        Icons.person,
                        'Dewasa',
                        data['dewasa'].toString(),
                        AppColors.warning,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.greyLight),
                    Expanded(
                      child: _buildStatItem(
                        Icons.elderly,
                        'Lansia',
                        data['lansia'].toString(),
                        AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
